---
title: "Journal"
weight: 2
---

# Journal

Slides that will be used in the lectures. A link to the Panopto
recording, if available, as well as a short summary of what was
discussed, will follow after the session. If you think you should have
access to the recordings but you don't, please [get in
touch]((mailto:massimiliano.fasi@durham.ac.uk)).

- **Session 1:**
[Slides]({{< static-ref "lecture-slides/01.pdf" >}}) –
[Notes]({{< static-ref "notes/introduction.md" >}}) –
[Exercise 1]({{< static-ref "exercises/exercise01.md" >}}) –
No recording available.

  The Encore capture system did not work for this session, thus no
  recording is available.

  We introduced some ideas of computer architecture and talked about the
  motivation for the course. There is a focus on trying to build
  predictive models for the speed that code runs at.

  We finished by working through the [first exercise]({{< ref
  "exercises/exercise01.md" >}}). To produce the [plots]({{< ref
  "exercises/exercise01.md#vector-size" >}}) in the last part of the
  exercise, you can use the jobscript below. We will discuss the results
  in the next session.
```shell
#!/bin/bash

# 1 core
#SBATCH -n 1
#SBATCH --job-name="collect-bw"
#SBATCH -o collect-bw.%J.out
#SBATCH -e collect-bw.%J.err
#SBATCH -t 00:20:00
#SBATCH -p shared

source /etc/profile.d/modules.sh

module load likwid/5.2.0
lscpu

for n in $(seq 0 20)
do
    size=$((2 ** n))
    mflops_scalar=$(likwid-bench -t sum_sp -w N:${size}kB:1 2>/dev/null | grep MFlops/s | cut -f 3)
    mflops_avx=$(likwid-bench -t sum_sp_avx -w N:${size}kB:1 2>/dev/null | grep MFlops/s | cut -f 3)
    echo $size $mflops_scalar $mflops_avx
done
```



- Session 2:
[Slides]({{< static-ref "lecture-slides/02.pdf" >}}) –
[Notes]({{< static-ref "notes/memory.md" >}}) –
[Exercise 2]({{< static-ref "exercises/exercise02.md" >}}) –
[Exercise 3]({{< static-ref "exercises/exercise03.md" >}})
