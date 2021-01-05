<table style="border-collapse: collapse; border: none;">
  <tr style="border-collapse: collapse; border: none;">
    <td style="border-collapse: collapse; border: none;">
      <a href="http://www.openairinterface.org/">
         <img src="./images/oai_final_logo.png" alt="" border=3 height=50 width=150>
         </img>
      </a>
    </td>
    <td style="border-collapse: collapse; border: none; vertical-align: center;">
      <b><font size = "5">OpenAirInterface Core Network Docker Deployment : EPC in a box</font></b>
    </td>
  </tr>
</table>

# Preface

This tutorial describes a simple, turn-key solution to creating your first
4G virtual network with OAI-EPC and testing it using the OAI openairinterface
eNodeB and UE simulators with a minimum of equipment and configuration.

All the network elements can be run on a single machine using virtual
machines which can be quickly and easily created using Vagrant with the
Vagrantfile provided in the OAI openairinterface repository.

This tutorial will use the eNB and UE simulators from openairinterface
passing data over ethernet, so no external radio hardware or antennas
are required.

The goal here is to provide a simple, base solution in order to verify the
basic connectivity and operation of the EPC, eNB and UE and give the user
an opprotunity to test and learn how the pieces interact without the need
for an elaborate system setup or external hardware.

# Download and install the OAI openairinterface source code.

