#!/bin/bash

# THIS FILE HOLDS THE VARIABLES NEEDED TO INSTALL THE CLUSTER NODES OF THE HPC COURSEA

hostnames=('compute-1-30'        'compute-1-31'     )
macs=(     '9c:b6:54:78:01:24'   '2c:41:38:eb:d1:f4')
bmcs=(      10.150.4.182         10.150.4.183       )
ips=(       10.150.7.112         10.150.7.113       )
clusters=(6)


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
        echo boot no implemented
       #bootHD
    elif [ $1 = "delete" ]
    then
        echo delete no implemented
       #deleteDefs
    elif [ $1 = "testconnection" ]
    then
        echo testconnection no implemented
       #testConnection
   else
       echo "ERROR: No valid parameter found"
    fi
}

function installNodes() {
    echo "Installing nodes"
    for i in "${clusters[@]}";do # 5 clusters
        g=cios_hpccourse_cluster${i}
        echo "INSTALLING NODES FROM GROUP $g"
        ## SET OS TO CENTOS 8
        nodeset $g osimage=centos8-x86_64-install-compute
        rinstall $g
    done
}


function createDefs(){
    echo "Creating defs"
    allg=cios_hpccourse
    #mkdef -t group -o $allg
    counter=0
    for i in "${clusters[@]}";do # 5 clusters
        echo $i
        i1=$counter
        i2=$((counter+1))

        h1="${hostnames[$i1]}"
        b1="${bmcs[$i1]}"
        m1="${macs[$i1]}"
        ip1="${ips[$i1]}"

        h2="${hostnames[$i2]}"
        b2="${bmcs[$i2]}"
        m2="${macs[$i2]}"
        ip2="${ips[$i2]}"

        g=cios_hpccourse_cluster${i}
        z=cios_hpccourse_zone${i}

        ## FIRST CREATE GROUP
        mkdef -t group -o $g

        ## CREATE DEFINITION FOR FIRST MACHINE
        mkdef -f -t node "$h1" arch=x86_64 mgt=ipmi netboot=xnba \
        groups=all,$g ip="$ip1" mac="$m1" \
        bmc="$b1" bmcusername=root bmcpassword='18$Ue$Ilo@'

        ## CREATE DEFINITION FOR SECOND MACHINE
        mkdef -f -t node "$h2" arch=x86_64 mgt=ipmi netboot=xnba \
        groups=all,$g ip="$ip2" mac="$m2" \
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

main $@
