---
title: Slides
weight: 1
draft: false
bookHidden: true
---

# Slides 2021/22 edition

{{< hint info >}}
This edition was taught by  [Lawrence Mitchell](mailto:lawrence@wence.uk)).
{{< /hint >}}

Slides for the live lectures. These will be augmented with annotated
versions, links to recordings, and some short commentary after the
fact. If you think you should have access to the recordings but don't,
please [get in touch]((mailto:lawrence@wence.uk)).

The long form notes add words in between the bullet points.

- [Session 1]({{< static-ref "lecture-slides/2021-22/01.pdf" >}}),
  [annotated]({{< static-ref "lecture-slides/2021-22/annotated/01.pdf" >}}),
  [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=052e8585-00a0-444a-829a-ae1900b6870e).

  We introduced some ideas of computer architecture and talked about
  the motivation for the course. There is a focus on trying to build
  predictive models for the speed that code runs at.

  We finished by working through the [first exercise]({{< ref
  "exercises/exercise01.md" >}}) in the round. But did not quite finish. Have a
  go at [producing the plots]({{< ref "exercises/exercise01.md#vector-size" >}})
  the last part of the exercise requires of you. We will discuss the
  results in the next session

- [Session 2]({{< static-ref "lecture-slides/2021-22/02.pdf" >}}),
  [annotated]({{< static-ref "lecture-slides/2021-22/annotated/02.pdf" >}}),
  [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=deba6d06-5908-49af-bf74-ae1a0143da57).

  I realised while we were doing the second exercise why I couldn't
  reproduce the plot from the slides. I started at 1024kB, rather than
  1kB. I should have looped from `seq 0 17` rather than `seq 10 17`.
  The corrected script to collect all the data we need is

  ```sh
  #!/bin/bash

  # 1 core
  #SBATCH -n 1
  #SBATCH --job-name="collect-bw"
  #SBATCH -o collect-bw.%J.out
  #SBATCH -e collect-bw.%J.err
  #SBATCH -t 00:20:00
  #SBATCH -p par7.q

  source /etc/profile.d/modules.sh

  module load likwid/5.0.1

  for n in $(seq 0 17)
  do
      size=$((2 ** n))
      mflops_scalar=$(likwid-bench -t sum_sp -w S0:${size}kB:1 2>/dev/null | grep MFlops/s | cut -f 3)
      mflops_avx=$(likwid-bench -t sum_sp_avx -w S0:${size}kB:1 2>/dev/null | grep MFlops/s | cut -f 3)
      echo $size $mflops_scalar $mflops_avx
  done
  ```

  We didn't quite finish all of the slides, so we'll pick up where we
  left off and use the results of the second exercise to build a
  predictive model for the performance of the vectorised sum reduction
  at the beginning of the next session.