The `openairinterface` eNodeB and UE simulators can be downloaded from
[github.com](https://github.com/danielgora/openairinterface5g.git)

```bash
host1 $ git clone https://github.com/danielgora/openairinterface5g.git
host1 $ # Eventually these changes will be hosted here:
host1 $ # git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git
```

Switch to the `develop` branch:

```bash
host1 $ cd openairinterface5g
host1 $ git checkout -b develop origin/develop
```

In the `vagrant/centos` subdirectory should be a Vagrantfile which will
be used to create and configure three virtual machines; one for the UE,
one for the eNB and one for the EPC:

```bash
host1 $ ls vagrant/centos/
Vagrantfile
```

# Create the eNodeB and UE Virtual Machines

In order to create the virtual machines, the user must first install
[Vagrant](https://www.vagrantup.com/downloads).

After vagrant is installed the virtual machines are created with the
`vagrant up` command:

```bash
host1 $ cd vagrant/centos/
host1 $ vagrant up
```

This command will automatically create and configure the virtual machines
for the eNodeB and the UE, downloading the proper source code and compiling
it appropriately for the eNB and UE.

The `Vagrantfile` specifies the location and the git branch for the
Openairinterface and OAI-EPC source code.

```bash
host1 $ cat Vagrantfile
<snip>

  # Select the openairinterface5g repo and branch to use...
  #oairepo = "https://gitlab.eurecom.fr/oai/openairinterface5g.git"
  #branch = "develop"
  oairepo = "https://github.com/danielgora/openairinterface5g.git"
  oaibranch = "develop"
  oaiclonecmd = "git clone " + oairepo + " -b " + oaibranch + " --single-branch"

  # Select the OAI-EPC (cn5g) repo and branch to use...
  epcrepo = "https://github.com/danielgora/openair-epc-fed.git"
  epcbranch = "develop"
  epcclonecmd = "git clone " + epcrepo + " -b " + epcbranch + " --single-branch"

<snip>
```

After the **OAI-eNB** and **OAI-UE** virtual machines are created, the
user can log into each one using the `vagrant ssh` command.  Note that
this must be peformed from the same directory where the Vagrantfile resides
because the ssh keys are stored in the `.vagrant` directory:

```bash
host1 $ cd ~/openairinterface5g/vagrant/centos/
host1 $ vagrant ssh OAI-eNB
Last login: Tue Dec 29 19:16:13 2020 from 10.0.2.2
[vagrant@eNB ~]$ 
```

```bash
host1 $ cd ~/openairinterface5g/vagrant/centos/
host1 $ vagrant ssh OAI-UE
Last login: Tue Dec 29 19:16:13 2020 from 10.0.2.2
[vagrant@UE ~]$ 
```

At this point it would be useful to read
and perform the tests documented in the [BasicSim NoS1
Test](https://github.com/danielgora/openairinterface5g/blob/develop_nas_nos1_fixes/doc/BASIC_SIM_NOS1.md)
tutorial.

This test does not require an EPC and will confirm that the eNB and UE
simulators are running correctly.

# Create the EPC Virtual Machine

The EPC virtual machine is not created or started automatically by default
with the `vagrant up` command, it must be specified as an argument to the
`vagrant up` command as follows:

```bash
host1 $ cd vagrant/centos/
host1 $ vagrant up OAI-EPC
Bringing machine 'OAI-EPC' up with 'virtualbox' provider...
==> OAI-EPC: Checking if box 'centos/8' version '2011.0' is up to date...
==> OAI-EPC: Clearing any previously set forwarded ports...
==> OAI-EPC: Clearing any previously set network interfaces...
==> OAI-EPC: Preparing network interfaces based on configuration...
    OAI-EPC: Adapter 1: nat
    OAI-EPC: Adapter 2: hostonly
==> OAI-EPC: Forwarding ports...
    OAI-EPC: 22 (guest) => 2222 (host) (adapter 1)
==> OAI-EPC: Running 'pre-boot' VM customizations...
==> OAI-EPC: Booting VM...
==> OAI-EPC: Waiting for machine to boot. This may take a few minutes...
    OAI-EPC: SSH address: 127.0.0.1:2222
    OAI-EPC: SSH username: vagrant
    OAI-EPC: SSH auth method: private key
==> OAI-EPC: Machine booted and ready!
==> OAI-EPC: Checking for guest additions in VM...
    OAI-EPC: No guest additions were detected on the base box for this VM! Guest
    OAI-EPC: additions are required for forwarded ports, shared folders, host only
    OAI-EPC: networking, and more. If SSH fails on this machine, please install
    OAI-EPC: the guest additions and repackage the box to continue.
    OAI-EPC: 
    OAI-EPC: This is not an error message; everything may continue to work properly,
    OAI-EPC: in which case you may ignore this message.
==> OAI-EPC: Setting hostname...
==> OAI-EPC: Configuring and enabling network interfaces...
==> OAI-EPC: Rsyncing folder: /home/dg/NFV/openairinterface/openairinterface5g/vagrant/centos/ => /vagrant
==> OAI-EPC: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> OAI-EPC: flag to force provisioning. Provisioners marked to run always will still run.
```

This will create a centos 8 virtual machine for the EPC and download the
correct source code and compile.

After the EPC virtual machine is created, the user can log into it and
run the EPC-in-a-box scripts to create the EPC containers.

The proper source code will automatically be downloaded and installed
when the virtual machine is created.

```bash
host1 $ cd ~/openairinterface5g/vagrant/centos/
host1 $ vagrant ssh OAI-EPC
Last login: Tue Dec 29 19:16:13 2020 from 10.0.2.2
[vagrant@EPC ~]$ 
```

# Running EPC-in-a-box

In the **OAI-EPC** virtual machine, in the directory
`./openair-epc-fed/scripts` is a bash shell script `docker_control.sh`
which automates all of the steps outlined in the previous documentation
and allows the user to run build and run all of the EPC Docker containers
with a single command.

The EPC-in-a-box scripts use centos8 as the container environment, but
can be run on any bare metal host system or inside a virtual machine.

The OAI openairinterface source tree provides a Vagrantfile which can
be used with Vagrant to automatically create and configure virtual
machines for the UE, eNB and EPC.  The EPC-in-a-box script can be
run inside this EPC virtual machine, or on another bare metal machine.

The script `docker_control.sh` is used to control the EPC-in-a-box.

```bash
[vagrant@EPC ~]$ ./scripts/docker_control.sh [start | stop | build | logs | configs | pcap]
start [ cassandra | hss | mme | spgwc | spgwu-tiny ]
   Deploy and run selected EPC network elements (default=all)

stop [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)
   Stop selected EPC network element (default=all)

build [ cassandra | hss | mme | spgwc | spgwu-tiny ]
   Build Docker image for selected network elements (default=all)

logs [ hss | mme | spgwc | spgwu-tiny ]
   Retrieve and show deployment and runtime log 
   from selected element (default=all)

configs [ hss | mme | spgwc | spgwu-tiny ] (default=all)
   Retrieve and show configuration files 
   from selected element (default=all)

pcap [ hss | mme | spgwc | spgwu-tiny ] (default=all)
   Retrieve and show wireshark pcap files 
   from selected element (default=all)
```

In order to build the EPC-in-a-box Docker must first
be installed.  To install Docker see the docker [install
page](https://docs.docker.com/engine/install/).

Docker is installed automatically when the **OAI-EPC** virtual machine is
created, so this step is not necessary unless running the `docker_control.sh`
script in other environments.

The user must also have `sudo` powers on the machine in which the containers
are going to be installed.

# Download and install the OAI-EPC-fed and component's source code.

**Note:** If using the **OAI-EPC** virtual machine created by Vagrant, this
step is not necessary as the source code will be automatically downloaded
and synchronized when the virtual machine is created.

Download the OAI-EPC-fed source repo from github.

```bash
[vagrant@EPC ~]$ git clone https://github.com/danielgora/openair-epc-fed
[vagrant@EPC ~]$ # Will eventually be hosted here:
[vagrant@EPC ~]$ # git clone https://github.com/OPENAIRINTERFACE/openair-epc-fed
```

Switch to the 'develop' branch:

```bash
[vagrant@EPC ~]$ cd openair-epc-fed
[vagrant@EPC ~]$ git checkout -b develop origin/develop
```

Download the EPC component submodules with the script `./scripts/syncComponents.sh`:

```bash
[vagrant@EPC ~]$ ./scripts/syncComponents.sh
---------------------------------------------------------
OAI-HSS    component branch : develop
OAI-MME    component branch : develop
OAI-SPGW-C component branch : develop
OAI-SPGW-U component branch : develop
---------------------------------------------------------
....
```

# Build the EPC containers

The EPC containers can be run on any base system as long as Docker is
installed and a recent linux kernel is installed which supports SCTP and GTP.
This has been tested with Centos8 and OpenSuse Leap 15.2 as a base system.

To build the EPC centos8 containers just run the following command:

```bash
[vagrant@EPC ~]$ cd openair-epc-fed
[vagrant@EPC openair-epc-fed] ./scripts/docker_control build
```

Go get some coffee.. This will take a while...

If for some reason something goes wrong and you need to make changes to
the source code, an individual component can be (re)built by specifying
the name of the component to `./scripts/docker_control build`:

```bash
[vagrant@EPC openair-epc-fed] ./scripts/docker_control build [ hss | mme | spgwc | spgwu-tiny ]
```

# Run the containers

After all the containers have been successfully built the containers can
be started.

The parameters used to configure the EPC containers are specified in
`./scripts/docker_params.sh`.  The default values are shown below:

```bash
#!/bin/bash

# Docker tag for OAI EPC images
tag=production

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
```

Typically the only parameters which may need to be modified are the IMSI
consisting of the `MCC`, `MNC`, and `MSIN`, the USIM Rijndael key schedule
value: `USIM_API_K` and the Operator Key `OP`.

This tutorial assumes that the default values above are preserved.

The EPC containers can then be started with the `docker_control start`
command:

```bash
[vagrant@EPC ~]$ cd openair-epc-fed
[vagrant@EPC openair-epc-fed] ./scripts/docker_control.sh start

======================
Creating Docker Networks
======================
sudo sysctl net.ipv4.conf.all.forwarding=1
[sudo] password for root: 
net.ipv4.conf.all.forwarding = 1
sudo iptables -P FORWARD ACCEPT
48a99a79231d        oai-private-net     bridge              local
e5afe6fe2330        oai-public-net      bridge              local

======================
Deploying Cassandra DB
======================
docker run --name oai-cassandra --network oai-private-net --ip 192.168.68.2 -d -e CASSANDRA_CLUSTER_NAME=OAI_HSS_Cluster -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch cassandra:2.1
410628adfd37e3df656d3c25e8a04e58e303fa3258691e8c4c9f28d767fe77ca
Waiting for Cassandra DB to start...
Datacenter: DC1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address       Load       Tokens  Owns (effective)  Host ID                               Rack
UN  192.168.68.2  51.65 KB   256     100.0%            2734dee1-2944-42d4-a67a-5f04e77396e2  RAC1

docker cp component/oai-hss/src/hss_rel14/db/oai_db.cql oai-cassandra:/home
docker exec -it oai-cassandra /bin/bash -c cqlsh --file /home/oai_db.cql 192.168.68.2
Connection error: ('Unable to connect to any servers', {'192.168.68.2': error(111, "Tried connecting to [('192.168.68.2', 9042)]. Last error: Connection refused")})
Waiting for Cassandra DB Shell to start...
Waiting for Cassandra DB Shell to start...
Waiting for Cassandra DB Shell to start...

======================
Deploying HSS
======================
docker run --privileged --name oai-hss --network oai-private-net --ip 192.168.68.3 -d --entrypoint /bin/bash oai-hss:production -c sleep infinity
a960d48b9848d4ecc894d33e1868ba5fc08b8189f6c9528293d26e208dc0a62a
docker network connect --ip 192.168.61.194 oai-public-net oai-hss
python3 component/oai-hss/ci-scripts/generateConfigFiles.py --kind=HSS --cassandra=192.168.68.2 --hss_s6a=192.168.61.194 --apn1=apn1.carrier.com --apn2=apn2.carrier.com --users=200 --imsi=208930000000001 --ltek=8baf473f2f8fd09487cccbd7097c6862 --op=11111111111111111111111111111111 --nb_mmes=4 --from_docker_file
docker cp ./hss-cfg.sh oai-hss:/openair-hss/scripts
docker exec -it oai-hss /bin/bash -c cd /openair-hss/scripts && chmod 777 hss-cfg.sh && ./hss-cfg.sh > hss_deploy.log 2>&1

======================
Deploying MME
======================
sudo modprobe sctp
docker run --privileged --name oai-mme --network oai-public-net --ip 192.168.61.195 -d --entrypoint /bin/bash oai-mme:production -c sleep infinity
f2247c1ad9249b67335c38127df1b94c6f9c23302490793e618c4d96ddce05b4
python3 ./component/oai-mme/ci-scripts/generateConfigFiles.py --kind=MME --hss_s6a=192.168.61.194 --mme_s6a=192.168.61.195 --mme_s1c_IP=192.168.61.195 --mme_s1c_name=eth0 --mme_s10_IP=192.168.61.195 --mme_s10_name=eth0 --mme_s11_IP=192.168.61.195 --mme_s11_name=eth0 --spgwc0_s11_IP=192.168.61.196 --mcc=208 --mnc=93 --mme_gid=1 --mme_code=1 --tac_list=1 2 3 --realm=openairinterface.org --from_docker_file
Using the same interface name and the same IP address for S11 and S10 is not allowed.
Starting a virtual interface on loopback for S10
docker cp ./mme-cfg.sh oai-mme:/openair-mme/scripts
docker exec -it oai-mme /bin/bash -c cd /openair-mme/scripts && chmod 777 mme-cfg.sh && ./mme-cfg.sh > mme_deploy.log 2>&1

======================
Deploying SPGW-C
======================
docker run --privileged --name oai-spgwc --network oai-public-net --ip 192.168.61.196 -d --entrypoint /bin/bash oai-spgwc:production -c sleep infinity
ad0b771fac354eb0c053a32764873c43d1af215b47b773767b529df47b5f8390
python3 ./component/oai-spgwc/ci-scripts/generateConfigFiles.py --kind=SPGW-C --s11c=eth0 --sxc=eth0 --dns1_ip=8.8.8.8 --dns2_ip=1.1.1.1 --apn=apn1.carrier.com --network_ue_ip=12.0.0.0/24 --from_docker_file
docker exec -it oai-spgwc /bin/bash -c mkdir -p /openair-spgwc/scripts
docker cp ./spgwc-cfg.sh oai-spgwc:/openair-spgwc/scripts
docker exec -it oai-spgwc /bin/bash -c cd /openair-spgwc/scripts && chmod 777 spgwc-cfg.sh && ./spgwc-cfg.sh > spgwc_deploy.log 2>&1

======================
Deploying SPGW-U
======================
docker run --privileged --name oai-spgwu-tiny --network oai-public-net --ip 192.168.61.197 -d --entrypoint /bin/bash oai-spgwu-tiny:production -c sleep infinity
7342859574d1e303af23146b273d322c2c953e8f29a78eaf04a7e496919d8570
python3 ./component/oai-spgwu-tiny/ci-scripts/generateConfigFiles.py --kind=SPGW-U --sxc_ip_addr=192.168.61.196 --sxu=eth0 --s1u=eth0 --network_ue_ip=12.0.0.0/24 --network_ue_nat_option=yes --from_docker_file
docker exec -it oai-spgwu-tiny /bin/bash -c mkdir -p /openair-spgwu-tiny/scripts
docker cp ./spgwu-cfg.sh oai-spgwu-tiny:/openair-spgwu-tiny/scripts
docker exec -it oai-spgwu-tiny /bin/bash -c cd /openair-spgwu-tiny/scripts && chmod 777 spgwu-cfg.sh && ./spgwu-cfg.sh > spgwu-tiny_deploy.log 2>&1

======================
Starting OAI EPC elements
======================
docker exec -d oai-hss /bin/bash -c nohup ./bin/oai_hss -j ./etc/hss_rel14.json --reloadkey true > hss_run.log 2>&1
docker exec -d oai-mme /bin/bash -c nohup ./bin/oai_mme -c ./etc/mme.conf > mme_run.log 2>&1
docker exec -d oai-spgwc /bin/bash -c nohup ./bin/oai_spgwc -o -c ./etc/spgw_c.conf > spgwc_run.log 2>&1
docker exec -d oai-spgwu-tiny /bin/bash -c nohup ./bin/oai_spgwu -o -c ./etc/spgw_u.conf > spgwu-tiny_run.log 2>&1

======================
OAI-EPC started !
Run:
./scripts/docker_control.sh logs 
to show the logs...
======================
```

Note that this script will automatically enable IP forwarding in the
EPC container host system, reset the `iptables` filter to allow external
machines to access the EPC containers and insert the SCTP kernel module
into the EPC container host system if it is not installed already.

# Connect the eNodeB to the EPC

In this tutorial we will use the OAI eNB and UE simulators in "basic sim"
mode without any radios to confirm the basic functionaltiy and connectivity.

The OAI eNB and UE simulators can be downloaded from
[gitlab.eurocom.fr](https://gitlab.eurecom.fr/oai/openairinterface5g) and
their virtual machines created as specified above in 
[Create the eNodeB and UE Virtual Machines](#create-the-enodeb-and-ue-virtual-machines)

After the EPC containers have been started, the eNodeB simulator can be
started to connect to the EPC.

The first step is to run a Docker command in the **OAI-EPC** virtual
machine to monitor the MMC's log file in order to watch the progress of
the eNodeB attaching to the EPC.

```bash
[vagrant@EPC scripts]$ docker exec -it oai-mme tail -f mme_run.log
000310 00020:899270 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0039    ======================================= STATISTICS ============================================

000311 00020:899349 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0042                   |   Current Status| Added since last display|  Removed since last display |
000312 00020:899356 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0048    Connected eNBs |          0      |              0              |             0               |
000313 00020:899391 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0054    Attached UEs   |          0      |              0              |             0               |
000314 00020:899398 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0060    Connected UEs  |          0      |              0              |             0               |
000315 00020:899404 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0066    Default Bearers|          0      |              0              |             0               |
000316 00020:899410 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0072    S1-U Bearers   |          0      |              0              |             0               |

000317 00020:899415 7F82067FC700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0075    ======================================= STATISTICS ============================================
```

On the **OAI-eNB** virtual machine, the user must create a route in
order to access the `oai-public-net` container network on the **OAI-EPC**
virtual machine.

```bash
[vagrant@eNB ~]$ sudo ip route add to 192.168.61.192/26 via 10.20.0.132 
```

After adding this route, ensure that the eNB can ping the MME at IP address
`192.168.61.195`:

```bash
[vagrant@eNB build]$ ping 192.168.61.195
PING 192.168.61.195 (192.168.61.195) 56(84) bytes of data.
64 bytes from 192.168.61.195: icmp_seq=1 ttl=63 time=0.646 ms
64 bytes from 192.168.61.195: icmp_seq=2 ttl=63 time=0.448 ms
```

On the **OAI-eNB** virtual machine, the user must create a configuration
file for the `lte-softmodem` eNodeB simulator.  The user should copy and
modify the `lte-fdd-basic-sim.conf` configuration file in order to set
the proper IP addresses to connect to the EPC:

```bash
[vagrant@eNB ~]$ cd openairinterface5g/ci-scripts/conf_files/
[vagrant@eNB conf_files]$ cp lte-fdd-basic-sim.conf epc_basicsim.conf
```

The user must make the following changes to the `epc_basicsim.conf`
configuration file to specify the IP address for the MME and specify the
local IP address to be used for the S1 and S1U interfaces:

```bash
[vagrant@eNB conf_files]$ diff -w epc_basicsim.conf lte-fdd-basic-sim.conf 
174c174
<     mme_ip_address      = ( { ipv4       = "192.168.61.195";
---
>     mme_ip_address      = ( { ipv4       = "CI_MME_IP_ADDR";
193,196c193,197
<         ENB_INTERFACE_NAME_FOR_S1_MME            = "eth1";
<         ENB_IPV4_ADDRESS_FOR_S1_MME              = "10.20.0.131";
<         ENB_INTERFACE_NAME_FOR_S1U               = "eth1";
<         ENB_IPV4_ADDRESS_FOR_S1U                 = "10.20.0.131";
---
> 
>         ENB_INTERFACE_NAME_FOR_S1_MME            = "eth0";
>         ENB_IPV4_ADDRESS_FOR_S1_MME              = "CI_ENB_IP_ADDR";
>         ENB_INTERFACE_NAME_FOR_S1U               = "eth0";
>         ENB_IPV4_ADDRESS_FOR_S1U                 = "CI_ENB_IP_ADDR";
198c199
<         ENB_IPV4_ADDRESS_FOR_X2C                 = "10.20.0.131";
---
>         ENB_IPV4_ADDRESS_FOR_X2C                 = "CI_ENB_IP_ADDR";
```

After configuring the parameters for the eNodeB, the eNodeB simulator can be started as follows:

```bash
[vagrant@eNB build]$ cd /home/vagrant/openairinterface5g/cmake_targets/ran_build/build
[vagrant@eNB build]$ ENODEB=1 sudo -E ./lte-softmodem -O ../../../ci-scripts/conf_files/epc_basicsim.conf \
                     --basicsim --nas.NetworkPrefix "11.0"
```

Note that the parameter `--nas.NetworkPrefix "11.0"` is necessary in order
for the network interface `oaitun_enm1` created when `lte-softmodem` is
started will be created with a IP prefix of `11.0`.  Without this option,
the interface would be assigned a network address in the `10.0.0.0/24`
subnet which would conflict with the IP address used by Vagrant to connect
to the virtual machine.

If the eNodeB is attached successfully, the user will see the number of
connected eNBs increase in the MME log:

```bash
[vagrant@EPC openair-epc-fed]$ docker exec -it oai-mme tail -f mme_run.log
055550 69063:557752 7F2E8AFFD700 DEBUG SCTP   rc/sctp/sctp_primitives_server.c:0469    Client association changed: 0                                                                              
055551 69063:557919 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0101    ----------------------                                                                                     
055552 69063:557932 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0102    SCTP Status:                                                                                               
055553 69063:557949 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0103    assoc id .....: 3                                                                                          
055554 69063:557957 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0104    state ........: 4                                                                                          
055555 69063:557964 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0105    instrms ......: 2                                                                                          
055556 69063:557971 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0106    outstrms .....: 2                                                                                          
055557 69063:557977 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0108    fragmentation : 1452                                                                                       
055558 69063:557983 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0109    pending data .: 0                                                                                          
055559 69063:557989 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0110    unack data ...: 0                                                                                          
055560 69063:557996 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0111    rwnd .........: 106496                                                                                     
055561 69063:558010 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0112    peer info     :                                                                                            
055562 69063:558016 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0114        state ....: 2                                                                                          
055563 69063:558022 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0116        cwnd .....: 4380                                                                                       
055564 69063:558028 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0118        srtt .....: 0                                                                                          
055565 69063:558034 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0120        rto ......: 3000                                                                                       
055566 69063:558040 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0122        mtu ......: 1500                                                                                       
055567 69063:558046 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0123    ----------------------                                                                                     
055568 69063:558052 7F2E8AFFD700 DEBUG SCTP   rc/sctp/sctp_primitives_server.c:0479    New connection                                                                                             
055569 69063:558104 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0205    ----------------------                                                                                     
055570 69063:558120 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0206    Local addresses:                                                                                           
055571 69063:558144 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0217        - [192.168.61.195]                                                                                     
055572 69063:558151 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0234    ----------------------                                                                                     
055573 69063:558163 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0151    ----------------------                                                                                     
055574 69063:558169 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0152    Peer addresses:                                                                                            
055575 69063:558176 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0163        - [10.20.0.131]                                                                                        
055576 69063:558183 7F2E8AFFD700 DEBUG SCTP   enair-mme/src/sctp/sctp_common.c:0178    ----------------------                                                                                     
055577 69063:558217 7F2E8AFFD700 DEBUG SCTP   rc/sctp/sctp_primitives_server.c:0554    SCTP RETURNING!!                                                                                           
055578 69063:558281 7F2EFB7FE700 DEBUG S1AP   mme/src/s1ap/s1ap_mme_handlers.c:2826    Create eNB context for assoc_id: 3                                                                         
055579 69063:558817 7F2E8AFFD700 DEBUG SCTP   rc/sctp/sctp_primitives_server.c:0547    [3][48] Msg of length 59 received from port 36412, on stream 0, PPID 18                                    
055580 69063:558866 7F2E8AFFD700 DEBUG SCTP   rc/sctp/sctp_primitives_server.c:0554    SCTP RETURNING!!                                                                                           
055582 69063:558969 7F2EFB7FE700 DEBUG S1AP   mme/src/s1ap/s1ap_mme_handlers.c:0361    S1-Setup-Request macroENB_ID.size 3 (should be 20)                                                         
055581 69063:558963 7F2EFB7FE700 DEBUG S1AP   mme/src/s1ap/s1ap_mme_handlers.c:0321    New s1 setup request incoming from macro eNB id: 00e00                                                     
055583 69063:558993 7F2EFB7FE700 DEBUG S1AP   r-mme/src/s1ap/s1ap_mme_gummei.c:0076    Checking GUMMEI 0 PLMN MCC 2.0.8 MNC 9.3.15 vs MCC 2.0.8 MNC 9.3.15
055584 69063:559012 7F2EFB7FE700 DEBUG S1AP   mme/src/s1ap/s1ap_mme_handlers.c:0423    Adding eNB to the list of served eNBs                                                                      
055585 69063:559018 7F2EFB7FE700 DEBUG S1AP   mme/src/s1ap/s1ap_mme_handlers.c:0438    Adding eNB id 3584 to the list of served eNBs                                                              
055586 69063:559117 7F2F0133E700 DEBUG SCTP   rc/sctp/sctp_primitives_server.c:0283    [48][3] Sending buffer 0x28a6f90 of 27 bytes on stream 0 with ppid 18                                      
055587 69063:559257 7F2F0133E700 DEBUG SCTP   rc/sctp/sctp_primitives_server.c:0296    Successfully sent 27 bytes on stream 0                                                                     
055588 69070:874244 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0039    ======================================= STATISTICS ============================================            

055589 69070:874303 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0042                   |   Current Status| Added since last display|  Removed since last display |                 
055590 69070:874310 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0048    Connected eNBs |          1      |              1              |             0               |             
055591 69070:874324 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0054    Attached UEs   |          0      |              0              |             0               |             
055592 69070:874331 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0060    Connected UEs  |          0      |              0              |             0               |             
055593 69070:874337 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0066    Default Bearers|          0      |              0              |             0               |             
055594 69070:874342 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0072    S1-U Bearers   |          0      |              0              |             0               |             

055595 69070:874348 7F2EFAFFD700 DEBUG MME-AP src/mme_app/mme_app_statistics.c:0075    ======================================= STATISTICS ============================================  

```

# Connect the UE to the eNodeB and EPC

After the eNodeB has successfully connected to the EPC, the UE simulator
can then be started to connect to the eNodeB, then register itself in the
EPC network.

When using the OAI UE simulator, the UE parameters are specified in the
file `./openair3/NAS/TOOLS/ue_eurecom_test_sfr.conf`.  It is recommended
on the UE machine to copy this file to the build directory where the
`./lte-uesoftmodem` resides to make any modifications:

```bash
[vagrant@UE ~]$ cd /home/vagrant/openairinterface5g
[vagrant@UE openairinterface5g] cat ./openair3/NAS/TOOLS/ue_eurecom_test_sfr.conf

<PLMN info snipped>

UE0:
{
    USER: {
        IMEI="356113022094149";
        MANUFACTURER="EURECOM";
        MODEL="LTE Android PC";
        PIN="0000";
    };

    SIM: {
        MSIN="0100001111";
        USIM_API_K="8baf473f2f8fd09487cccbd7097c6862";
        OPC="e734f8734007d6c5ce7a0508809e7e9c";
        MSISDN="33611123456";
    };

    # Home PLMN Selector with Access Technology
    HPLMN= "20893";

    # User controlled PLMN Selector with Access Technology
    UCPLMN_LIST = ();

    # Operator PLMN List
    OPLMN_LIST = ("00101", "20810", "20811", "20813", "20893", "310280", "310028");

    # Operator controlled PLMN Selector with Access Technology
    OCPLMN_LIST = ("22210", "21401", "21406", "26202", "26204");

    # Forbidden plmns
    FPLMN_LIST = ();

    # List of Equivalent HPLMNs
#TODO: UE does not connect if set, to be fixed in the UE
#    EHPLMN_LIST= ("20811", "20813");
    EHPLMN_LIST= ();
};
```

The default UE configuration file does not have the correct values for the
`MSIN` and `OPC`.  The `OPC` value is tricky, because it's value is derived
from the `USIM_API_K` and `OP` values provided in the EPC configuration.
It is not specified directly in the EPC configuration files.  Therefore
the HSS must be started and the logs examined in order to find the `OPC`
value to be programmed into the UE.

With the default EPC `USIM_API_K` value of `8BAF473F2F8FD09487CCCBD7097C6862`
and `OP` value of `11111111111111111111111111111111` specified in
`./scripts/docker_params.sh`, the resulting `OPC` value to be used by the
UE is `8E27B6AF0E692E750F32667A3B14605D`.

This can be seen in the log file `hss_run.log` after starting the EPC and
retreiving the logs with the `docker_control.sh logs` command:

```bash
[vagrant@EPC ~]$ # Collect the logs from the running EPC...
[vagrant@EPC openair-epc-fed]$ ./scripts/docker_control.sh logs
[vagrant@EPC openair-epc-fed]$ vi archives/hss_run.log

<search for 208930000000001>

[2020-12-30T21:39:01.712] [hss] [system] [info] COUNT: 144 IMSI: 208930000000001 KEY: 8baf473f2f8fd09487cccbd7097c6862 OPC: 8e27b6af0e692e750f32667a3b14605d NEW OPC: 8e27b6af0e692e750f32667a3b14605d
RijndaelKeySchedule: K 8BAF473F2F8FD09487CCCBD7097C6862
Compute opc:
        K:      8BAF473F2F8FD09487CCCBD7097C6862
        In:     11111111111111111111111111111111
        Rinj:   9F36A7BE1F783F641E23776B2A05714C
        Out:    8E27B6AF0E692E750F32667A3B14605D
```

In order to configure the UE, copy this default UE configuration file and
make the requisite changes to match the EPC configuration.

* The MCC/MNC (PLMN) (default 208/93 (20893)) value in the EPC must match
one of the PLMN values in the UE configuration file.  The default UE
configuration file already has an entry for for PLMN 20893, so this does
not need to be modified.

* The `MSIN` (default 000000001) value in the EPC must match exactly the
`MSIN` value in the UE.  This must be modified in the UE configuration file.

* The `USIM_API_K` (default="8baf473f2f8fd09487cccbd7097c6862") in the
EPC must match exactly the `USIM_API_K` value in the UE.  The default UE
configuration file already has this set.

* The `OPC` value in the UE must be set to the output generated by
the HSS from the `USIM_API_K` and `OP` as described above.  With the
default values the resulting `OPC` value should be changed to
"8E27B6AF0E692E750F32667A3B14605D".

Here are the changes that must be made to the UE configuration file if
the default EPC values are used:

```bash
    SIM: {
        MSIN="0100001111"; <== Change to "0000000001";
        USIM_API_K="8baf473f2f8fd09487cccbd7097c6862";
        OPC="e734f8734007d6c5ce7a0508809e7e9c";  <== Change to "8E27B6AF0E692E750F32667A3B14605D"
        MSISDN="33611123456";
    };
```

Here is the resulting UE configuration file:

```bash
[vagrant@UE ~]$ cd /home/vagrant/openairinterface5g
[vagrant@UE ~]$ cp ./openair3/NAS/TOOLS/ue_eurecom_test_sfr.conf cmake_targets/ran_build/build/ue.conf
[vagrant@UE ~]$ cd cmake_targets/ran_build/build
[vagrant@UE ~]$ cat ue.conf
# List of known PLMNS
PLMN: {
    PLMN0: {
           FULLNAME="Test network";
           SHORTNAME="OAI4G";
           MNC="01";
           MCC="001";

    };
    PLMN1: {
           FULLNAME="SFR France";
           SHORTNAME="SFR";
           MNC="10";
           MCC="208";

    };
    PLMN2: {
           FULLNAME="SFR France";
           SHORTNAME="SFR";
           MNC="11";
           MCC="208";
    };
    PLMN3: {
           FULLNAME="SFR France";
           SHORTNAME="SFR";
           MNC="13";
           MCC="208";
    };
    PLMN4: {
           FULLNAME="OAI LTEBOX";
           SHORTNAME="OAIALU";
           MNC="93";
           MCC="208";
    };
    PLMN5: {
           FULLNAME="T-Mobile USA";
           SHORTNAME="T-Mobile";
           MNC="280";
           MCC="310";
    };
    PLMN6: {
           FULLNAME="FICTITIOUS USA";
           SHORTNAME="FICTITIO";
           MNC="028";
           MCC="310";
    };
    PLMN7: {
           FULLNAME="Vodafone Italia";
           SHORTNAME="VODAFONE";
           MNC="10";
           MCC="222";
    };
    PLMN8: {
           FULLNAME="Vodafone Spain";
           SHORTNAME="VODAFONE";
           MNC="01";
           MCC="214";
    };
    PLMN9: {
           FULLNAME="Vodafone Spain";
           SHORTNAME="VODAFONE";
           MNC="06";
           MCC="214";
    };
    PLMN10: {
           FULLNAME="Vodafone Germ";
           SHORTNAME="VODAFONE";
           MNC="02";
           MCC="262";
    };
    PLMN11: {
           FULLNAME="Vodafone Germ";
           SHORTNAME="VODAFONE";
           MNC="04";
           MCC="262";
    };
};

UE0:
{
    USER: {
        IMEI="356113022094149";
        MANUFACTURER="EURECOM";
        MODEL="LTE Android PC";
        PIN="0000";
    };

    SIM: {
        MSIN="0000000001";
        USIM_API_K="8baf473f2f8fd09487cccbd7097c6862";
        OPC="8e27b6af0e692e750f32667a3b14605d";
        MSISDN="33611123456";
    };

    # Home PLMN Selector with Access Technology
    HPLMN= "20893";

    # User controlled PLMN Selector with Access Technology
    UCPLMN_LIST = ();

    # Operator PLMN List
    OPLMN_LIST = ("00101", "20810", "20811", "20813", "20893", "310280", "310028");

    # Operator controlled PLMN Selector with Access Technology
    OCPLMN_LIST = ("22210", "21401", "21406", "26202", "26204");

    # Forbidden plmns
    FPLMN_LIST = ();

    # List of Equivalent HPLMNs
#TODO: UE does not connect if set, to be fixed in the UE
#    EHPLMN_LIST= ("20811", "20813");
    EHPLMN_LIST= ();
};
```

After modifying the UE configuration file, the UE "SIM" must be reprogrammed
using the `conf2uedata` program:

```bash
[vagrant@UE build] ../../nas_sim_tools/build/conf2uedata -c ue.conf -o .

UE's non-volatile data:

IMEI            = 356113022094149
manufacturer    = EURECOM
model           = LTE Android PC
PIN             = 0000
UE identity data file: ./.ue.nvram0

EMM non-volatile data:

IMSI            = 208.930.000000001
RPLMN           = 20893
EPS Mobility Management data file: ./.ue_emm.nvram0

USIM data:

Administrative Data:
        UE_Operation_Mode       = 0x00
        Additional_Info         = 0xffff
        MNC_Length              = 2

IMSI:
        length  = 8
        parity  = Odd
        digits  = 15
        digits  = 208930000000001

Ciphering and Integrity Keys:
        KSI     : 0x07
        CK      : ""
        IK      : ""

        usim_api_k: 8b af 47 3f 2f 8f d0 94 87 cc cb d7 09 7c 68 62
        opc       : 8e 27 b6 af 0e 69 2e 75 0f 32 66 7a 3b 14 60 5d

EPS NAS security context:
        KSIasme : 0x07
        Kasme   : ""
        ulNAScount      : 0x00000000
        dlNAScount      : 0x00000000
        algorithmID     : 0x02

MSISDN  = 336 1112 3456

PNN[0]  = {Test network, OAI4G}
PNN[1]  = {SFR France, SFR}
PNN[2]  = {SFR France, SFR}
PNN[3]  = {SFR France, SFR}
PNN[4]  = {OAI LTEBOX, OAIALU}
PNN[5]  = {T-Mobile USA, T-MobileCFICTITIOUS USA}
PNN[6]  = {FICTITIOUS USA, FICTITIO}
PNN[7]  = {, }

OPL[0]  = 00101, TAC = [0001 - fffd], record_id = 0
OPL[1]  = 20810, TAC = [0001 - fffd], record_id = 1
OPL[2]  = 20811, TAC = [0001 - fffd], record_id = 2
OPL[3]  = 20813, TAC = [0001 - fffd], record_id = 3
OPL[4]  = 20893, TAC = [0001 - fffd], record_id = 4
OPL[5]  = 310280, TAC = [0001 - fffd], record_id = 5
OPL[6]  = 310028, TAC = [0001 - fffd], record_id = 6
OPL[7]  = , TAC = [0000 - 0000], record_id = 0

HPLMN           = 20893, AcT = 0x80c0

FPLMN[0]        = 
FPLMN[1]        = 
FPLMN[2]        = 
FPLMN[3]        = 

EHPLMN[0]       = 
EHPLMN[1]       = 

PLMN[0]         = , AcTPLMN = 0x0
PLMN[1]         = , AcTPLMN = 0x0
PLMN[2]         = , AcTPLMN = 0x0
PLMN[3]         = , AcTPLMN = 0x0
PLMN[4]         = , AcTPLMN = 0x0
PLMN[5]         = , AcTPLMN = 0x0
PLMN[6]         = , AcTPLMN = 0x0
PLMN[7]         = , AcTPLMN = 0x0

OPLMN[0]        = 22210, AcTPLMN = 0x80c0
OPLMN[1]        = 21401, AcTPLMN = 0x80c0
OPLMN[2]        = 21406, AcTPLMN = 0x80c0
OPLMN[3]        = 26202, AcTPLMN = 0x80c0
OPLMN[4]        = 26204, AcTPLMN = 0x80c0
OPLMN[5]        = , AcTPLMN = 0x0
OPLMN[6]        = , AcTPLMN = 0x0
OPLMN[7]        = , AcTPLMN = 0x0

HPPLMN          = 0x00 (0 minutes)

LOCI:
        TMSI = 0x000d
        LAI     : PLMN = 20893, LAC = 0xfffe
        status  = 1

PSLOCI:
        P-TMSI = 0x000d
        signature = 0x1 0x2 0x3
        RAI     : PLMN = 20893, LAC = 0xfffe, RAC = 0x1
        status  = 1

EPSLOCI:
        GUTI    : GUMMEI        : (PLMN = 20893, MMEgid = 0x102, MMEcode = 0xf), M-TMSI = 0x000d
        TAI     : PLMN = 20893, TAC = 0x01
        status  = 0

NASCONFIG:
        NAS_SignallingPriority          : 0x00
        NMO_I_Behaviour                 : 0x00
        AttachWithImsi                  : 0x01
        MinimumPeriodicSearchTimer      : 0x00
        ExtendedAccessBarring           : 0x00
        Timer_T3245_Behaviour           : 0x00
USIM data file: ./.usim.nvram0
```

This command creates three dotfiles `.ue_emm.nvram0`, `.ue.nvram0`, and
`.usim.nvram0`.  These files *must* reside in the same directory as the
`lte-uesoftmodem` binary.

After creating the NVRAM dotfiles, the UE simulator `lte-uesoftmodem`
can be started as follows:

```bash
[vagrant@UE build]$ TCPBRIDGE=10.20.0.131 sudo -E ./lte-uesoftmodem -C 2680000000 -r 25 \
                    --ue-rxgain 140 --basicsim --nas.NetworkPrefix "11.0" 2>&1 |tee ue.log
```

The `TCPBRIDGE=<eNB IP address>` environment variable specifies the IP
address to use to connect to the `tcp_bridge_oai` listener port on the
eNodeB.  This must be set to the IP address of the eNodeB.

The `-r <num DL RB>` specifies the number of downlink radio bearers.

This value must match the value specified in the eNB configuration file by
the parameter `N_RB_DL`.  In the `epc_basicsim.conf` eNodeB configuration
files the default value is 25.

The `-C <DL freq> ` specifies the downlink frequency.

This value must match the `downlink_frequency` in the eNB
configuration file.  If `lte-fdd-basic-sim.conf` is used on the eNB
side, the default value is 2680000000. If `lte-tdd-basic-sim.conf`
is used on the eNB side, the default value is 2350000000.

The `--nas.NetworkPrefix <IP prefix>` flag configures the IP address
prefix for the `oaitun_uem1` virtual IP interface which
are created when `lte-uesoftmodem` is run.  The default value is `"10.0"`,
which causes the `oaitun_uem1` interface to be assigned the IP address
`10.0.2.2/24`.  Only the first two bytes of the IP network prefix can be
specified as a quoted string.

In virtual machines created with Vagrant the IP interface used to access
the virtual machine is already using the `10.0.0.0/24` subnet, so we must
specify a different IP prefix for the eNB and UE IP interfaces.  We specify
`"11.0"` which causes the `oaitun_uem1` interface to be assigned the IP
address `11.0.2.2/24`.

After the UE has successfully connected to the eNodeB and successfully
registred itself in the network, the UE virtual IP interface `oaitun_ue1`
will be assigned an IP address automatically by the EPC in the `12.0.0.0/24`
network.  This can be checked with the `ip addr` command:

```bash
[vagrant@UE ~]$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 56218sec preferred_lft 56218sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:eb:97:75 brd ff:ff:ff:ff:ff:ff
    inet 10.20.0.130/24 brd 10.20.0.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feeb:9775/64 scope link 
       valid_lft forever preferred_lft forever
85: oaitun_ue1: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none 
    inet 12.0.0.2/8 brd 12.255.255.255 scope global oaitun_ue1
       valid_lft forever preferred_lft forever
    inet6 fe80::303d:3ad4:1fba:3072/64 scope link flags 800 
       valid_lft forever preferred_lft forever
86: oaitun_uem1: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none 
    inet 11.0.2.2/24 brd 10.0.255.255 scope global oaitun_uem1
       valid_lft forever preferred_lft forever
    inet6 fe80::fac6:84ad:7d7d:b5ac/64 scope link flags 800 
       valid_lft forever preferred_lft forever
```

# Testing UE connectivity

After the UE has successfully connected to the eNodeB and successfully
registred itself in the network, the UE virtual IP interface `oaitun_ue1`
will be assigned an IP address automatically by the EPC in the `12.0.0.0/24`
network.  By default the `docker_control` EPC-in-a-box script will
configure the SPGW-U to enable NAT for connected UEs.  This means that if
the container host virtual machine **OAI-EPC** has connectivity to the
internet (which we assume that it does, as this is required in order to
build the containers in the first place), then the UE will also be able
to connect to the Internet via the SGPW-U in the EPC.

In order to test connecting to the internet via the EPC in the UE, the user
must change the default route in the **OAI-UE** virtual machine to use the
`oaitun_ue1` interface so that packets will be routed via the EPC rather
than just using the normal Ethernet interface:

```bash
[vagrant@UE ~]$ sudo ip route add default  dev oaitun_ue1
[vagrant@UE ~]$ ip route
default dev oaitun_ue1 scope link 
default via 10.0.2.2 dev eth0 proto dhcp metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
10.20.0.0/24 dev eth1 proto kernel scope link src 10.20.0.130 metric 101 
11.0.2.0/24 dev oaitun_uem1 proto kernel scope link src 11.0.2.2 
12.0.0.0/8 dev oaitun_ue1 proto kernel scope link src 12.0.0.2 
```

After the default route is chan ged to use the `oaitun_ue1` interface,
the user can connect to the internet using any normal tool such as `ping`:

```bash
[vagrant@UE ~]$ ping www.google.com
PING www.google.com (172.217.162.196) 56(84) bytes of data.
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=1 ttl=60 time=24.6 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=2 ttl=60 time=53.1 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=3 ttl=60 time=78.9 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=4 ttl=60 time=231 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=5 ttl=60 time=52.8 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=6 ttl=60 time=84.0 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=7 ttl=60 time=88.4 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=8 ttl=60 time=46.4 ms
64 bytes from gru14s20-in-f4.1e100.net (172.217.162.196): icmp_seq=9 ttl=60 time=41.7 ms
```

Note that the latency will be much greater than normal since packets have
to traverse the "radio" interface which is simulated between the UE and
eNodeB, then passed to the SPGW-U, NAT translated, then transmitted.

That's it!  You have successfully simulated a UE connecting to the internet
via a simulated 4G network!

# Log and PCAP files.

The user can retrieve the log files and the wireshark pcap files which
are generated on all the EPC network elements using the `docker_control`
script on the **OAI-EPC** virtual machine.

The `docker_control.sh logs` command will copy all of the log files into the
`$TOP_DIR/archives` directory.

```bash
[vagrant@EPC openair-epc-fed]$ ./scripts/docker_control.sh logs
[vagrant@EPC openair-epc-fed]$ ls -lt archives/
total 768
-rw-r--r--. 1 vagrant vagrant  50776 Jan  5 19:48 spgwu-tiny_run.log
-rw-r--r--. 1 vagrant vagrant  36919 Jan  5 19:48 spgwc_run.log
-rw-r--r--. 1 vagrant vagrant 269782 Jan  5 19:48 mme_run.log
-rw-r--r--. 1 vagrant vagrant 100236 Jan  5 19:42 hss_run.log
drwxrwxr-x. 2 vagrant vagrant     25 Jan  5 19:42 spgwu-tiny-cfg
drwxrwxr-x. 2 vagrant vagrant     25 Jan  5 19:42 spgwc-cfg
drwxrwxr-x. 2 vagrant vagrant    123 Jan  5 19:42 mme-cfg
drwxrwxr-x. 2 vagrant vagrant    164 Jan  5 19:42 hss-cfg
-rw-r--r--. 1 vagrant vagrant     20 Jan  5 19:42 spgwu-tiny_deploy.log
-rw-r--r--. 1 vagrant vagrant   1723 Jan  5 19:42 mme_deploy.log
-rw-r--r--. 1 vagrant vagrant      0 Jan  5 19:42 spgwc_deploy.log
-rw-r--r--. 1 vagrant vagrant 309725 Jan  5 19:42 hss_deploy.log
```

The user can optionally specify only the EPC network element to retrieve
only the logs for that element:

```bash
[vagrant@EPC openair-epc-fed]$ ./scripts/docker_control.sh 
./scripts/docker_control.sh [start | stop | build | logs | configs | pcap]
start [ cassandra | hss | mme | spgwc | spgwu-tiny ]
   Deploy and run selected EPC network elements (default=all)

stop [ cassandra | hss | mme | spgwc | spgwu-tiny ] (default=all)
   Stop selected EPC network element (default=all)

build [ cassandra | hss | mme | spgwc | spgwu-tiny ]
   Build Docker image for selected network elements (default=all)

logs [ hss | mme | spgwc | spgwu-tiny ]
   Retrieve and show deployment and runtime log 
   from selected element (default=all)

configs [ hss | mme | spgwc | spgwu-tiny ] (default=all)
   Retrieve and show configuration files 
   from selected element (default=all)

pcap [ hss | mme | spgwc | spgwu-tiny ] (default=all)
   Retrieve and show wireshark pcap files 
   from selected element (default=all)
```

The `docker_control.sh pcap` command will copy all of the pcap files into the
`$TOP_DIR/archives` directory.

```bash
[vagrant@EPC openair-epc-fed]$ ./scripts/docker_control.sh pcap
Getting hss pcap file
=================
Getting mme pcap file
=================
Getting spgwc pcap file
=================
Getting spgwu-tiny pcap file
=================
[vagrant@EPC openair-epc-fed]$ ls -lt archives/
total 1032
-rw-r--r--. 1 vagrant vagrant  28672 Jan  5 19:50 mme.pcap
-rw-r--r--. 1 vagrant vagrant  42316 Jan  5 19:50 spgwc_run.log
-rw-r--r--. 1 vagrant vagrant  28672 Jan  5 19:50 spgwc.pcap
-rw-r--r--. 1 vagrant vagrant  59896 Jan  5 19:50 spgwu-tiny_run.log
-rw-r--r--. 1 vagrant vagrant  32768 Jan  5 19:50 spgwu-tiny.pcap
-rw-r--r--. 1 vagrant vagrant 167936 Jan  5 19:49 hss.pcap
-rw-r--r--. 1 vagrant vagrant 269782 Jan  5 19:48 mme_run.log
-rw-r--r--. 1 vagrant vagrant 100236 Jan  5 19:42 hss_run.log
drwxrwxr-x. 2 vagrant vagrant     25 Jan  5 19:42 spgwu-tiny-cfg
drwxrwxr-x. 2 vagrant vagrant     25 Jan  5 19:42 spgwc-cfg
drwxrwxr-x. 2 vagrant vagrant    123 Jan  5 19:42 mme-cfg
drwxrwxr-x. 2 vagrant vagrant    164 Jan  5 19:42 hss-cfg
-rw-r--r--. 1 vagrant vagrant     20 Jan  5 19:42 spgwu-tiny_deploy.log
-rw-r--r--. 1 vagrant vagrant   1723 Jan  5 19:42 mme_deploy.log
-rw-r--r--. 1 vagrant vagrant      0 Jan  5 19:42 spgwc_deploy.log
-rw-r--r--. 1 vagrant vagrant 309725 Jan  5 19:42 hss_deploy.log
```

These pcap files can then be examined with `tcpdump` or `wireshark` to
see the decoded packet captures.

# Stopping the EPC

The EPC network elements can be stopped using the command `docker_control.sh
stop`:

```bash
[vagrant@EPC openair-epc-fed]$ ./scripts/docker_control.sh stop
Stopping oai-cassandra...
oai-cassandra
Stopping oai-hss...
oai-hss
Stopping oai-mme...
oai-mme
Stopping oai-spgwc...
oai-spgwc
Stopping oai-spgwu-tiny...
oai-spgwu-tiny
```
