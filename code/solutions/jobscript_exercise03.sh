#!/bin/bash

# Run the clload on an increasing number of cores of a reserved node for
# vectors of size between 1kB and 1GB.

#SBATCH -N 1
#SBATCH --job-name="collect-bw-bm"
#SBATCH -o collect-bw-bm.%J.out
#SBATCH -e collect-bw-bm.%J.err
#SBATCH -t 01:00:00
#SBATCH -p test

source /etc/profile.d/modules.sh

module load likwid/5.2.0

# Print some statistics on the CPU whereon the experiment is running.
lscpu
echo -e "\n\n"

#######################
## Print the result. ##
#######################
# The output will have the following header:
#
# n_cores L1_BW_s L1_BW_d L2_BW_s L2_BW_d L3_BW_s L3_BW_d RAM_BW_s RAM_BW_d
#
# where
#   * L1, L2, L3, and RAM: type of memory
#   * s and d: number of sockets being used (single-socket and dual-socket)

# Print header
echo n_cores \
     L1_BW_s L1_BW_d \
     L2_BW_s L2_BW_d \
     L3_BW_s L3_BW_d \
     RAM_BW_s RAM_BW_d

max_cores_per_socket=64
for n_cores in $(seq 1 64)
do
    # Compute number of sockets needed, and number of cores per socket.

    # Compute size of vector to be allocated to each socket.
    # number of cores * size of cache (in kB) * fraction we want to fill
    L1_size=$((n_cores * 32 / 2))                 # half the cache
    L2_size=$((n_cores * 512 / 2))                # half the cache
    L3_size=$((n_cores * (16 * 1024) * 2 / 3))    # two thirds of the cache

    RAM_size=$((2 * 1024 * 1024))

    #Print number of cores.
    # echo -n "$n_cores "

    # Print bandwidth for L1, L2, and L3 cache and for RAM.
    for size in $RAM_size # $L1_size $L2_size $L3_size $RAM_size
    do
	mem_bandwidth_single=$(likwid-bench -t clload \
                                            -w S0:${size}kB:${n_cores} \
                                            2> /dev/null \
                                   | grep MByte/s | cut -f 3)
        mem_bandwidth_dual=$(likwid-bench -t clload \
                                          -w S0:${size}kB:${n_cores} \
                                          -w S1:${size}kB:${n_cores} \
                                          2> /dev/null \
                                 | grep MByte/s | cut -f 3)
        echo -n "$mem_bandwidth_single $mem_bandwidth_dual "
    done
    echo ""
done
