#!/bin/bash
hostnames=('compute-1-1'        'compute-1-2'      'compute-1-8'       'compute-1-9'       'compute-1-12'      'compute-1-13'      'compute-1-15'      'compute-1-16'       'compute-1-5'      'compute-1-11'      )
counter=0
for i in 1 2 3 4 5;do # 5 clusters
    i1=$counter

    h1="${hostnames[$i1]}"

    #rsync -av h1:/shared
    rsync -azP --delete $h1:/shared /backup/$h1

    counter=$((counter+2))
done
