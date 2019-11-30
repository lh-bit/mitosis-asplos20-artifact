#!/bin/bash

###############################################################################
# Script to run Figure 6 Evaluation of the paper
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

echo "************************************************************************"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis - Figure 6"
echo "************************************************************************"

ROOT=$(dirname `readlink -f "$0"`)
#source $ROOT/site_config.sh

THP="never"
configure_system_settings()
{
        echo $THP | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
        if [ $? -ne 0 ]; then
                echo "Error disabling THP"
                exit
        fi
        echo $THP | sudo tee /sys/kernel/mm/transparent_hugepage/defrag > /dev/null
        if [ $? -ne 0 ]; then
                echo "Error disabling THP"
                exit
        fi
        echo 0 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
        if [ $? -ne 0 ]; then
                echo "Error setting page table allocation to node 0"
                exit
        fi
}
configure_system_settings

# List of all benchmarks to run
BENCHMARKS="gups btree hashjoin redis xsbench pagerank liblinear canneal"
# List of all configs to run
CONFIGS="LPLD LPRD LPRDI RPLD RPILD RPRD RPIRDI"

for bench in $BENCHMARKS; do
	for config in $CONFIGS; do
		echo "******************$bench : $config***********************"
		bash $ROOT/run_f6f10_one.sh $bench $config
	done
done
# --- process the output logs
$ROOT/process_logs_f6f10.py
