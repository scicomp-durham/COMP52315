---
title: "Instrumenting code with the `likwid` Marker API"
weight: 7
katex: true
bookHidden: true
draft: true
---

# Instrumenting code with the `likwid` Marker API

The goal of this exercise is to conduct a performance analysis of a
simple code from the ground up using the tools we have seen so far. We
will use the [GNU
profiler](https://ftp.gnu.org/old-gnu/Manuals/gprof-2.9.1/html_mono/gprof.html)
to profile our code and
[`likwid-perfctr`](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr)
to look at performance counters. We will have to instrument the code
using the Marker API macros. This is a rather hand-on exercise, in which
you will get to modify existing code before running it.


## Background

We will be working with the `code/exercise06/simple_code.c`, which you
can download from [this website]({{< code-ref 6 "simple_code.c" >}}).
The file defines two functions, `perform_computation_one` and
`perform_computation_two`, which take as input two arrays of `double`s
and operate on them, and a `main`, which allocates and initialises two
arrays of length `N` and then calls the two functions on them. The
program takes one optional command line argument, which represents the
size of the two arrays.

We will be using GCC to compile the code and `likwid-perfctr` to collect
performance measurements, and we will need to load the two modules with
```sh
module load gcc/12.2 likwid/5.2.0
```
To test that the setup is correct, you can try to compile the code
without optimizations and run it. The following two comands
```sh
gcc simple_code.c -o simple_code
time ./simple_code
```
should produce an output along the lines of
```sh
Using N = 1000
First result is 8.0930e+00
Second result is 3.3102e+03

real	0m0.004s
user	0m0.003s
sys	0m0.000s
```
The code accepts one (optional) command line argument, and we can use it
to specify the vector size `N`, which is set to `1000` by default.
Additional command line arguments are ignored, and a message is printed
when that happens.

## Profiling the code
First, we will use `gprof` to find out what function is the hotspot.
Setting `N = 100000` via the command line argument should be a good
choice for this exercise. Do not forget to use pass the `-pg` option to
GCC when compiling your code. You should also use either the
`-march=native` or the `-mavx2` option to ensure that the compiler makes
use of vector registers, if possible.

{{< exercise >}}

1. Compile the code with the lowest optimization level (you can use the
   optimization flag `-O0`, which is the default), and time one run for
   `N = 100000`.

1. Increase the optimization level by using the optimization flag `-O3`.
   Time the code and compare the timing with that of the unoptimized
   run.

1. Now use `gprof` to read the content of `gmon.out` for the code
   produced with `-O0` and `-O3`.

{{< /exercise >}}

{{< question >}}
1. Do the results for `-O0` and `-O3` match your expectations? What
   difference do you see, beyond timings?

1. What do you think the explanation for the poor results is?
{{< /question >}}

{{< exercise >}}

Now try to profile the compiled with the `-fno-inline` and
`-fno-reorder-functions` for the optimization level `-O3`. Does this
help you figure out what is happening?

{{< /exercise >}}

## Instrumenting the code with the Marker API

Now we will instrument the code to measure the performance of the two
function. We will only see how to instrument the code, how to compile
it, and how to perform the measurements. Make sure to check out the
[section in the `likwid-perfctr` wiki
page](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr#using-the-marker-api)
to understand what the code is doing, and how to make changes.

#### Including the Marker API

First of all, we need to add, before the beginning of the first
measurement region, the code snippet
```c
#ifdef LIKWID_PERFMON
#include <likwid-marker.h>
#else
#define LIKWID_MARKER_INIT
#define LIKWID_MARKER_THREADINIT
#define LIKWID_MARKER_SWITCH
#define LIKWID_MARKER_REGISTER(regionTag)
#define LIKWID_MARKER_START(regionTag)
#define LIKWID_MARKER_STOP(regionTag)
#define LIKWID_MARKER_CLOSE
#define LIKWID_MARKER_GET(regionTag, nevents, events, time, count)
#endif
```
which will allow us to compile the code with and without the likwid
header in place. You can download the short header file [`likwidinc.h`]({{<
code-ref "snippets/likwidinc.h" >}}) and include it in `simple_code.c` with
```c
#include "likwidinc.h"
```

#### Marking named regions

Next, we need to enclose the portions of code we want to measure in a
named region. We can do that easily with the two macros
```C
LIKWID_MARKER_START("<region_name>");

LIKWID_MARKER_STOP("<region_name>");
```
where `<region_name>` is a string that will be used to identify the
portion of code in the output of `likwid-perfctr`. Try to create two
regions, one for each function.

#### Initialising and finalising the Marker API

Finally, we need to modify the `main` function by adding
```c
LIKWID_MARKER_INIT;
LIKWID_MARKER_THREADINIT;
```
before the first call to a `LIKWID_MARKER_START` and
```c
LIKWID_MARKER_CLOSE;
```
after the last call to a `LIKWID_MARKER_STOP`.

{{< hint warning >}}
Make sure that all macros are reachable. For example, they should not be
in a branch of an `if` statement or after a `return` instructions.
{{< /hint >}}


You can look at the [C source code]({{< code-ref 5 "stream.c" >}}) we
used in [Exercise 5]({{< ref "exercise05.md" >}}) to see an example C
code that uses the Marker API.

Next, we need to compile and run the code, which we can do with the same
commands as in [Exercise 5]({{< ref "exercise05.md" >}}). Assuming that
your annotated code is in the file `simple_code.c`, you can compile it
with
```sh
gcc -std=c99 -mfma -O1 -DLIKWID_PERFMON -fno-inline -march=native \
    -o simple_code simple_code.c -llikwid
```
and you can measure the performance of the executable for `N = 100000`
with
```sh
likwid-perfctr -m -g "<group_string>" -C 0 ./simple_codef 100000
```

Here, `<group_string>` can be either:
1. a [custom even
   set](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr#using-custom-event-sets)
   of the form `<counter>:<register>`, where `<counter>` is the
   performance counter we want to use (for example `LS_DISPATCH_LOADS`)
   and `<register>` is the register in which we want to save it; or
2. a suitable [performance
   group](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr#performance-groups),
   such as `BRANCH`, `DATA`, `FLOPS_DP`, or `TLB`, for example. You can
   see the complete list of performance group supported on the [GitHub
   folder for the AMD Zen2
   microarchitecture](https://github.com/RRZE-HPC/likwid/tree/master/groups/zen2).
   Each `.txt` file is a performance group, and you can what kind of
   event sets and metrics it will produce by looking at the individual
   files.

{{< exercise >}}

1. Annotate the code in `simple_code.c` so that all the computation in
   `perform_computation_one` and `perform_computation_two` is in two
   named regions.

2. Measure the operational intensity of your code using the `MEM_DP`
   performance group.

{{< /exercise >}}

{{< question >}}

Does the measured operational intensity match your expectations? Can you
explain the discrepancies?

{{< /question >}}
