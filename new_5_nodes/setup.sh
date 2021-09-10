#!/bin/bash

# ONLY AS DOCUMENTATION
# THIS SCRIPT HAS NOT BEEN EXECUTED

chdef -t node 'compute-1-[32-34],lab-[2,3]' groups=cios_hpccourse,cios_hpccourse_zone,all,new_5nodes_sep04

xdcp new_5nodes_sep04 MLNX_OFED_SRC-4.9-3.1.5.0.tgz /root/MLNX_OFED_SRC-4.9-3.1.5.0.tgz

xdsh new_5nodes_sep04 ls /root/MLNX_OFED_SRC-4.9-3.1.5.0.tgz
xdsh new_5nodes_sep04 'dnf groupinstall -y "Development Tools"' | xcoll
xdsh new_5nodes_sep04 'dnf install -y epel-release' | xcoll
xdsh new_5nodes_sep04 'dnf config-manager --set-enabled PowerTools' | xcoll
xdsh new_5nodes_sep04 'yum install -y python3-Cython glib2-devel systemd-devel' | xcoll
xdsh new_5nodes_sep04 'yum install -y perl pciutils gcc-gfortran tcsh expat glib2 tcl libstdc++ bc tk gtk2 atk cairo numactl pkgconfig ethtool lsof' | xcoll
xdsh new_5nodes_sep04 'yum install -y binutils-devel openssl-devel libdb-devel lsof libselinux-devel tcsh elfutils-devel kernel-rpm-macros iptables-devel gcc-gfortran kernel-devel-4.18.0-193.el8.x86_64 libmnl-devel numactl-devel python36-devel pciutils libnl3-devel' | xcoll
xdsh new_5nodes_sep04 'yum install -y cmake libarchive' | xcoll

# RUNNING INSTALLER FOR MELLANOX DRIVERS
xdsh new_5nodes_sep04 'cd /root && tar xf MLNX_OFED_SRC-4.9-3.1.5.0.tgz' | xcoll
xdsh new_5nodes_sep04 'cd /root/MLNX_OFED_SRC-4.9-3.1.5.0 && ./install.pl --with-nfsrdma --enable-mlnx_tune --enable-opensm --all --mlnx-libs --upstream-libs' | xcoll

# POST INSTALL 
xdsh 'new_5nodes_sep04' 'dracut -f' | xcoll
xdsh 'new_5nodes_sep04' '/etc/init.d/openibd restart' | xcoll
xdsh 'new_5nodes_sep04' '/etc/infiniband/info' | xcoll

xdsh new_5nodes_sep04 'useradd -U -c "Equipo 1" -u 20001 -p mccalpin e1'
xdsh new_5nodes_sep04 'useradd -U -c "Equipo 2" -u 20002 -p mccalpin e2'
xdsh new_5nodes_sep04 'useradd -U -c "Equipo 3" -u 20003 -p mccalpin e3'
xdsh new_5nodes_sep04 'useradd -U -c "Equipo 4" -u 20004 -p mccalpin e4'
xdsh new_5nodes_sep04 'useradd -U -c "Equipo 5" -u 20005 -p mccalpin e5'
xdsh new_5nodes_sep04 'useradd -U -c "Equipo 6" -u 20006 -p mccalpin e6'

xdsh cios_hpccourse 'echo "mccalpin" | passwd --stdin e1'
xdsh cios_hpccourse 'echo "linus" | passwd --stdin e2'
xdsh cios_hpccourse 'echo "ritchie" | passwd --stdin e3'
xdsh cios_hpccourse 'echo "deutsch" | passwd --stdin e4'
xdsh cios_hpccourse 'echo "stroustrup" | passwd --stdin e5'
xdsh cios_hpccourse 'echo "dongarra" | passwd --stdin e6'

xdsh new_5nodes_sep04 'mount compute-1-1:/home /home'
xdsh new_5nodes_sep04 'mount compute-1-1:/root /root'

xdsh cios_hpccourse 'dnf install -y sshpass'

xdsh new_5nodes_sep04 -e ./test-ssh-users.sh
