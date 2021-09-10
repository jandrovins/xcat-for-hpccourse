# rmdef -t node compute-1-9
h1="compute-1-28"
b1="10.150.4.180"
m1="2c:41:38:eb:d5:7c"
g="cios_hpccourse"
z="cios_hpccourse_zone"
ip="10.150.7.111"
# Show free ip nodes
# lsdef -i ip | grep 10.* | sort

# Change zone
# chzone cios_hpccourse_zone3 -a cios_hpccourse_cluster3 -g

function main(){
    if [ "$#" -ne 1 ]; then
        echo "ERROR: Illegal number of parameters"
        echo "Usage ./script <arg>"
        exit
    fi

    if [ "$1" = "def" ]
    then
        createDefs
    elif [ "$1" = "install" ]
    then
        installNodes
    elif [ "$1" = "boot" ]
    then
       bootHD
    elif [ "$1" = "delete" ]
    then
       deleteDefs
    elif [ "$1" = "testconnection" ]
    then
       testConnection
   else
       echo "ERROR: No valid parameter found"
    fi
}

function createDefs(){
    echo "Creating defs"
    mkdef -f -t node "$h1" arch=x86_64 mgt=ipmi netboot=xnba \
        groups="all,cios_hpccourse,$g" ip="$ip" mac="$m1" \
        bmc="$b1" bmcusername=root bmcpassword='18$Ue$Ilo@'

    chdef -p -t node -o $h1 groups="all,$g"
    chzone $z -a $g -g

    makehosts
    makedns -n
    makedhcp -n
}

function installNodes(){
    echo "Installing node"
    nodeset $h1 osimage=centos8-x86_64-install-compute
    rinstall $h1
}

function bootHD(){
    echo "Setting node boot to HD"
    rsetboot $h1 hd
    sleep 1
    rpower $h1 boot
    sleep 20
    rsetboot $h1 hd
}

main $@
