---
title: "Journal"
weight: 2
katex: true
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

  We finished by working through the [Exercise 1]({{< ref
  "exercises/exercise01.md" >}}). We will discuss the results
  in the next session.

- **Session 2**:
[Slides]({{< static-ref "lecture-slides/02.pdf" >}}) –
[Notes]({{< ref "notes/memory.md" >}}) –
[Exercise 2]({{< ref "exercises/exercise02.md" >}}) –
[Exercise 3]({{< ref "exercises/exercise03.md" >}}) –
[Audio](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=c477e919-b55c-422b-b799-af870094e658)

  The Encore capture system still has troubles, and there is a chance it
  will keep having troubles until the end of the submodule. I've decided
  to put a link to the audio recording, should anyone find them useful.

  We started by looking at the results of [Exercise 1]({{< ref
  "exercises/exercise01.md" >}}). We noticed that the performance drops
  as the size of the array we use in the benchmark increases, and we
  identified three plateaus.

  To justify these results, we discussed the fact that the memory is
  divided into several levels (L1, L2, L3 caches, and main memory) and
  that these levels have very different sizes and performance levels.

  We then focused on the cache memory and discussed the organisation of
  direct mapped and associative cache. We briefly mentioned $k$-way
  associative caches.

  We finished by working through [Exercise 2]({{< ref
  "exercises/exercise02.md" >}}) and [Exercise 3]({{< ref
  "exercises/exercise03.md" >}}). We will discuss the results in the
  next session.

