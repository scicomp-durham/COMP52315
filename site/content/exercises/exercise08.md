---
title: "Loop tiling for matrix–matrix multiplication"
weight: 8
katex: true
bookHidden: true
---

# Loop tiling for matrix–matrix multiplication

In [Exercise 7]({{< ref "exercise07.md" >}}), we looked at the
effect of loop tiling schemes to increase the throughput of matrix
transposition. Now we are going to look at the throughput of loop
tiling for matrix–matrix multiplication. The [matrix-matrix
multiplication code]({{< code-ref 8 "gemm.c" >}}) we will use
provides contains different variants: a naive triple loop, a tiled
version of the triple loop, and a tiled version that manually
packs local buffers.

## Compiling the code

We will be using the intel compiler to build this code. After
logging in to Hamilton and downloading the `gemm.c` code, we need
to load the compiler with

```
module load intel/2022.2
```

The code can be compiled with `icx -O3 -xHOST -o gemm gemm.c`.

## Compare the variants

You can run the different implemented variants with `./gemm N VARIANT`
where `N` is the matrix size and `VARIANT` is one of `BASIC`, `TILED`,
or `TILEDPACKED`.

For the `TILED` and `TILEDPACKED` variants, the matrix size must be a
multiple of the tile size (which is 64 by default).

{{< exercise >}}

Run the code with matrix sizes from 64 up to 2048.

{{< /exercise >}}

{{< question >}}
Which version performs the best?
{{< /question >}}

## Inspecting optimisation reports

You probably noticed that the `TILEDPACKED` variant
performed very badly. Before measuring anything, we can look at more
detailed output from the compiler to see if we spot anything
suspicious.

The Intel compiler can provide excellent diagnostics on what it was
doing when compiling code. Run the compile command again, this time
with
```sh
icx -O3 -xHOST -qopt-report=3 -qopt-report-file=no-simd-reduction.txt -o gemm gemm.c
```
Look in the resulting `no-simd-reduction.txt` file and search for
`tiled_packed_gemm` (the name of the routine that performs worse
than expected).

{{< question >}}

Do you see anything in the optimisation report that stands out as
interesting?

{{< /question >}}


In this case, it seems that we need to give the compiler a hint as to
how to proceed. It did not vectorise the inner loop because it
couldn't prove that it was safe to do so. However, we know it is safe,
so I've added some annotations to the relevant loop. Instead of having

```c
for (p = 0; p < TILESIZE; p++) {
  c[j_*ldc + i_] += apack[i*TILESIZE + p] * bpack[j*TILESIZE + p];
}
```

I use [OpenMP](https://www.openmp.org) pragma annotations to instruct
the compiler to vectorise the loop

```c
double c_ = 0;
#pragma omp simd reduction (+: c_)
for (p = 0; p < TILESIZE; p++) {
  c_ += apack[i*TILESIZE + p] * bpack[j*TILESIZE + p];
}
c[j_*ldc + i_] += c_;
```

{{< exercise >}}

Try compiling again, this time adding `-DSIMD_REDUCTION` to the
compile line (and changing the output file for the optimisation report
to `simd-reduction.txt`

{{< /exercise >}}

{{< question >}}

Look at the new optimisation report and see what the compiler reports
this time.

Did it manage to vectorise the loop?

{{< /question >}}

{{< exercise >}}

Benchmark this new version of the `TILEDPACKED` variant using the same
set of matrix sizes as before.

{{< /exercise >}}

{{< question >}}

Do you observe any change in the performance?

{{< /question >}}

## The effects of tiling on memory movement

As usual, this example is also annotated with likwid markers. We'll
use `likwid-perfctr` to measure the effect of loop tiling on the total
_data movement_ and measured _arithmetic intensity_ for a large
matrix. We'll need to recompile with likwid enabled for this, so
`module load likwid/5.2.0` and recompile, adding `-DLIKWID_PERFMON
-llikwid` to the compilation flags.

{{< exercise >}}

Measure the memory and floating point performance for the three
different variatnts using \\(N = 3072\\) using the `MEM_DP` group.

{{< /exercise >}}

{{< question >}}

What do you observe in terms of operational intensity and total
volume of data moved from main memory?

Can you relate this to the simple model we discussed?

{{< /question >}}
