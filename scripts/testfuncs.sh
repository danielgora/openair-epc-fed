#!/bin/bash
#set -x
TOP_DIR=$(git rev-parse --show-toplevel)
source $TOP_DIR/scripts/params.sh

LOGFILE_DIR=$TOP_DIR/archives

run_with_echo() {
    echo $@
    "$@"
}

remove_docker_net() {
    echo
    echo "======================"
    echo "Removing Docker Networks"
    echo "======================"
    docker network rm oai-public-net oai-private-net
}

create_docker_net() {
    echo
    echo "======================"
    echo "Creating Docker Networks"
    echo "======================"
    # Ensure that all traffic is forwarded to the containers from the outside world...
    # ZZZ: Probably should lock this down better...
    run_with_echo sudo sysctl net.ipv4.conf.all.forwarding=1
    run_with_echo sudo iptables -P FORWARD ACCEPT
    if docker network ls | egrep "oai-public-net|oai-private-net"
    then
        return 0
    fi
    if ! run_with_echo docker network create --attachable --subnet $PUBLIC_NETWORK_RANGE \
                             --ip-range $PUBLIC_NETWORK_RANGE oai-public-net
    then
        echo "Error: Failed to create docker public network $PUBLIC_NETWORK_RANGE"
        return 1
    fi
    if ! run_with_echo docker network create --attachable --subnet $PRIVATE_NETWORK_RANGE \
                             --ip-range $PRIVATE_NETWORK_RANGE oai-private-net
    then
        echo "Error: Failed to create docker private network $PRIVATE_NETWORK_RANGE"
        return 1
    fi
    return 0
}

# Search for the docker image with the specified tag
# arg1 type (hss/mme/spgwc/spgwu-tiny)
# arg2 tag
find_image_tag() {
        if ! docker image inspect oai-$1:$2 > /dev/null 2>&1
        then
            echo "Error: Docker image oai-$1:$2 does not exist!"
            echo "Specify the correct tag with the --tag option"
            return 1
        fi
}

deploy_cassandra() {
    pushd $TOP_DIR > /dev/null 2>&1
    echo
    echo "======================"
    echo "Deploying Cassandra DB"
    echo "======================"
    if docker ps -a | grep "cassandra" > /dev/null
    then
        remove_cassandra
    fi
    if ! run_with_echo docker run --name oai-cassandra --network oai-private-net --ip $CASS_IP_ADDR -d \
        -e CASSANDRA_CLUSTER_NAME='OAI_HSS_Cluster' \
        -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch cassandra:2.1
    then
        echo "Error: Failed to start Cassandra DB container at IP $CASS_IP_ADDR"
        return 1
    fi

    # Wait until the container starts up
    until docker exec -it oai-cassandra /bin/bash -c "nodetool status" | \
            grep "UN.*$CASS_IP_ADDR" > /dev/null
    do
        echo "Waiting for Cassandra DB to start..."
        sleep 1
    done
    docker exec -it oai-cassandra /bin/bash -c "nodetool status"
    run_with_echo docker cp component/oai-hss/src/hss_rel14/db/oai_db.cql oai-cassandra:/home
    sleep 3
    run_with_echo docker exec -it oai-cassandra /bin/bash -c "cqlsh --file /home/oai_db.cql $CASS_IP_ADDR"
    ret=$?
    while [ $ret -ne 0 ]
    do
        docker exec -it oai-cassandra /bin/bash -c "cqlsh --file /home/oai_db.cql $CASS_IP_ADDR" > /dev/null
        ret=$?
        echo "Waiting for Cassandra DB Shell to start..."
        sleep 1
    done
    popd > /dev/null 2>&1
    return $ret
}

