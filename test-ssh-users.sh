#!/bin/bash

nodes=( compute-1-1 compute-1-11 compute-1-12 compute-1-13 compute-1-16 compute-1-2 compute-1-27 compute-1-28 compute-1-30 compute-1-31 compute-1-5 compute-1-8 lab-2 lab-3 compute-1-32 compute-1-33 compute-1-34) 
users=( e1 e2 e3 e4 e5 e6 )
passwords=( mccalpin linus ritchie deutsch stroustrup dongarra)

for i in `seq 0 5`; do
    for h in "${nodes[@]}"; do
        p="${passwords[$i]}"
        u="${users[$i]}"
        sshpass -p "$p" ssh "$u"@"$h" 'echo "HOSTNAME=`hostname` and USER=`whoami` ID=`id` OK"' || echo "HOSTNAME=$h and USER=$u ERROR"
    done
done
