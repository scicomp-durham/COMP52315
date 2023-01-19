#!/bin/bash

# Run the clload on an increasing number of cores of a reserved node for
# vectors of size between 1kB and 1GB.

#SBATCH -N 1
#SBATCH --job-name="collect-bw-bm"
#SBATCH -o collect-bw-bm.%J.out
#SBATCH -e collect-bw-bm.%J.err
#SBATCH -t 00:30:00
#SBATCH -p test

source /etc/profile.d/modules.sh

module load likwid/5.2.0
module load intel/2022.2

# Download code, must be executed from a login node
# wget https://scicomp-durham.github.io/COMP52315/code/exercise04/dmvm.c
# wget https://scicomp-durham.github.io/COMP52315/code/exercise04/dmvm-blocked.c

# Mesure streaming memory bandwidth of main memory
# using the TRIAD benchmark and an array of size 1GB.
size=1GB
memory_bandwidth=$(likwid-bench -t triad \
                                -w N:$size:1 \
                                2> /dev/null \
                       | grep MByte/s | cut -f 3)

echo "Streaming memory bandwidth: $memory_bandwidth MB/s"

# Compute peak floating point throughput for double precision computations.
# CPU_frequency * number_of_FMAs_per_cycle * width_of_vector_register / 64
# 3.35GHz * 2 * 256 / 64 = 26.8 GFlops/s

echo "Peak floating point throughput: 26.8 GFlops/s"

# Compute the arithmetic intensity of the code.
# 1 FMA per iteration
# 1 store and 3 loads = 4 data accesses
declare -a flagslist=("-O0"
                      "-O1"
                      "-O2"
                      "-O3"
                      "-march=core-avx2 -unroll16 -mfma -O3")

for code_version in dmvm dmvm-blocked
do
    for flags in "${flagslist[@]}"
    do
        icx -std=c11 ${flags[@]} -o $code_version $code_version.c
        for nrow in 1000 2000 5000 10000 20000 50000 100000
        do
            # Output is:
            #   + number_of_iterations
            #   + number_of_rows
            #   + number_of_columns
            #   + performance in MFlops/s
            echo -n "$(./dmvm $nrow 10000 | cut -d " " -f 4) "
        done
        echo ""
    done
done
