#!/bin/bash
# EPC Docker Test Network parameters
PRIVATE_NETWORK_RANGE='192.168.68.0/26'
PUBLIC_NETWORK_RANGE='192.168.61.192/26'

# Cassandra DB IP addr on private network
CASS_IP_ADDR='192.168.68.2'
# HSS IP addr on private network to connect to Cassandra DB
HSS_DBN_ADDR='192.168.68.3'

# HSS IP on public network
HSS_PUBLIC_ADDR='192.168.61.194'
# MME IP on public network
MME_PUBLIC_ADDR='192.168.61.195'
# SPGW-C IP on public network
SPGWC_PUBLIC_ADDR='192.168.61.196'
# SPGW-U IP on public network
SPGWU_PUBLIC_ADDR='192.168.61.197'

# S1AP Realm (domain name)
REALM=openairinterface.org
# Mobile Country Code (3 digits)
MCC=208
# Mobile Network Code (2 or 3 digits)
MNC=93
# Mobile SIM number, together with MCC/MNC forms the IMSI
# This must match the MSIN value in the configuration file
# passed to conf2uedata if you are using the Openairinterface UE simulator
MSIN="0000000001"
# IMSI - International Mobile Subscriber Identity ie Who is the user?
# (15 or 16 digits)
IMSI="$MCC"
IMSI+="$MNC"
IMSI+="$MSIN"
# USIM LTE API K.  Rijndael Key Schedule value. See 3gpp ts 35.206
USIM_API_K="8baf473f2f8fd09487cccbd7097c6862"
# OP. Operator Key.  Used to generate OPc value. See 3gpp ts 35.206
OP="11111111111111111111111111111111"

# GUMMEI (Globally unique MME Ids PLMN (MCC|MNC) + MME_GUI + MME_CODE)
# See TS 36.413
MME_GID=1
MME_CODE=1

# Tracking Area Codes for MCC/MNC
TAC1=1
TAC2=2
TAC3=3
