#!/bin/bash

# Run the sum_sp and sum_sp_avx benchmarks on a single core of a
# reserved node for vectors of size between 1kB and 1GB.

#SBATCH -N 1
#SBATCH --job-name="collect-sum-bm"
#SBATCH -o collect-sum-bm.%J.out
#SBATCH -e collect-sum-bm.%J.err
#SBATCH -t 00:05:00
#SBATCH -p test

source /etc/profile.d/modules.sh

module load likwid/5.2.0

# Print some statistics on the CPU whereon the experiment is running.
lscpu

for n in $(seq 0 20)
do
    size=$((2 ** n))
    mflops_scalar=$(likwid-bench -t sum_sp -w N:${size}kB:1 \
                                 2>/dev/null | \
                        grep MFlops/s |
                        cut -f 3)
    mflops_avx=$(likwid-bench -t sum_sp_avx -w N:${size}kB:1 \
                              2>/dev/null | \
                     grep MFlops/s | \
                     cut -f 3)
    echo $size $mflops_scalar $mflops_avx
done
