#!/bin/bash

# Run performance measurements using likwid-perfctr on annotated code.

#SBATCH -N 1
#SBATCH --job-name="collect-bw-bm"
#SBATCH -o collect-bw-bm.%J.out
#SBATCH -e collect-bw-bm.%J.err
#SBATCH -t 00:05:00
#SBATCH -p teset

source /etc/profile.d/modules.sh

module load likwid/5.2.0
module load gcc/12.2

# Download code, must be executed from a login node
# wget https://scicomp-durham.github.io/COMP52315/code/exercise05/stream.c

gcc -std=c99 -mfma -O1 -DLIKWID_PERFMON -fno-inline -march=native -o stream stream.c -llikwid

likwid-perfctr -m -g "LS_DISPATCH_LOADS:PMC0" -C 0 ./stream 1000000 sca
likwid-perfctr -m -g "LS_DISPATCH_STORES:PMC0" -C 0 ./stream 1000000 sca
