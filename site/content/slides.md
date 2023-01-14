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

- **Session 1**:
[Slides]({{< static-ref "lecture-slides/01.pdf" >}}) –
[Notes]({{< ref "notes/introduction.md" >}}) –
[Exercise 1]({{< ref "exercises/exercise01.md" >}}) –
[Audio](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=931d06c3-113f-4e06-b03e-af82009523dc)

  The Encore capture system had some troubles, thus only the audio
  recording of the session is available.

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



- **Session 2**:
[Slides]({{< static-ref "lecture-slides/02.pdf" >}}) –
[Notes]({{< ref "notes/memory.md" >}}) –
[Exercise 2]({{< ref "exercises/exercise02.md" >}}) –
[Exercise 3]({{< ref "exercises/exercise03.md" >}}) –
[Audio](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=c477e919-b55c-422b-b799-af870094e658)

  The Encore capture system still has troubles, and there is a chance it
  will keep having troubles until the end of the submodule. I've decided
  to put a link to the audio recording, should anyone find them useful.

  We discussed the memory hierarchy and the organisation of direct mapped
  and associative cache.

  We finished by working through the [second]({{< ref
  "exercises/exercise02.md" >}}) and [third]({{< ref
  "exercises/exercise03.md" >}}). We will discuss the results in the
  next session.

- **Session 3**:
[Slides]({{< static-ref "lecture-slides/02.pdf" >}}) –
[Notes]({{< ref "notes/roofline.md" >}}) –
[Exercise 4]({{< ref "exercises/exercise04.md" >}}) –
[Paper](https://dl.acm.org/doi/pdf/10.1145/1498765.1498785)