deploy_hss() {
    pushd $TOP_DIR > /dev/null 2>&1
    echo
    echo "======================"
    echo "Deploying HSS"
    echo "======================"
    if ! find_image_tag hss $tag
    then
        read -p "OAI-HSS tag $tag not found.  Do you want to build the image? (y/n)" rsp
        rsp=${rsp:-"y"}
        if [ "y" == "$rsp" ]
        then
            if ! build hss
            then
                return 1
            fi
        fi
    fi

    # SDB to Cassandra will be on `eth0`
    # S6A to MME will be on `eth1`
    run_with_echo docker run --privileged --name oai-hss --network oai-private-net --ip $HSS_DBN_ADDR \
               -d --entrypoint "/bin/bash" oai-hss:$tag -c "sleep infinity"
    run_with_echo docker network connect --ip $HSS_PUBLIC_ADDR oai-public-net oai-hss
    run_with_echo python3 component/oai-hss/ci-scripts/generateConfigFiles.py --kind=HSS \
            --cassandra=$CASS_IP_ADDR \
            --hss_s6a=$HSS_PUBLIC_ADDR \
            --apn1=apn1.carrier.com \
            --apn2=apn2.carrier.com \
            --users=200 \
            --imsi=$IMSI \
            --ltek=$USIM_API_K \
            --op=$OP \
            --nb_mmes=4 \
            --from_docker_file
    run_with_echo docker cp ./hss-cfg.sh oai-hss:/openair-hss/scripts
    run_with_echo docker exec -it oai-hss /bin/bash -c \
            "cd /openair-hss/scripts && chmod 777 hss-cfg.sh && ./hss-cfg.sh > hss_deploy.log 2>&1"
    ret=$?
    popd > /dev/null 2>&1
    return $ret
}

deploy_mme() {
    pushd $TOP_DIR > /dev/null 2>&1
    echo
    echo "======================"
    echo "Deploying MME"
    echo "======================"
    # Ensure that SCTP is installed in the kernel in the docker host system.
    # It's required for MME
    if ! run_with_echo sudo modprobe sctp
    then
        echo "Error: Failed to install SCTP kernel module!"
        echo "Ensure that SCTP is installed in this host system!"
        exit 1
    fi
    if ! find_image_tag mme $tag
    then
        read -p "OAI-MME tag $tag not found.  Do you want to build the image? (y/n)" rsp
        rsp=${rsp:-"y"}
        if [ "y" == "$rsp" ]
        then
            if ! build mme
            then
                return 1
            fi
        fi
    fi
    # SDB to Cassandra will be on `eth0`
    # S6A to MME will be on `eth1`
    run_with_echo docker run --privileged --name oai-mme --network oai-public-net --ip $MME_PUBLIC_ADDR \
               -d --entrypoint "/bin/bash" oai-mme:$tag -c "sleep infinity"
    run_with_echo python3 ./component/oai-mme/ci-scripts/generateConfigFiles.py --kind=MME \
            --hss_s6a=$HSS_PUBLIC_ADDR \
            --mme_s6a=$MME_PUBLIC_ADDR \
            --mme_s1c_IP=$MME_PUBLIC_ADDR \
            --mme_s1c_name=eth0 \
            --mme_s10_IP=$MME_PUBLIC_ADDR \
            --mme_s10_name=eth0 \
            --mme_s11_IP=$MME_PUBLIC_ADDR \
            --mme_s11_name=eth0 \
            --spgwc0_s11_IP=$SPGWC_PUBLIC_ADDR \
            --mcc=$MCC \
            --mnc=$MNC \
            --mme_gid=$MME_GID \
            --mme_code=$MME_CODE \
            --tac_list="$TAC1 $TAC2 $TAC3" \
            --realm="$REALM" \
            --from_docker_file
    run_with_echo docker cp ./mme-cfg.sh oai-mme:/openair-mme/scripts
    run_with_echo docker exec -it oai-mme /bin/bash -c \
            "cd /openair-mme/scripts && chmod 777 mme-cfg.sh && ./mme-cfg.sh > mme_deploy.log 2>&1"
    ret=$?
    popd > /dev/null 2>&1
    return $ret
}

