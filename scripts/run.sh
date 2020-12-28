#!/bin/bash
#
# Test script to fully configure and deploy all of the EPC elements
# as Centos 8 docker containers
#
# Find the top level directory of OAI-EPC-fed
TOP_DIR=$(git rev-parse --show-toplevel)
source $TOP_DIR/scripts/testfuncs.sh

case $1 in
    build)
        shift
        build $*
    ;;
    deploy)
        deploy_$2
    ;;
    start | run)
        deploy
        start_trace
        start_bin
        get_configs
        echo "======================"
        echo "OAI-EPC started successfully!"
        echo "Run $0 logs to show logs from each element..."
        echo "======================"
    ;;
    stop)
        stop_all
    ;;
    logs)
        get_logs
    ;;
    configs)
        get_configs
    ;;
    pcap)
        get_pcap
    ;;
    *)
        echo "$0 [build | run | logs | configs | pcap | stop]"
        echo "build: [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "logs: [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "configs: [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "pcap: [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        exit 1
    ;;
esac
