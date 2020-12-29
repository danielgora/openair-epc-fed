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
        build $@
    ;;
    deploy)
        shift
        deploy $@
    ;;
    start | run)
        shift
        deploy $@
        start_trace $@
        start_bin $@
        get_configs $@
        echo "======================"
        echo "OAI-EPC started $@!"
        echo "Run:"
        echo "$0 logs $@"
        echo "to show the logs..."
        echo "======================"
    ;;
    stop)
        shift
        stop_bin $@
    ;;
    logs)
        shift
        get_logs $@
    ;;
    configs)
        shift
        get_configs $@
    ;;
    pcap)
        shift
        get_pcap $@
    ;;
    *)
        echo "$0 [build | run | logs | configs | pcap | stop]"
        echo "build [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "logs [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "configs [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "pcap [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "stop [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        exit 1
    ;;
esac
