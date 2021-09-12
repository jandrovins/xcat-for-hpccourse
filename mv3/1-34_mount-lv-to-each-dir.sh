#!/bin/bash

for ((i=1;i<=5;i++)); do
    dir=/cios_hpccourse_mv3_fs/e${i}fs
    vol=/dev/cios_mv3_home/e${i}_lv
    umount $dir
    mount $vol $dir
done
