---
title: "Benchmarking with `likwid-bench`"
weight: 1
katex: true
bookHidden: true
---

# Benchmarking with `likwid-bench`

We're going to look at the throughput of a very simple piece of code

```c
float reduce(int N, const float *restrict a)
{
  float c = 0;
  for (int i = 0; i < N; i++)
    c += a[i];
  return c;
}
```

when the data live in L1 cache.

We'll do so on an AVX-capable core (where the single-precision vector
width is 8 bytes).

There is a loop-carried dependency on the summation variable, and without
[unrolling](https://en.wikipedia.org/wiki/Loop_unrolling) the execution
stalls at every add until the previous one completes.

Assembly pseudo-code looks something like

{{% columns %}}

#### Scalar code

```
LOAD r1.0 ← 0
i ← 0
loop:
  LOAD r2.0 ← a[i]
  ADD r1.0 ← r1.0 + r2.0
  i ← i + 1
  if i < N: loop
result ← r1.0
```

<--->

#### Vector code

```
LOAD [r1.0, ..., r1.7] ← 0
i ← 0
loop:
  LOAD [r2.0, ..., r2.7] ← [a[i], ..., a[i+7]]
  ADD r1 ← r1 + r2 ; SIMD ADD
  i ← i + 8
  if i < N: loop
result ← r1.0 + r1.1 + ... + r1.7
```

{{% /columns %}}

Looking at the [uops.info table](https://uops.info/table.html) for the
AMD Zen 2 architecture, we see that the instructions of the
floating-point `ADD` family in the AVX ISA extension (the benchmark will
be using the `VADDSS` and `VADDPS` instructions) have a latency of three
cycles and a reciprocal throughput of 0.5, which means that the CPU can
be executing two such operations every cycle.

If the sums use a pipeline so that once the pipeline is full one
operation is retired every cycle, then we should expect the scalar code
to run at one eighth of the `ADD` peak.

The goal of this exercise is to check that this is indeed the case.

In addition, we will start to gain familiarity with some of the
[likwid](https://github.com/RRZE-HPC/likwid/wiki) tools that we will be
using throughout the course.

## Setup: logging in to Hamilton

Likwid is installed on [Hamilton
8](https://www.dur.ac.uk/arc/hamilton/). Remember that you can log in to
the machine with

```
ssh <username>@hamilton8.dur.ac.uk
```

where `<username>` is a placeholder for your CIS username.

{{< hint info >}}
See the [`ssh` tips & tricks]({{< ref configuration.md >}}) pace for
advice on simplifying this process.
{{< /hint >}}

### Using the batch system

Hamilton is a typical supercomputing cluster: the login (or "frontend")
node is shared between all users, and you use a batch system to request
resources and execute your code on the compute nodes.

**Do not** use the login nodes to benchmark code—this is bad for you and
for anybody else using the system:
1. if you overload a login node, it will freeze for everyone else
   using the supercomputer; and
2. as you are not using the machine exclusively, any results you get are
   potentially highly inaccurate (depending on what else is running at
   the time).

You either need to submit a job script that executes your commands to
the batch system, or request an interactive terminal on a compute node.
For details see the [quickstart guide]({{< ref hamilton.md >}}) and the
[Hamilton
documentation](https://www.dur.ac.uk/arc/hamilton/usage/jobs/).

To request an interactive node, run
```
srun --pty $SHELL
```

Note that Hamilton has a limited number of interactive compute nodes. If
they are all in use, then this command will wait until one becomes
available. You can cancel the command with <kbd>control-c</kbd>. The
alternative to using an interactive job is to use a batch job, where you
write a shell script that runs the commands and submit it with `sbatch`.
The Hamilton documentation has some template scripts you can copy on the
`Example job script` tab of the [`Running Jobs`
section](https://www.dur.ac.uk/arc/hamilton/usage/jobs/). You can start
with the serial script and modify it as needed.

Hamilton uses the `module` system
to provide access to software. To gain access to the [likwid tools](https://hpc.fau.de/research/tools/likwid/), we
need to run
```
module load likwid/5.2.0
```

{{< hint info >}} If you run in batch mode, you should execute this
command as part of the batch script. In interactive mode, you need to
load the module each time you request a new interactive job.
{{< /hint >}}


## Using `likwid-bench`

Verify that you have correctly loaded the likwid module by running
`likwid-bench -h` and checking that you see this output:

```
Threaded Memory Hierarchy Benchmark --  Version  5.2


Supported Options:
-h		 Help message
-a		 List available benchmarks
-d		 Delimiter used for physical hwthread list (default ,)
-p		 List available thread domains
		 or the physical ids of the hwthreads selected by the -c expression
-s <TIME>	 Seconds to run the test minimally (default 1)
		 If resulting iteration count is below 10, it is normalized to 10.
-i <ITERS>	 Specify the number of iterations per thread manually.
-l <TEST>	 list properties of benchmark
-t <TEST>	 type of test
-w		 <thread_domain>:<size>[:<num_threads>[:<chunk size>:<stride>]-<streamId>:<domain_id>[:<offset>]
-W		 <thread_domain>:<size>[:<num_threads>[:<chunk size>:<stride>]]
		 <size> in kB, MB or GB (mandatory)
For dynamically loaded benchmarks
-f <PATH>	 Specify a folder for the temporary files. default: /tmp
-o <FILE>	 Save generated assembly to file

Difference between -w and -W :
-w allocates the streams in the thread_domain with one thread and support placement of streams
-W allocates the streams chunk-wise by each thread in the thread_domain

Usage:
# Run the store benchmark on all CPUs of the system with a vector size of 1 GB
likwid-bench -t store -w S0:1GB
# Run the copy benchmark on one CPU at CPU socket 0 with a vector size of 100kB
likwid-bench -t copy -w S0:100kB:1
# Run the copy benchmark on one CPU at CPU socket 0 with a vector size of 100MB but place one stream on CPU socket 1
likwid-bench -t copy -w S0:100MB:1-0:S0,1:S1
```

### An example benchmark

`likwid-bench` has [detailed
documentation](https://github.com/RRZE-HPC/likwid/wiki/Likwid-Bench)
but for this exercise we just need a little bit of information.

We are going to run the `sum_sp` and `sum_sp_avx` benchmarks. The former runs
the scalar single-precision sum reduction from the lecture, while the latter
runs the SIMD sum reduction. You can find the assembler code for
[`sum_sp`](https://github.com/RRZE-HPC/likwid/blob/master/bench/x86-64/sum_sp.ptt)
and for
[`sum_sp_avx`](https://github.com/RRZE-HPC/likwid/blob/master/bench/x86-64/sum_sp_avx.ptt)
on the `likwid` GitHub repository. The syntax used in those files is explained
in the [Adding
benchmarks](https://github.com/RRZE-HPC/likwid/wiki/Likwid-Bench#adding-benchmarks)
section of the `likwid` documentation.

Next, we need to choose the correct setting for the `-w` (for "workgroup")
argument. Recall that our goal is to measure the single-thread performance of
in-cache operations. We therefore need a small vector size, 16kB suffices, and
want to request just a single thread. We can use `-w N:16kB:1` to run the
benchmark on any available core (in our case, the one we have been allocated by
the batch system will be used), for a vector of length 16kB (4000
single-precision entries), using one thread.

{{< hint info >}}
Later we will see how I determined that 16kB was an appropriate size,
and what the `N` stands for (for the impatient: this is the affinity
domain, and here we select none that lets us use any core).
{{< /hint >}}

Running the command `likwid-bench -t sum_sp -w N:16kB:1` you should
see output like the following

```txt {linenos=false,hl_lines=[23]}
Allocate: Process running on hwthread 60 (Domain N) - Vector length 4000/16000 Offset 0 Alignment 1024
--------------------------------------------------------------------------------
LIKWID MICRO BENCHMARK
Test: sum_sp
--------------------------------------------------------------------------------
Using 1 work groups
Using 1 threads
--------------------------------------------------------------------------------
Running without Marker API. Activate Marker API with -m on commandline.
--------------------------------------------------------------------------------
Group: 0 Thread 0 Global Thread 0 running on hwthread 60 - Vector length 4000 Offset 0
--------------------------------------------------------------------------------
Cycles:                 2458121180
CPU Clock:              1996181275
Cycle Clock:            1996181275
Time:                   1.231412e+00 sec
Iterations:             1048576
Iterations per thread:  1048576
Inner loop executions:  1000
Size (Byte):            16000
Size per thread:        16000
Number of Flops:        4194304000
MFlops/s:               3406.09
Data volume (Byte):     16777216000
MByte/s:                13624.37
Cycles per update:      0.586062
Cycles per cacheline:   9.376988
Loads per update:       1
Stores per update:      0
Load bytes per element: 4
Store bytes per elem.:  0
Instructions:           7340032020
UOPs:                   10485760000
--------------------------------------------------------------------------------
```

We are interested in the highlighted MFlops/s line. We can see that this
benchmark runs at 3406.09MFlops/s. The CPU on Hamilton compute nodes is an [AMD
EPYC 7702 64-Core Processor](https://www.amd.com/en/products/cpu/amd-epyc-7702),
which AMD claims has a maximum base clock frequency of 2.0GHz and a maximum
boost frequency of 3.35GHz. This benchmark result is well within the 2 scalar
`ADD` per cycle, which is consistent with the declared reciprocal throughput.

{{< exercise >}} Replicate the scalar sum reduction benchmark for yourself, and
check if you get similar results. Then run the benchmark a few times. What do you
observe? Check with your colleagues: what flop rates do they get?

Compare the results to the floating point performance obtained when you run the
`sum_sp_avx` benchmark instead of the `sum_sp` benchmark. {{< /exercise >}}

{{< question >}}
What floating point throughput do you observe for the SIMD
(`sum_sp_avx`) case?
{{< /question >}}

<div id="vector-size"></div>
{{< exercise >}}

1. Study what happens to the performance (for both the
   `sum_sp` and `sum_sp_avx` benchmarks) when
   you vary the size of the vector from 1kB up to 128MB.
2. Produce a plot of performance with MFlops/s on the y axis and
   vector size on the x axis comparing the `sum_sp` and
   `sum_sp_avx` benchmarks.
{{< /exercise >}}

Rather than copying and pasting the output from every run into a data
file, you might find it useful to script the individual benchmarking
runs. For example, to extract the MFlops/s from the
`likwid-bench` output you can use

```
likwid-bench -t sum_sp -w N:16kB:1 | grep MFlops/s | cut -f 3
```

{{< hint info >}}
#### Scripting the data collection
For different vector sizes, you'll need to change the size,
which can be done with a loop, for example to measure the
performance with vector sizes of 1, 2, and 4kB:

```bash
for size in 1kB 2kB 4kB; do
  echo $size $(likwid-bench -t sum_sp -w N:$size:1 2> /dev/null | grep MFlops/s | cut -f 3)
done
```

where
the `2> /dev/null` redirects the standard error to `/dev/null` effectively
preventing it from being printed to screen)

{{< /hint >}}

{{< question >}}
What do you observe about the performance of the scalar code and the
SIMD code?
{{< /question >}}
