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
        echo "$0 [start | stop | build | logs | configs | pcap]"
        echo "start [ cassandra | hss | mme | spgwc | spgwu-tiny ]"
        echo "   Deploy and run selected EPC network elements (default=all)"
        echo
        echo "stop [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "   Stop selected EPC network element (default=all)"
        echo
        echo "build [ cassandra | hss | mme | spgwc | spgwu-tiny ]"
        echo "   Build Docker image for selected network elements (default=all)"
        echo
        echo "logs [ hss | mme | spgwc | spgwu-tiny ]"
        echo "   Retrieve and show deployment and runtime log "
        echo "   from selected element (default=all)"
        echo
        echo "configs [ hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "   Retrieve and show configuration files "
        echo "   from selected element (default=all)"
        echo
        echo "pcap [ hss | mme | spgwc | spgwu-tiny ] (default=all)"
        echo "   Retrieve and show wireshark pcap files "
        echo "   from selected element (default=all)"
        echo
        exit 1
    ;;
esac