- **Session 3**:
[Slides]({{< static-ref "lecture-slides/03.pdf" >}}) –
[Notes]({{< ref "notes/roofline.md" >}}) –
[Exercise 4]({{< ref "exercises/exercise04.md" >}}) –
[Audio](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=21ef9a68-e27f-448d-bd47-af8900946d7b) –
[Paper](https://dl.acm.org/doi/pdf/10.1145/1498765.1498785)

  Still no luck with the Encore capture system, but the audio is
  available.

  We began the session by analysing the results of [Exercise 2]({{< ref
  "exercises/exercise02.md" >}}) and [Exercise 3]({{< ref
  "exercises/exercise03.md" >}}). We focused in particular on [Exercise
  2]({{< ref "exercises/exercise02.md" >}}), of which we gave a rather
  detailed interpretation by means of pen-and-paper calculations. You
  can find these at towards the end of the [slides for Session 2]({{<
  static-ref "lecture-slides/02.pdf" >}}).

  Next, we introduced the roofline model, discussing the key parameters
  we need to estimate. Of these, two (peak floating-point performance
  and main memory bandwidth) depend on the hardware and one (operational
  intensity) on the code we are measuring. We started to how these
  parameters can be estimated, either by looking at spec sheets or
  source code, or by direct measurement. We will give more details on
  the methods based on measurement in the rest of the course.

  We concluded by collecting the data necessary to obtain a roofline
  model for the performance of a simple code computing matrix–vector
  multiplication. This was the subject of [Exercise 4]({{< ref
  "exercises/exercise04.md" >}}).

  In preparation for the next session, please have a look at the
  [article](https://dl.acm.org/doi/pdf/10.1145/1498765.1498785) in which
  roofline models were introduced, and note down any comments or
  questions you might have. Throughout the paper, which was published 14
  years ago, the authors (Williams, Waterman, and Patterson) make a
  number of predictions regarding the evolution of computing. You can
  try to think whether and to what degree they came to pass.

- **Session 4**:
[Slides]({{< static-ref "lecture-slides/04.pdf" >}}) –
[Notes]({{< ref "notes/measurements.md" >}}) –
[Exercise 5]({{< ref "exercises/exercise05.md" >}})

  The Encore capture system was faulty this time, so no recording of the
  live session is available.

  We spent most of the session discussing the paper by Williams,
  Waterman, and Patterson. We then moved on to the slides and started
  discussing performance counters.

  We concluded the session by working through [Exercise 5]({{< ref
  "exercises/exercise05.md" >}}): we used `likwid-perfctr` to collect
  performance measurements on an implementation of the STREAM TRIAD
  benchmark that uses `likwid`'s Marker API.

- **Session 5**:
[Slides]({{< static-ref "lecture-slides/05.pdf" >}}) –
[Notes]({{< ref "notes/measurements.md" >}}) –
[Exercise 6]({{< ref "exercises/exercise06.md" >}}) –
[Recording](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=8b58f649-6a44-4b56-a979-af9000968342)

  The session was dedicated to profiling. We discussed the differences
  between sampling and instrumentation. We then focused in detail at the
  GNU Profiler, which uses a hybrid of the two approaches. We discussed
  the capabilities of the tool, and looked in particular at the three
  types of output the tool can produce: flat profile, call graph, and
  annotated source code.

  We concluded the session by profiling some code with `gprof` and
  instrumenting it to collect performance measurements with
  `likwid-perfctr`.
  In [Exercise 6]({{< ref "exercises/exercise06.md" >}}) we looked at
  profiling and measuring the performance of some simple C code and
  of the `miniMD` application.

  There were some issues with the exercises. Thank you Yash for finding
  out how to produce a call graph with `gprof` when the executable is
  compiled with `-O3`. I have updated the exercise to reflect that.

- **Session 6**:
[Slides]({{< static-ref "lecture-slides/06.pdf" >}}) –
[Notes]({{< ref "notes/tiling.md" >}}) –
[Exercise 7]({{< ref "exercises/exercise07.md" >}}) –
[Recording](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=7a952d80-e5f4-485f-b348-af9500954751)

  In this session, we looked at cache effects in matrix transposition.
  We began by developing a simple performance model for this operation,
  which requires memory accesses but no computation, and we saw that the
  performance of a naive implementation is much worse than our model
  would predict. We argued that this is due to a poor usage of the
  cache, as the algorithm implemented in a naive way cannot exploit
  cache locality when the matrices are large.

  We then discussed how cache utilization can be improved by combining
  *strip mining*, which splits large loops into several small chunks of
  fixed size, and *loop reordering*. We argued that this technique is
  most useful to address the poor performance of nested loops, and we
  used our model to make sense of it.

  In [Exercise 7]({{< ref "exercises/exercise07.md" >}}), we compared
  the performance of two implementation of matrix transposition, a naive
  one based on nested loops and a more advanced one supporting tiling,
  and our experiments mostly confirmed our expectations. We also
  stumbled over a well-known but quite surprising phenomenon when trying
  to transpose large matrices whose size is a power of 2 (in our
  examples, this behaviour was clearly visible for matrices of size 4096
  $\times$ 4096 and multiples thereof.)

- **Session 7**:
[Slides]({{< static-ref "lecture-slides/07.pdf" >}}) –
[Notes]({{< ref "notes/tiling.md" >}}) –
[Exercise 8]({{< ref "exercises/exercise08.md" >}}) –
[Recording](https://durham.cloud.panopto.eu/Panopto/Pages/Viewer.aspx?id=f94eec2d-42ca-4981-be8e-af900095a536)

  In this session, we kept discussing the use of cache memory for matrix
  operations, focusing on matrix–matrix multiplication. This operation
  is more complicated than matrix transposition because it involves
  three matrices, all of which have to be stored in cache to guarantee
  reuse.

  In [Exercise 8]({{< ref "exercises/exercise08.md" >}}), we tried to
  compare three different algorithms for matrix—matrix multiplication: a
  naive variant, one that uses tiles, and one that combines tiling and
  packing. There were some issues with the compilation command, which
  have hopefully been fixed in the updated version of the exercise.
    + I had been testing the code with a different version of the Intel
      compiler (`icc` rather than `icx`), which was much less aggressive
      in its use of vectorisation. This is not the default compiler for
      the `intel/2022.2` module that is the latest on Hamilton.
    + Some of the flags (`-xHOST` in particular), which were accented by
      `icc`, are not accepted by `icx` and cannot be used any longer.

- **Session 8**:
[Slides]({{< static-ref "lecture-slides/08.pdf" >}}) –
[Notes]({{< ref "notes/tiling.md" >}}) –
[Exercise 9]({{< ref "exercises/exercise09.md" >}})