- [Session 3]({{< static-ref "lecture-slides/2021-22/03.pdf" >}}),
  [annotated]({{< static-ref "lecture-slides/2021-22/annotated/03.pdf" >}}),
  [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=4f7435e0-1b80-4bd6-a9a3-ae2000c78ca7).

  We used the results of our benchmarking of the cache hierarchy to
  construct a model for how fast the sum reductions should run as a
  function of the vector size. It works pretty well! This was the end
  of slides from session 2, I have updated the annotated version
  above. Then I talked, probably for a bit long (sorry), about memory
  bandwidth, resource restrictions and some philosophy of how to go
  about thinking about optimising code.

  We finished by talking about the [roofline
  model](https://en.wikipedia.org/wiki/Roofline_model),
  introduced in [Williams, Waterman, and Patterson
  (2009)](https://people.eecs.berkeley.edu/~kubitron/cs252/handouts/papers/RooflineVyNoYellow.pdf).
  Please read this paper before the session tomorrow and note any
  questions or discussion points you might have on it, we'll read
  through the paper in class and discuss it further then.

- [Session 4]({{< static-ref "lecture-slides/2021-22/04.pdf" >}}),
  [annotated]({{< static-ref "lecture-slides/2021-22/annotated/04.pdf" >}}),
  [annotated roofline paper]({{< static-ref
  "lecture-slides/2021-22/annotated/williams2009-roofline.pdf" >}}), [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=a5d68405-a795-42c3-bc7b-ae21014beb02)

  We spent the first half of the session going over the roofline paper
  and pointing out some key ideas.

  Then I started talking about performance counters and how to access
  them. We finished by trying to confirm our hypotheses about some
  simple stream code and how many loads and stores we would observe.
  We didn't manage to do so in all cases, so we'll try and figure
  things out next time.

- [Session 5]({{< static-ref "lecture-slides/2021-22/05.pdf" >}}),
  [annotated]({{< static-ref "lecture-slides/2021-22/annotated/04.pdf" >}}),
  [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=b584f983-febd-4969-b691-ae2700c4eab1)

  We didn't make it very far through the session five slides, but did
  finish session four on profiling (annotated slides above updated).
  The low-level profiling toolkit on Linux-based systems is
  [perf](https://perf.wiki.kernel.org/index.php/Main_Page), and
  [Brendan Gregg](https://www.brendangregg.com/) has [many
  examples](https://www.brendangregg.com/perf.html).

  We figured out what was going on with our measurements of memory
  loads and stores for the simple example of [exercise 5]({{< ref
  "exercises/exercise05.md" >}}). We needed to convince the compiler
  to do the right thing in terms of the code it emitted, by adding
  `-fno-inline -march=native` to the compile flags: I have updated the
  exercise instructions.

- [Session 6 (didn't get to these slides)]({{< static-ref "lecture-slides/2021-22/06.pdf" >}}), [updated
  annotated session 5 slides]({{< static-ref
  "lecture-slides/2021-22/annotated/05.pdf" >}})
  [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=d7309aaa-c6c8-4b31-96b7-ae280132de5c).

  We went through cache blocking/loop tiling in more detail, and
  constructed a model for how dense matrix-matrix multiplication might
  perform. I left the part of the video in the middle where I did one
  of the exercises so you can observe my process if you like (I didn't
  submit to the batch system because I was a bad person).

  For next time, we'll look at data layout transformations and
  vectorisation, please read through [Henretty et al. (2011), _Data Layout
  Transformation for Stencil Computations on Short-Vector SIMD
  Architectures_](https://web.cs.ucla.edu/~pouchet/doc/cc-article.11.pdf)
  and think of any questions or comments you might have about it for
  next time: we'll go through this paper and the session 6 slides on
  Monday. You might also find glancing at the sesion 7 slides helpful
  for the paper reading.

- Session 7: [annotated session 6 slides]({{< static-ref "lecture-slides/2021-22/annotated/06.pdf" >}}),
  [annotated Henretty (2011) paper]({{< static-ref
  "lecture-slides/2021-22/annotated/stencil-data-layout.pdf" >}})
  [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=6d609469-e249-4ae5-a362-ae2e00c4d672)

  We talked about data layout transformations and vectorisation, and
  then read through the paper on data layout transformations for
  stencil computations. The main idea is that it is sometimes
  possible, and preferable to restructure both the code _and_ data to
  permit more efficient vectorisation. The key ideas in the paper are
  also covered in the [session 7 slides]({{< static-ref
  "lecture-slides/2021-22/07.pdf" >}}), which we didn't go over in class.


- Session 8 [scribbles]({{< static-ref "lecture-slides/2021-22/annotated/08.pdf"
  >}}),
  [video](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=fff86be1-ecf5-4629-b3df-ae2f0129effe)

  I talked a little about the computational model in the finite
  element method (which forms the basis of the code that we're looking
  at in the [coursework]({{< ref "coursework.md" >}}). In particular
  focusing on how much compute and how much data movement happens.

  If you run on
  [Hamilton8](https://www.dur.ac.uk/arc/hamilton/migration/) `likwid`
  is still available (contrary to what I stated live).
