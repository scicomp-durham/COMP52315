---
title: "Memory bandwidth"
weight: 3
katex: true
---

# Measuring multi-core memory bandwidth

The goal of this exercise is to measure the memory bandwidth for
various vector sizes as a function of the number of cores used to
process the vector.

Again, we will do this with `likwid-bench`. This time, we will use the
`clload` benchmark.

## Topology of a compute node

{{< exercise >}}
The first thing we need to do is figure out what the _topology_ of the
node we're running on is. We can do that by running `likwid-topology
-g`. We can use this to guide appropriate choices of vectors.
{{< /exercise >}}

{{< question >}}
The output of `likwid-topology` should help you answer these three
questions:
+ How many sockets does a compute node have?
+ How many cores does each socket have?
+ How large are the L1, L2, and L3 caches?
+ Which cache levels are private?
+ How many cores share the shared cache?
{{< /question >}}

Having answered these questions, you should be able to pick appropriate
vector sizes to test the parallel memory bandwidth of both cache and
main memory.

## Interlude: more on `likwid-bench`
### Selecting the number of cores to use

You should have determined that a Hamilton node has two sockets, each
with 64 cores, and that the L1 cache is 32kB and private to each core.
Let's look at how to benchmark in multiple cores with `likwid-bench`.

In order to select the number of cores to allocate to the benchmark, we
have to adapt the workgroup string. Previously we just used `-w
N:size:1` which means

`N`
: The affinity domain on which to _allocate_ the vector. We do not
  specify any affinity domain with `N`, but we can use `S0` or `S1` for
  either of the two sockets.

`size`
: As before, the size of the vector.

`1`
: The _number_ of cores to use.

To change the number of cores, we replace `1` by our choice (say `2`).
The vector size is the global vector size, so if we run with a vector
size $S$ on $N$ cores, then each core gets $\frac{S}{N}$ elements.

For example, to run with 4 cores on the same socket so that each core
handles 4kB of data, we run `likwid-bench -t clload -w S0:16kB:4`, which
should produce output like the below

```txt {linenos=false,hl_lines=[30]}
Warning: Sanitizing vector length to a multiple of the loop stride 32 and thread count 4 from 2000 elements (16000 bytes) to 1920 elements (15360 bytes)
Allocate: Process running on hwthread 0 (Domain S0) - Vector length 1920/15360 Offset 0 Alignment 512
Initialization: First thread in domain initializes the whole stream
--------------------------------------------------------------------------------
LIKWID MICRO BENCHMARK
Test: clload
--------------------------------------------------------------------------------
Using 1 work groups
Using 4 threads
--------------------------------------------------------------------------------
Running without Marker API. Activate Marker API with -m on commandline.
--------------------------------------------------------------------------------
Group: 0 Thread 1 Global Thread 1 running on hwthread 1 - Vector length 480 Offset 480
Group: 0 Thread 3 Global Thread 3 running on hwthread 3 - Vector length 480 Offset 1440
Group: 0 Thread 2 Global Thread 2 running on hwthread 2 - Vector length 480 Offset 960
Group: 0 Thread 0 Global Thread 0 running on hwthread 0 - Vector length 480 Offset 0
--------------------------------------------------------------------------------
Cycles:                 3763788760
CPU Clock:              1996231214
Cycle Clock:            1996231214
Time:                   1.885447e+00 sec
Iterations:             536870912
Iterations per thread:  134217728
Inner loop executions:  15
Size (Byte):            15360
Size per thread:        3840
Number of Flops:        0
MFlops/s:               0.00
Data volume (Byte):     2061584302080
MByte/s:                1093419.21
Cycles per update:      0.014605
Cycles per cacheline:   0.116843
Loads per update:       1
Stores per update:      0
Load bytes per element: 8
Store bytes per elem.:  0
Instructions:           56371445776
UOPs:                   48318382080
--------------------------------------------------------------------------------
```

At the top, `likwid-bench` reports which cores were used. The rest of
the output is the same as for the previous exercises. Again, we are
interested in the highlighted memory bandwidth line.

### Benchmarking on multi-socket systems

If the node has more than one socket, we need to make sure that we
allocate the vector on the correct socket. For example, if we have two
64-core sockets and want to benchmark the main memory bandwidth on all 128
cores, we should write

```
likwid-bench -t clload -w S0:1GB:64 -w S1:1GB:64
```

This tells `likwid-bench` to allocate two vectors each of 1GB, one on
each socket, and to use 64 cores on each socket.


## Measuring the memory bandwidth

{{< exercise >}}
You should now produce plots of memory bandwidth as a function of the
number of cores for data at different levels in the memory hierarchy.

For the private caches (L1, L2), pick a vector size such that the
vector fills about half the cache on each core.

For the L3 cache, pick a vector size to fill around two-thirds of the
cache.

For the main memory, pick a vector size of around 1GB/socket.

You should produce plots of the memory bandwidth as a function of the
number of cores for each of these different vector sizes.

{{< /exercise >}}

{{< question >}}
Do you observe any difference in the _scalability_ of the memory
bandwidth when you change the size of the vectors?

Can you explain what you see based on the notion of shared and
scalable resources?
{{< /question >}}
