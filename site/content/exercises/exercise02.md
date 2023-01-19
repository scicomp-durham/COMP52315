---
title: "Memory bandwidth in the memory hierarchy"
weight: 2
bookHidden: true
---

# Memory bandwidth in the memory hierarchy

The goal of this exercise is to determine the memory bandwidth as a function of
the amount of data we are moving on the Hamilton cores.

As done in the [the first exercise]({{< ref "exercise01" >}}) we will use
`likwid-bench`. This time we will use three different benchmarks:

1. [`clcopy`](https://github.com/RRZE-HPC/likwid/blob/master/bench/x86-64/clcopy.ptt):
   Double-precision cache line copy, which only touches first element of each cache line.

2. [`clload`](https://github.com/RRZE-HPC/likwid/blob/master/bench/x86-64/clload.ptt):
   Double-precision cache line load, which only loads first element of each cache
   line.
3. [`clstore`](https://github.com/RRZE-HPC/likwid/blob/master/bench/x86-64/clstore.ptt):
   Double-precision cache line store, which only stores first element of each cache
   line.

These benchmarks do the minimal amount of work while moving data in cache lines
(64 bytes at a time), and therefore they exercise the memory bandwidth
bottlenecks (rather than instruction issue or similar).

## Running the benchmarks

As mentioned, this time we want to measure memory bandwidth with the
`clcopy`, `clload`, and `clstore`
benchmarks. We are interested in the (highlighted) MByte/s output of
`likwid-bench`. For example running
```sh
likwid-bench -t clcopy -w N:1kB:1
```
produces the following output.

```txt {linenos=false,hl_lines=[27]}
Warning: Sanitizing vector length to a multiple of the loop stride 32 and thread count 1 from 62 elements (496 bytes) to 32 elements (256 bytes)
Allocate: Process running on hwthread 22 (Domain N) - Vector length 32/256 Offset 0 Alignment 512
Allocate: Process running on hwthread 22 (Domain N) - Vector length 32/256 Offset 0 Alignment 512
--------------------------------------------------------------------------------
LIKWID MICRO BENCHMARK
Test: clcopy
--------------------------------------------------------------------------------
Using 1 work groups
Using 1 threads
--------------------------------------------------------------------------------
Running without Marker API. Activate Marker API with -m on commandline.
--------------------------------------------------------------------------------
Group: 0 Thread 0 Global Thread 0 running on hwthread 22 - Vector length 32 Offset 0
--------------------------------------------------------------------------------
Cycles:                 4032322860
CPU Clock:              1996234632
Cycle Clock:            1996234632
Time:                   2.019964e+00 sec
Iterations:             536870912
Iterations per thread:  536870912
Inner loop executions:  1
Size (Byte):            512
Size per thread:        512
Number of Flops:        0
MFlops/s:               0.00
Data volume (Byte):     274877906944
MByte/s:                136080.57
Cycles per update:      0.234712
Cycles per cacheline:   1.877697
Loads per update:       1
Stores per update:      1
Load bytes per element: 8
Store bytes per elem.:  8
Load/store ratio:       1.00
Instructions:           5905580048
UOPs:                   7516192768
--------------------------------------------------------------------------------
```

{{< exercise >}}
Produce a plot of memory bandwidth as a function of the size vector
being streamed from 1kB up to 1GB for each of the three different
benchmarks.

As before, you can script this data collection with a [bash loop]({{<
ref "exercise01.md#scripting-the-data-collection" >}}).
{{< /exercise >}}

{{< question >}}
What do you observe about the available memory bandwidth?
Is the bandwidth the same for 1kB and 1GB vectors? Why?
{{< /question >}}

{{< exercise >}}
Use `likwid-topology` to find out about the
different sizes of cache available on the system. You can find
out how to use it by providing the `-h`
command-line flag. The graphical output (`-g`) is most useful. However, a
compute node of Hamilton 8 has 64 cores per socket, which will most likely mess
up the view; the command `less -S` might come in handy.
{{< /exercise >}}

{{< question >}}
Can you use the output from `likwid-topology` to explain and
understand your memory bandwidth results?
{{< /question >}}
