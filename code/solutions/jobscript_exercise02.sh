#!/bin/bash

# Run the clcopy, clload, and clstore benchmarks on a single core of a
# reserved node for vectors of size between 1kB and 1GB.

#SBATCH -n 1
#SBATCH --job-name="collect-mem-bm"
#SBATCH -o collect-mem-bm.%J.out
#SBATCH -e collect-mem-bm.%J.err
#SBATCH -t 00:05:00
#SBATCH -p test

source /etc/profile.d/modules.sh

module load likwid/5.2.0

# Print some statistics on the CPU whereon the experiment is running.
lscpu

for n in $(seq 0 20)
do
    size=$((2 ** n))
    bandwidth_clcopy=$(likwid-bench -t clcopy -w N:${size}kB:1 2>/dev/null | \
                           grep MByte/s | cut -f 3)
    bandwidth_clload=$(likwid-bench -t clload -w N:${size}kB:1 2>/dev/null | \
                           grep MByte/s | cut -f 3)
    bandwidth_clstore=$(likwid-bench -t clstore -w N:${size}kB:1 2>/dev/null | \
                            grep MByte/s | cut -f 3)
    echo $size $bandwidth_clcopy $bandwidth_clload $bandwidth_clstore
done
