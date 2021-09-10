#!/bin/bash

#hostnames=('compute-1-23'        'compute-1-33'     'compute-1-34'      'lab-2'      'lab-3'  )
#macs=(     '2c:41:38:eb:da:f0'   '2c:41:38:eb:d1:60'   '2c:41:38:eb:da:30'   '2c:41:38:eb:d3:b4'   '2c:41:38:eb:da:3c')
#bmcs=(      10.150.4.175         10.150.4.185   10.150.4.186  10.150.4.188  10.150.4.189)
#ips=(      10.150.7.175         10.150.7.185   10.150.7.186  10.150.7.188  10.150.7.189)

hostnames=( compute-1-38        compute-1-32  )
macs=(      "5c:b9:01:8b:33:58" "2c:41:38:eb:d5:88")
bmcs=(      10.150.4.190        10.150.4.184)
ips=(       10.150.7.190        10.150.7.184)

g="cios_hpccourse"
z="cios_hpccourse_zone"


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
    #elif [ $1 = "delete" ]
    #then
    #   deleteDefs 
    #elif [ $1 = "testconnection" ]
    #then
       #testConnection 
   else
       echo "ERROR: No valid parameter found"
    fi
}
function createDefs(){
    echo "Creating defs"
    counter=0
    for i in 0 1 2 3 4;do # 5 computes
        i1=$counter

        h1="${hostnames[$i1]}"
        b1="${bmcs[$i1]}"
        m1="${macs[$i1]}"
        ip1="${ips[$i1]}"

        ## CREATE DEFINITION FOR FIRST MACHINE
        #echo $(printf "%02d" $b1)
         mkdef -f -t node "$h1" arch=x86_64 mgt=ipmi netboot=xnba \
        groups=all,$g ip="$ip1" mac="$m1" \
        bmc="$b1" bmcusername=root bmcpassword='18$Ue$Ilo@'

         chdef -p -t node -o $h1 groups="all,$g"
         chzone $z -a $g -g

        counter=$counter+1

    done
    makehosts
    makedns -n
    makedhcp -n
}
function deleteDefs(){
    echo "Deleting defs"
    counter=0
    for i in 0 1 2 3 4;do # 5 computes
        i1=$counter

        h1="${hostnames[$i1]}"
        z=cios_hpccourse_zone${i}

        rmdef -t node $h1

        counter=$counter+1
    done
    makehosts
    makedns -n
    makedhcp -n
}

function installNodes() {
    echo "Installing nodes"
    for i in "${computes[@]}"; do # 5 computes
        compute=${hostnames[$i]}
        ## SET OS TO CENTOS 8
        nodeset $compute osimage=centos8-x86_64-install-compute
        rinstall $compute
    done
}

function bootHD() {
    echo "Setting boot hd"
    for i in 0 1 2 3 4; do # 5 compute
        compute=${hostnames[$i]}
        rsetboot $compute hd
        sleep 1
        rpower $compute boot
        sleep 20
        rsetboot $compute hd
    done
}

function testConnection() {
    echo "Testing connection to each node"
    for i in "${hostnames[@]}"; do
        xdsh $i hostname
    done
}

main $@
