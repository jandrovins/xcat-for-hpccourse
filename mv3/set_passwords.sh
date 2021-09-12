#!/bin/bash

passwords=(linus mccalpin deutsch stroustrup ritchie) 
xcatg_prefix=cios_hpccourse_cluster
for((i=1;i<=5;i++)); do
    p_ind=$((i-1))
    echo INFO: xdsh ${xcatg_prefix}${i} "echo ${passwords[$p_ind]} | passwd --stdin root"
    xdsh ${xcatg_prefix}${i} "echo ${passwords[$p_ind]} | passwd --stdin root"
done
