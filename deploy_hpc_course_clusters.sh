#!/bin/bash

hostnames=('compute-1-30'        'compute-1-31'     )
macs=(     '9c:b6:54:78:01:24'   '2c:41:38:eb:d1:f4')
bmcs=(      10.150.4.182         10.150.4.183       )
ips=(       10.150.7.112         10.150.7.113       )


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
       testConnection 
   else
       echo "ERROR: No valid parameter found"
    fi
}
function createDefs(){
    echo "Creating defs"
    allg=cios_hpccourse
    mkdef -t group -o $allg
    counter=0
    for i in 1 2 3 4 5;do # 5 clusters
        i1=$counter
        i2=$((counter+1))

        h1="${hostnames[$i1]}"
        b1="${bmcs[$i1]}"
        m1="${macs[$i1]}"

        h2="${hostnames[$i2]}"
        b2="${bmcs[$i2]}"
        m2="${macs[$i2]}"

        g=cios_hpccourse_cluster${i}
        z=cios_hpccourse_zone${i}

        ## FIRST CREATE GROUP
        mkdef -t group -o $g

        ## CREATE DEFINITION FOR FIRST MACHINE
        mkdef -f -t node "$h1" arch=x86_64 mgt=ipmi netboot=xnba \
        groups=all,$g ip="10.150.7.1$(printf "%02d" $i1)" mac="$m1" \
        bmc="$b1" bmcusername=root bmcpassword='18$Ue$Ilo@'

        ## CREATE DEFINITION FOR SECOND MACHINE
        mkdef -f -t node "$h2" arch=x86_64 mgt=ipmi netboot=xnba \
        groups=all,$g ip="10.150.7.1$(printf "%02d" $i2)" mac="$m2" \
        bmc="$b2" bmcusername=root bmcpassword='18$Ue$Ilo@'

        chdef -p -t node -o $h1 groups="$allg"
        chdef -p -t node -o $h2 groups="$allg"

        mkzone $z -a $g -g


        counter=$((counter+2))
    done
    makehosts
    makedns -n
    makedhcp -n
}
function deleteDefs(){
    echo "Deleting defs"
    allg=cios_hpccourse
    rmdef -t group -o $allg
    counter=0
    for i in 1 2 3 4 5;do # 5 clusters
        i1=$counter
        i2=$((counter+1))

        h1="${hostnames[$i1]}"
        h2="${hostnames[$i2]}"
        g=cios_hpccourse_cluster${i}
        z=cios_hpccourse_zone${i}

        rmdef -t group $g
        rmdef -t node $h1
        rmdef -t node $h2
        rmdef -t zone $z

        counter=$((counter+2))
    done
    makehosts
    makedns -n
    makedhcp -n
}

function installNodes() {
    echo "Installing nodes"
    for i in 1 2 3 4 5; do # 5 clusters
        g=cios_hpccourse_cluster${i}
        ## SET OS TO CENTOS 8
        nodeset $g osimage=centos8-x86_64-install-compute
        rinstall $g
    done
}

function bootHD() {
    echo "Setting boot hd"
    for i in 1 2 3 4 5; do # 5 clusters
        g=cios_hpccourse_cluster${i}
        rsetboot $g hd
        sleep 1
        rpower $g boot
        sleep 20
        rsetboot $g hd
    done
}

function testConnection() {
    echo "Testing connection to each node"
    for i in "${hostnames[@]}"; do
        xdsh $i hostname
    done
}

main $@
