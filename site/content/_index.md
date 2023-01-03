---
title: Introduction
draft: false
weight: 1
---

# COMP52315: Performance Engineering

This is the course webpage for the Performance Engineering part of
[COMP52315]({{< modulepage >}}). It collects the syllabus, exercises, slides,
and notes for the course. The source repository is [hosted on GitHub]({{< repo
>}}).

The primary goal of the course is to equip you with tools and
techniques to answer the question:

{{< question >}}

Given some code, which I would like to run faster, how do I know
_what_ to do?

{{< /question >}}

This is a large and open-ended question and we will focus on a subset
of all the possible approaches. The philosophy is that of treating the
computer, and the code we run on it, as an _experimental system_. Our
goal is to:

1. measure the performance of this system;
2. construct _models_ that explain the observed behaviour; and
3. use these models to determine, and then apply, appropriate
   optimisations.

## Course Organisation

The course will run over four weeks starting on 9th January 2023. Our weekly
session will be on Mondays and Thursdays, from 16:00 to 18:00, in MCS3098.

During the sessions, we will use the [slides]({{< ref "slides.md" >}}) as guide,
but we will spend a good deal of our time working on the exercises. The long
form notes run over much of the same ground, but with more words.

The exercises are designed to help you get familiar with the tools we'll use
throughout the course. The notes contain shorter exercises that you should
attempt on your own before we discuss them in the live sessions.

Some of the content is enclosed in boxes:

{{< exercise >}}
Exercises look like this.
{{< /exercise >}}

{{< hint warning >}}
Warnings look like this.
{{< /hint >}}

{{< hint info >}}
Information looks like this.
{{< /hint >}}

## Syllabus

- Fundamentals of performance engineering
- Tools: CPU topology and affinity
- The Roofline performance model
- Tools: Performance counters
- Technique: Vectorisation (SIMD programming)
- Technique: Data layout transformations

## Lecturer

The material on this website, and the website itself, were developed by
[Lawrence Mitchell](mailto:lawrence.mitchell@durham.ac.uk), who delivered the
course in a.y. 2020/2021 and 2021/2022. The current maintainer is [Massimiliano
Fasi](mailto:massimiliano.fasi@durham.ac.uk).
