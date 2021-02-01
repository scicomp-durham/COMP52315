---
title: Introduction
draft: false
weight: 1
---

# COMP52315: Performance Engineering

This is the course webpage for the Performance Engineering part of
[COMP52315]({{< modulepage >}}). It collects the exercises, syllabus,
and notes. The source repository is [hosted on GitHub]({{< repo >}}).

The primary goal of the course is to equip you with tools and
techniques to answer the question

{{< question >}}

Given some code, which I would like to run faster, how do I know
_what_ to do?

{{< /question >}}

This is a large and open-ended question, so we will focus on a subset
of all the possible approaches. The philosophy is that of treating the
computer, and the code we run on it, as an _experimental system_. Our
goal is to

1. Perform measurements (of performance) on this sytems;
2. Construct _models_ that explain the behaviour;
3. Use these models to determine, and then apply, appropriate
   optimisations.

## Course Organisation

The course will run over four weeks starting on 11th January 2021.
Each week there will be two sessions run via Teams, scheduled at 9am
on Mondays and 4pm on Tuesdays (UK time).

There are a bunch of exercises which we'll mostly work on in the live
sessions, their aim is to familiarise you with the tools we'll use for
performance measurements and modelling throughout the course.

As well as the listed exercises, the notes also contain shorter
exercises which you should attempt. We can discuss them in the live
sessions.

{{< exercise >}}
Exercises look like this.
{{< /exercise >}}

## Annotated slides

Slides as annotated during the live lectures

- [Session 1](lecture-slides/01.pdf)
- [Session 2](lecture-slides/02.pdf)
- [Session 3](lecture-slides/03.pdf), and the [roofline
  paper](lecture-slides/williams2009-roofline.pdf)
- [Session 4](lecture-slides/04.pdf)
  I got a bit confused towards the end in the exercises determining
  why likwid was reporting load counts different from those we were
  expecting. We worked this out (thanks Finlay) by the next session:
  the compiler was inlining some code and producing some extra moves.
- [Session 5](lecture-slides/05.pdf)
- [Session 6](lecture-slides/06.pdf)
  I went over the end of the cache blocking for matrix-matrix
  multiplication again, and then we looked briefly at the performance
  we obtained on Hamilton. We then looked at how we can convince our
  compiler to generate the code we know is right. As mentioned, in my
  experience, of Intel, GCC, and Clang, the Intel compiler is the best
  in terms of optimisation reports. Flags for Intel are in the slides.
  For GCC, we can get some reports with `-fopt-info` (see [this
  page](https://gcc.gnu.org/onlinedocs/gcc/Developer-Options.html) and
  search for `-fopt-info`). For Clang, we can get some reports with
  `-Rpass=vec` and `-Rpass-missed=vec` (see [this
  page](https://clang.llvm.org/docs/UsersManual.html#options-to-emit-optimization-reports)).
- [Session 7](lecture-slides/07.pdf), I also annotated one page from
  the [BLIS paper](lecture-slides/vanzee2015-blis.pdf).

  The two articles I took examples from for the dimension-lifted
  transposition approach are [Henretty et al. (2011), _Data Layout
  Transformation for Stencil Computations on Short-Vector SIMD
  Architectures_](https://web.cs.ucla.edu/~pouchet/doc/cc-article.11.pdf),
  and [Boyle et al. (2015), _Grid: A next generation data parallel C++
  QCD library_](https://arxiv.org/pdf/1512.03487.pdf). One example of
  the same approach applied to unstructured problems is shown in [Sun
  et al. (2020), _A study of vectorization for matrix-free finite
  element methods_](https://arxiv.org/pdf/1903.08243.pdf).

## Syllabus

- Fundamentals of performance engineering
- Tools: CPU topology and affinity
- The Roofline performance model
- Tools: Performance counters
- Technique: Vectorisation (SIMD programming)
- Technique: Data layout transformations

## Lecturer

- [Lawrence Mitchell](mailto:lawrence@wence.uk)