deploy_spgwc() {
    pushd $TOP_DIR > /dev/null 2>&1
    echo
    echo "======================"
    echo "Deploying SPGW-C"
    echo "======================"
    if ! find_image_tag spgwc $tag
    then
        read -p "OAI-SPGWC tag $tag not found.  Do you want to build the image? (y/n)" rsp
        rsp=${rsp:-"y"}
        if [ "y" == "$rsp" ]
        then
            if ! build spgwc
            then
                return 1
            fi
        fi
    fi
    # SDB to Cassandra will be on `eth0`
    # S6A to MME will be on `eth1`
    run_with_echo docker run --privileged --name oai-spgwc --network oai-public-net --ip $SPGWC_PUBLIC_ADDR \
               -d --entrypoint "/bin/bash" oai-spgwc:$tag -c "sleep infinity"
    run_with_echo python3 ./component/oai-spgwc/ci-scripts/generateConfigFiles.py --kind=SPGW-C \
            --s11c=eth0 \
            --sxc=eth0 \
            --dns1_ip=8.8.8.8 \
            --dns2_ip=1.1.1.1 \
            --apn="apn1.carrier.com" \
            --network_ue_ip="12.0.0.0/24" \
            --from_docker_file

    run_with_echo docker exec -it oai-spgwc /bin/bash -c "mkdir -p /openair-spgwc/scripts"
    run_with_echo docker cp ./spgwc-cfg.sh oai-spgwc:/openair-spgwc/scripts
    run_with_echo docker exec -it oai-spgwc /bin/bash -c \
            "cd /openair-spgwc/scripts && chmod 777 spgwc-cfg.sh && ./spgwc-cfg.sh > spgwc_deploy.log 2>&1"
    ret=$?
    popd > /dev/null 2>&1
    return $ret
}

deploy_spgwu-tiny() {
    pushd $TOP_DIR > /dev/null 2>&1
    echo
    echo "======================"
    echo "Deploying SPGW-U"
    echo "======================"
    if ! find_image_tag spgwu-tiny $tag
    then
        read -p "OAI-SPGWU-tiny tag $tag not found.  Do you want to build the image? (y/n)" rsp
        rsp=${rsp:-"y"}
        if [ "y" == "$rsp" ]
        then
            if ! build spgwu-tiny
            then
                return 1
            fi
        fi
    fi
    # SDB to Cassandra will be on `eth0`
    # S6A to MME will be on `eth1`
    run_with_echo docker run --privileged --name oai-spgwu-tiny --network oai-public-net --ip $SPGWU_PUBLIC_ADDR \
               -d --entrypoint "/bin/bash" oai-spgwu-tiny:$tag -c "sleep infinity"
    run_with_echo python3 ./component/oai-spgwu-tiny/ci-scripts/generateConfigFiles.py --kind=SPGW-U \
            --sxc_ip_addr=$SPGWC_PUBLIC_ADDR \
            --sxu=eth0 \
            --s1u=eth0 \
            --network_ue_ip="12.0.0.0/24" \
            --network_ue_nat_option="yes" \
            --from_docker_file
    run_with_echo docker exec -it oai-spgwu-tiny /bin/bash -c "mkdir -p /openair-spgwu-tiny/scripts"
    run_with_echo docker cp ./spgwu-cfg.sh oai-spgwu-tiny:/openair-spgwu-tiny/scripts
    run_with_echo docker exec -it oai-spgwu-tiny /bin/bash -c \
            "cd /openair-spgwu-tiny/scripts && chmod 777 spgwu-cfg.sh && ./spgwu-cfg.sh > spgwu-tiny_deploy.log 2>&1"
    ret=$?
    popd > /dev/null 2>&1
    return $ret
}

# Build the containers
# Specify which ones or all by default
build() {
    pushd $TOP_DIR > /dev/null 2>&1
    local elms
    local target
    elms=${@:-"hss mme spgwc spgwu-tiny"}
    for target in $elms
    do
        if ! docker build --target oai-$target \
                          --tag oai-$target:$tag \
                          --file component/oai-$target/docker/Dockerfile.centos8 \
                          component/oai-$target
        then
            echo "Error: Failed to build container for $target!"
            return 1
        fi
    done
    popd > /dev/null 2>&1
}

