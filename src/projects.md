---
title: Projects
layout: page
---

These are some of the open-source programming projects I am, or have been,
working on. All projects listed below, and many more, are available at [my
GitHub profile page]( https://github.com/owickstrom).

## Hyper

The goal of *Hyper* is to make use of row polymorphism, and other tasty type
system features in [PureScript](http://www.purescript.org/), to enforce
correctly stacked middleware in HTTP server applications. All effects of
middleware should be reflected in the types to ensure that otherwise common
mistakes cannot be made. This is one of my most recent projects, which I have
been wanting to do for a long time. Please have a look at the [the Hyper design
document](https://owickstrom.github.io/hyper/) for more information.

## The Oden Programming Language

As described at [oden-lang.github.io](https://oden-lang.github.io), *Oden is an
experimental, statically typed, functional programming language, built for the
Go ecosystem.* I worked on the language for the majority of 2016, rounding off
in October. Why I stopped working on Oden is explained in greater detail in
[Taking a Step Back from
Oden](/programming/2016/10/10/taking-a-step-back-from-oden.html). The compiler
is written in Haskell, and I am very satisified with the readability of the
source code, and the correctness of the compiler. I hope that the source code
can be of use, or serve as inspiration, to others.

## DataFlow

During my work at Sony Mobile, I created [DataFlow], a tool that renders
graphs using a declarative markup. It is built around the DFD format, but also
supports sequence diagrams and structured data output. We used it to document
our service integrations and security requirements between separate systems,
and integrated it in to our bigger documentation workflow. The software is
written in Haskell and has seen very few bugs.