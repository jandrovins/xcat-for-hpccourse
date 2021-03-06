#!/bin/bash

hostnames=('compute-1-1'        'compute-1-2'          'compute-1-5'        'compute-1-8'        'compute-1-11'        'compute-1-12'        'compute-1-13'        'compute-1-16'        'compute-1-27'        'compute-1-28'        'compute-1-31'        'compute-1-32'        'compute-1-33'        'lab-2'               'lab-3'     )
macs=(     '2c:41:38:eb:db:90'   '2c:41:38:eb:db:68'   '2c:41:38:eb:d6:58'  '2c:41:38:eb:d8:58'  '2c:41:38:eb:d5:54'   '2c:41:38:eb:d3:c4'   '2c:41:38:eb:da:a0'   '2c:41:38:eb:db:7c'   '2c:41:38:eb:da:24'   '2c:41:38:eb:d5:7c'   '2c:41:38:eb:d1:f4'   '2c:41:38:eb:d5:88'   '2c:41:38:eb:d1:61'   '2c:41:38:eb:d3:b4'   '2c:41:38:eb:da:3c' )
bmcs=(      10.150.4.153         10.150.4.154          10.150.4.157         10.150.4.160         10.150.4.163          10.150.4.164          10.150.4.165          10.150.4.168          10.150.4.179          10.150.4.180          10.150.4.183          10.150.4.184          10.150.4.185          10.150.4.188          10.150.4.189       )
ips=(       10.150.7.100         10.150.7.101          10.150.7.102         10.150.7.104         10.150.7.103          10.150.7.106          10.150.7.107          10.150.7.109          10.150.7.110          10.150.7.111          10.150.7.113          10.150.7.184          10.150.7.185          10.150.7.188          10.150.7.189)

num_teams=5
nodes_per_team=3
allg=cios_hpccourse # common group for all nodes
mv3g=cios_hpccourse_mv3 # without compute-1-34 which is NFS server on MV3

function main(){
    if [ "$#" -ne 1 ]; then
        echo "ERROR: Illegal number of parameters"
        echo "Usage ./script <arg>"
        exit
    fi

    if [ $1 = "def" ]
    then
        createDefs
    elif [ $1 = "install" ]
    then
        installNodes
    elif [ $1 = "boot" ]
    then
       bootHD 
    elif [ $1 = "delete" ]
    then
       deleteDefs 
    elif [ $1 = "testconnection" ]
    then
       testconnection 
   else
       echo "ERROR: No valid parameter found"
    fi
}
function createDefs(){
    echo "Creating defs"
    mkdef -t group -o $allg
    mkdef -t group -o $mv3g
    info_it=0 # array's iterator
    for ((t=1;t<=$num_teams;t++ )); do 
        g=cios_hpccourse_cluster${t}
        z=cios_hpccourse_zone${t}
        ## FIRST CREATE GROUP
        rmdef -t group $g
        rmdef -t zone $z
        mkdef -t group -o $g
        for((n=1;n<=$nodes_per_team;n++)); do
            h="${hostnames[$info_it]}"
            ip="${ips[$info_it]}"
            bmc="${bmcs[$info_it]}"
            mac="${macs[$info_it]}"

            ## CREATE DEFINITION FOR FIRST MACHINE
            mkdef -f -t node "$h" arch=x86_64 mgt=ipmi netboot=xnba \
            groups=all,$g,$allg,$mv3g ip="$ip" mac="$mac" \
            bmc="$bmc" bmcusername=root bmcpassword='18$Ue$Ilo@'

            info_it=$((info_it+1))
        done
        mkzone $z -a $g -g # to be executed after nodes are created in group $g
    done
    makehosts
    makedns -n
    makedhcp -n
}
function deleteDefs(){
    echo "Deleting defs"
    info_it=0 # array's iterator
    for ((t=1;t<=$num_teams;t++ )); do 
        g=cios_hpccourse_cluster${t}
        z=cios_hpccourse_zone${t}
        for((n=1;n<=$nodes_per_team;n++)); do
            h="${hostnames[$info_it]}"

            rmdef -t node $h
            info_it=$((info_it+1))
        done
        rmdef -t group $g
        rmdef -t zone $z
    done

    rmdef -t group -o $allg
    rmdef -t group -o $mv3g

    makehosts
    makedns -n
    makedhcp -n
}

function installNodes() {
    echo "Launching nodes installation "
    nodeset $mv3g osimage=centos8-x86_64-install-compute
    rinstall $mv3g
}

function bootHD() {
    echo "Setting boot hd"
    rsetboot $mv3g hd
    rpower $mv3g boot
    rsetboot $mv3g hd
}

function testConnection() {
    echo "Testing ssh to each node"
    for i in "${hostnames[@]}"; do
        xdsh $i hostname
    done
}

main $@
