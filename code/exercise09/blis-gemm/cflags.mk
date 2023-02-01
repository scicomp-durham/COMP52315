# These flags are for the Intel compiler icx, GCC/Clang may need different ones
CC = icx
CFLAGS := -O3 -march=core-avx2 -ffast-math
USE_LIKWID = No
USE_OPENBLAS = No