deploy() {
    local elms
    local t

    if [ ! -d $LOGFILE_DIR ]
    then
        echo "Creating log file directory $LOGFILE_DIR"
        mkdir -p $LOGFILE_DIR
        rm -rf $LOGFILE_DIR/*
    fi
    if ! create_docker_net
    then
        exit 1
    fi

    elms=${@:-"cassandra hss mme spgwc spgwu-tiny"}
    for t in $elms
    do
        if ! deploy_${t}
        then
            exit 1
        fi
    done
}

stop_bin() {
    local elms
    local t
    elms=${@:-"cassandra hss mme spgwc spgwu-tiny"}
    for t in $elms
    do
        echo "Stopping oai-${t}..."
        docker rm -f oai-$t 2>/dev/null
    done
}

# Start tcpdump on all the containers.
start_trace() {
    pushd $TOP_DIR > /dev/null 2>&1
    local elms
    local t
    elms=${@:-"hss mme spgwc spgwu-tiny"}
    for t in $elms
    do
        docker exec -d oai-$t /bin/bash -c "nohup tcpdump -i any -w /tmp/${t}.pcap 2>&1 > /dev/null"
    done
    popd > /dev/null 2>&1
}

start_bin() {
    echo
    echo "======================"
    echo "Starting OAI EPC elements"
    echo "======================"
    local elms
    local t
    elms=${@:-"hss mme spgwc spgwu-tiny"}
    for t in $elms
    do
        case $t in
        hss)
            # Start the binaries
            run_with_echo docker exec -d oai-hss /bin/bash -c \
                    "nohup ./bin/oai_hss -j ./etc/hss_rel14.json --reloadkey true > hss_run.log 2>&1"
            sleep 2
        ;;
        mme)
            run_with_echo docker exec -d oai-mme /bin/bash -c \
                    "nohup ./bin/oai_mme -c ./etc/mme.conf > mme_run.log 2>&1"
            sleep 2
        ;;
        spgwc)
            run_with_echo docker exec -d oai-spgwc /bin/bash -c \
                    "nohup ./bin/oai_spgwc -o -c ./etc/spgw_c.conf > spgwc_run.log 2>&1"
            sleep 2
        ;;
        spgwu-tiny)
            run_with_echo docker exec -d oai-spgwu-tiny /bin/bash -c \
                    "nohup ./bin/oai_spgwu -o -c ./etc/spgw_u.conf > spgwu-tiny_run.log 2>&1"
            sleep 2
        ;;
        esac
    done
}

get_configs() {
    pushd $TOP_DIR > /dev/null 2>&1
    local elms
    local t
    elms=${@:-"hss mme spgwc spgwu-tiny"}
    for t in $elms
    do
        mkdir -p $LOGFILE_DIR/${t}-cfg
        docker cp oai-${t}:/openair-${t}/etc/. $LOGFILE_DIR/${t}-cfg
    done
    popd > /dev/null 2>&1
}

get_logs() {
    pushd $TOP_DIR > /dev/null 2>&1
    local elms
    local t
    elms=${@:-"hss mme spgwc spgwu-tiny"}
    for t in $elms
    do
        docker cp oai-${t}:/openair-${t}/scripts/${t}_deploy.log $LOGFILE_DIR
        docker cp oai-${t}:/openair-${t}/${t}_run.log $LOGFILE_DIR
        echo
        echo "==================="
        echo "${t} Deploy Logfile"
        echo "==================="
        cat $LOGFILE_DIR/${t}_deploy.log
        echo
        echo "==================="
        echo "${t} Runtime Logfile"
        echo "==================="
        cat $LOGFILE_DIR/${t}_run.log
    done
    popd > /dev/null 2>&1
}

get_pcap() {
    pushd $TOP_DIR > /dev/null 2>&1
    local elms
    local t
    elms=${@:-"hss mme spgwc spgwu-tiny"}
    for t in $elms
    do
        echo "Getting $t pcap file"
        echo "================="
        docker cp oai-$t:/tmp/${t}.pcap $LOGFILE_DIR
    done
    popd > /dev/null 2>&1
}
