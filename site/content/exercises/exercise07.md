---
title: "The effect of loop tiling on matrix transposition"
weight: 7
katex: true
bookHidden: true
---

# The effect of loop tiling on matrix transposition

In lectures, we saw a model for throughput of a matrix transpose
operation. Here we're going to look at the effect on throughput of loop
tiling. You can find an implementation of naive transposition
[here]({{< code-ref 7 "transpose.c" >}}) and one with one level of loop
tiling [here]({{< code-ref 7 "transpose-blocked.c" >}}).

## Compile the code

We'll use the Intel compiler to build this code. So after logging in
to Hamilton and downloading, load the relevant module

```
module load intel/2022.2
```

The untiled version of the code can be compiled with
```sh
icx -O1 -std=c99 -o transpose transpose.c
```
and the tiled version with
```sh
icx -O1 -std=c99 -o transpose-blocked transpose-blocked.c
```

## Measure effective bandwidth as a function of matrix size

{{< exercise >}}
For both the blocked and unblocked code, measure the memory bandwidth
as a function of the number of rows and columns (using square matrices
is fine) from around \\(N = 100\\) to \\(N = 20000\\). Try both with \\(N\\)
a power of two, and \\(N\\) a multiple of ten.

{{< /exercise >}}

{{< question >}}
What do you observe comparing the blocked and unblocked performance?
{{< /question >}}

{{< question >}}
Do you notice anything different when using power of two sizes
compared to multiples of ten?
{{< /question >}}

The default blocking size is a \\(64 \times 64\\) tile. You can
override these sizes when compiling with
```sh
icx -O1 -std=c99 -o transpose-blocked transpose-blocked.c -DRSTRIDE=X
-DCSTRIDE=Y
```
by setting `X` and `Y` to appropriate numbers.

{{< question >}}

Given that a Hamilton CPU has a 32kB level one cache size. What is a
good tile size if you want to block for level one cache?

{{< /question >}}

{{< question >}}

Do you notice any performance changes if you change the tile size?

{{< /question >}}

## Measuring cache behaviour

The code is annotated with likwid markers, so we can run it with
`likwid-perfctr` and measure the cache behaviour. To do this, load the
`likwid/5.2.0` module and recompile the two executables with
```sh
icx -O1 -std=c99 -DLIKWID_PERFMON -o transpose transpose.c -llikwid
```
and
```sh
icx -O1 -std=c99 -DLIKWID_PERFMON -o transpose-blocked transpose-blocked.c -llikwid
```

{{< exercise >}}

For a \\(4096 \times 4096\\) matrix, measure the main memory bandwidth
and data volume for both the blocked and unblocked cases with
`likwid-perfctr -g MEM -C 0 -m <executable> 4096 4096`.

{{< /exercise >}}

{{< question >}}

What do you observe about the measured data volume (reported by
likwid) compared to the effective data volume?

What about if you change to a \\(5000 \times 5000\\) matrix?

Can you explain what you see?

{{< /question >}}
