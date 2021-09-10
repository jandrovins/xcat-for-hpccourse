#!/bin/bash

xdsh cios_hpccourse 'echo 0 > /proc/sys/kernel/kptr_restrict'
xdsh cios_hpccourse 'echo -1 > /proc/sys/kernel/perf_event_paranoid'
