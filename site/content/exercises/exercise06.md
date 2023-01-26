---
title: "Finding a hotspot and determining the execution limits"
weight: 6
bookHidden: true
---

# Finding a hotspot and determining the execution limits

The goal of this exercise is to model the performance of existing code
using the tools we have seen so far: the [GNU
profiler](https://ftp.gnu.org/old-gnu/Manuals/gprof-2.9.1/html_mono/gprof.html)
to profile our code and
[`likwid-perfctr`](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr)
to look at performance counters. We will have to instrument the code
using the [Marker API]((https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr#using-the-marker-api)) macros. This is a rather hand-on exercise, in which
you will get to modify existing code before running it.

We will be looking at two codes:

1. a [simple C code](#profiling-and-instrumenting-a-simple-C-code).

1. a [mini-app](#profiling-and-instrumenting-a-mini-app).

## Profiling and instrumenting a simple C code

In the first half of this exercise, we will be working with the
`code/exercise06/simple_code.c`, which you can download from [this
website]({{< code-ref 6 "simple_code.c" >}}). The file defines two
functions, `perform_computation_one` and `perform_computation_two`,
which take as input two arrays of `double`s and operate on them, and a
`main`, which allocates and initialises two arrays of length `N` and
then calls the two functions on them. The program takes one optional
command line argument, which represents the size of the two arrays.

### Background

We will be using GCC to compile the code and `likwid-perfctr` to collect
performance measurements, and we will need to load the two modules with
```sh
module load gcc/12.2 likwid/5.2.0
```
To test that the setup is correct, you can try to compile the code
without optimizations and run it. The following two commands
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

### Profiling the code
First, we will use `gprof` to find out what function is the hotspot.
Setting `N = 100000` via the command line argument should be a good
choice for this exercise. Do not forget to pass the `-pg` option to GCC
when compiling your code. You should also use the `-march=native` option
(or the `-mavx2 -mfma` string) to ensure that the compiler makes use of
vector registers, if possible.

{{< hint "info" >}}
For more information on gprof, the HPC centre at Lawrence Livermore
have a [useful introductory
tutorial](https://hpc.llnl.gov/software/development-environment-software/gprof#documentation).
{{< /hint >}}


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

{{< hint "warning" >}}

A program instrumented with gprof will always write its output to
`gmon.out` (overwriting any previous information). So you should make
sure to move the `gmon.out` from each run to a unique name (perhaps
describing briefly what you did) before running the next benchmark.

{{< /hint >}}



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

### Instrumenting the code with the Marker API

Now we will instrument the code so that we can get the performance
counters for the two functions individually. We will see how to
instrument the code, how to compile it, and how to perform the
measurements. Make sure to check out the [section in the
`likwid-perfctr` wiki
page](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr#using-the-marker-api)
to understand what the code is doing, and how to make changes.

#### Including the header file
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
which will allow us to compile the code with and without the `likwid`
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

#### Compiling and running the code

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

#### Installing missing performance groups
Not all performance groups are installed on Hamilton. In fact, we will
be interested in the [`MEM_DP
group`](https://github.com/RRZE-HPC/likwid/blob/master/groups/zen2/MEM_DP.txt),
which reports the operational intensity. This group is not available by
default, but you can download by issuing from a login node the command
```sh
mkdir -p ~/.likwid/groups/zen2/
wget https://raw.githubusercontent.com/RRZE-HPC/likwid/master/groups/zen2/MEM_DP.txt -P ~/.likwid/groups/zen2/
```
If the command executed successfully, the `MEM_DP` group should now be
available in `likwid-perfctr`. You can check this with `likwid-perfctr
-a`, which should produce a list of groups whose last item is
```text
  MEM_DP	Main memory bandwidth in MBytes/s (experimental)
```

{{< exercise >}}

1. Annotate the code in `simple_code.c` so that all the computation in
   `perform_computation_one` and `perform_computation_two` is in two
   named regions.

2. Measure the operational intensity of your code using the `MEM_DP`
   performance group.

{{< /exercise >}}

## Profiling and instrumenting a mini-app

So far, we've only run very simple benchmarks. Now we're going to try
and find some information in a larger code. We will look at the
[`miniMD`](https://github.com/Mantevo/miniMD) application which has
been developed as part of the [Mantevo](https://mantevo.github.io)
project. This is a molecular dynamics code that implements algorithms
and data structures from a large research code, but in a small package
that is amenable to benchmarking and trying out different
optimisations.

The aim is to run and profile the code to determine where it spends
all its time, and then dig a little deeper using likwid markers and
the performance counters API.

### Downloading and compiling the software

`miniMD` is maintained on
[GitHub](https://github.com/Mantevo/miniMD/), so after logging in to
Hamilton, you can get the source code with

```
git clone https://github.com/Mantevo/miniMD.git
```

The code is parallelised with MPI, so we need to load some modules to
make the right compilers available.

```
module load intel/2022.2
module load intelmpi/2021.6
```

We will compile the "reference" implementation which is the in `ref`
subdirectory. The build system uses
[`make`](https://www.gnu.org/software/make/), so first we'll just
compile and check things work. Run `make intel`. You should see some
output, which ends with

```
size ../miniMD_intel
   text    data     bss     dec     hex filename
 219867   20880    2304  243051   3b56b ../miniMD_intel
make[1]: Leaving directory `.../miniMD/ref/Obj_intel'
```

You can check the compilation was successful with `make test`

### Compiling and running with profiling enabled

Having verified the code runs correctly, we will now recompile with
profiling enabled. First run `make clean` to delete the
executable. You will need to edit the `Makefile.intel` file
to add `-pg` to the compile and link flags (do this by
modifying the `CCFLAGS` and `LINKFLAGS`
variables). Now run `make intel` again.

{{< exercise >}}
1. Profile the default run on a compute node. This should
   produce a `gmon.out` file.
1. Produce the gprofile output with `gprof ./miniMD_Intel gmon.out`
   (if it scrolls off the screen, you can redirect the output to a
   text file by appending `> SOMETEXTFILE.txt` to the
   command and then look at it in an editor)

{{< /exercise >}}

{{< question >}}

Where does the code spend most of its time?

{{< /question >}}

{{< exercise >}}

`miniMD` implements a few different algorithms
which can be selected with command line options and choosing
the right input file. Run profiling for the following sets of options.

1. `./miniMD_intel -i in.lj.miniMD --half_neigh 0`
1. `./miniMD_intel -i in.lj.miniMD --half_neigh 1`
1. `./miniMD_intel -i in.eam.miniMD --half_neigh 0`
1. `./miniMD_intel -i in.eam.miniMD --half_neigh 1`

{{< /exercise >}}

{{< question >}}
Do you always see the same functions at the top of
the profile?

{{< /question >}}

### Generating graphical call graphs from gprof output

Inspecting the gprof output just as a text file can be slightly hard
to understand. A clearly overview can often be obtained by creating a
visualisation of the call graph. We can do this with
[`gprof2dot`](https://github.com/jrfonseca/gprof2dot) which is a
Python package that turns gprof (and other profiling output) into the
[dot](https://graphviz.gitlab.io/documentation/) graph format. This
can then be converted to PDF, PNG, or other graphical formats (see the
[graphviz documentation](https://graphviz.gitlab.io/documentation/)
for more details).

Minimally, having installed `gprof2dot` and graphviz, you can generate
a call graph. First, you need to convert the `gmon.out` to the textual
format, with `gprof ./miniMD_intel gmon.out > gmon-output.txt`. Then
run `gprof2dot gmon-output.txt -o gmon-output.dot`. Finally, use `dot
-Tpdf gmon-output.dot -o callgraph.pdf` to generate a PDF.

### Instrumenting hotspot functions with likwid

Having determined which functions are the hotspots, we'll try to get
some more information about their performance. As above, we will use
`likwid-perfctr` and its [marker
API](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr#using-the-marker-api).

In order to instrument a function, we need to find its location in the
source code. We can achieve this by using `grep`: running
```sh
grep -n <NAME_OF_FUNCTION> *.cpp
```
will search for the string `<NAME_OF_FUNCTION>` in all the `.cpp` files
in the current folder and will print matches, along with line numbers.

For instrumentation with the Marker API, we need to follow the steps in
we took [for the simpler
code](#instrumenting-the-code-with-the-marker-api), but we will have to
operate on different files. The [header
file](#including-the-header-file) should be included in `ljs.h`, and the
[initialisation and finalisation of the
API](#initialising-and-finalising-the-marker-api) should be placed in
the `main` function, which is located in `ljs.cpp`.

The flags we used [compile the code](#compiling-and-running-the-code)
will have to be added to the appropriate `Makefile`. As we are using
`make intel` to compile, we should once again edit `Makefile.intel`by

1. removing the `-pg` flag from both `CCFLAGS` and `LINKFLAGS`; and
1. adding `-DLIKWID_PERFMON` to `CCFLAGS` and `-DLIKWID_PERFMON
-llikwid` to `LINKFLAGS`.

Finally, we're ready to rebuild everything, so run `make intel`.

If you run `./miniMD_intel` on its own, everything should work, but
you should see
```sh
Running without Marker API. Activate Marker API with -m on commandline.
```
being printed (this indicates that we managed to successfully add all
the performance monitoring, but are not yet using `likwid-perfctr`).

{{< exercise >}}

Run a profile of the memory and floating point performance. You can use
the `MEM_DP` group, which can be installed [as explained
above](#installing-missing-performance-groups)
```sh
likwid-perfctr -C 0 -g MEM_DP -m ./miniMD_intel -i in.lj.miniMD --half_neigh 1
```

If you want to take the harder route, you can take the measurements
detailed in the
[`MEM_DP.txt`](https://github.com/RRZE-HPC/likwid/blob/master/groups/zen2/MEM_DP.txt)
file by hand, and then compute the `Operational intensity` metric as
defined there. If some of the event sets do not work as you expect when
you use them directly, you can try to use other performance groups, such
as
[`FLOPS_DP`](https://github.com/RRZE-HPC/likwid/blob/master/groups/zen2/FLOPS_DP.txt)
for instructions and
[`MEM`](https://github.com/RRZE-HPC/likwid/blob/master/groups/zen2/MEM.txt)
for memory. .

{{< /exercise >}}

{{< question >}}

What operational intensity do you observe? For this operational
intensity, is the code at the roofline limit?

{{< /question >}}

{{< exercise >}}

Try the same profiling, but this time with with `--half_neigh 0` and
the `in.eam.miniMD` input file.

{{< /exercise >}}

{{< question >}}

Do you notice any differences in the profiles?

{{< /question >}}

{{< question >}}

Can you suggest some next steps to try and improve performance?

{{< /question >}}
