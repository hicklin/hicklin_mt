+++
title = "Ultrasonic data-logger"
description = "Specified a whole system's communications before building it, designed so that a malformed message cannot be constructed, then built the multi-threaded Rust application at the centre of it."
weight = 10

[taxonomies]
tags = ["Rust", "Go", "Embedded Linux", "Protocol design", "Specification authoring", "Nix", "Technical leadership"]
+++

- **Role** — Embedded Systems Architect, nine-month fixed-term contract, remote
- **Period** — January to September 2026
- **Outcome** — Specification, protocol and sampling engine delivered; the Nix development environments were adopted by the whole team and the CI pipeline

The device is an industrial data-logger. It sits on machinery, samples ultrasonic data from
it, and sends measurements on to a cloud service. Inside, it is not a single program:
several processes run on embedded Linux, talking to microcontrollers doing the actual
sampling below them and to cloud services above them, with separate teams owning different
parts.

My contract covered two things — the communications across that whole system, and the
application at the centre of it that collects and processes the samples.

## Specifying before building

The interesting problem was not the signal processing. It was that the boundaries between
all those parts were undefined, and each team was working to its own assumptions about what
the others would send.

So I wrote the specification first: a document covering the behaviour and communication
interface of every component in the system, with state machines, sequence diagrams, and
prose that uses *shall*, *should* and *may* in the formal sense, so that a mandatory
requirement is visibly distinct from a recommendation. It was written in AsciiDoc with
diagrams generated from PlantUML source, which means the whole document — prose and
diagrams alike — lived in git and was reviewed through pull requests like any other source.

I don't treat a specification as documentation produced after the fact. It is the thing that
lets two engineers working on different components disagree and resolve it by reading,
rather than by discovering the mismatch on hardware weeks later.

## One protocol, end to end

Messages are defined and serialised with Cap'n Proto: you declare message structures in a
schema file and generate the code to read and write them, in any supported language. I
chose it over Protocol Buffers for three reasons. Fields can be read directly out of the
received bytes rather than being unpacked into new objects first, which matters because some
of these messages are large; its type system suited the job; and its Rust support is good.

I designed the communications as three layers: each component's own messages and behaviour
at the top, a framing layer common to the whole system beneath that, and the transport
underneath. Two transports are in use — a message broker for publish/subscribe and
request/response traffic, and a broker-less socket library for queued data streams — and
which one a given interaction uses is fixed by rule, not left to preference, so there
is one correct answer to how any two components should talk.

## A message that cannot lie about itself

The framing layer solves a specific problem. Cap'n Proto messages do not describe
themselves, so a receiver has to already know what structure it is decoding into. The
obvious fix is to send a type tag alongside the payload — but then you have two things that
can disagree, and eventually will.

Instead I made the message a nested choice: the root says which component a message belongs
to, and that in turn says which of that component's messages it is, with the contents
attached. The tag and the data are therefore the same object. A message whose declared type
doesn't match its contents is not something you can construct.

## Making the specification difficult to bypass

A specification that exists only in prose decays. I wrote libraries in both Rust and Go that
wrap the code generated from the schemas, giving each language the same ergonomic API and,
more importantly, the same validation. Message types check their inputs as they are built
and return an error rather than yielding a malformed message, so the constraints the
specification states are enforced where messages are created instead of being left to each
caller to remember.

Generating both libraries from one set of schemas holds the two implementations to
the same contract. CI then checks that the generated code is up to date with the schemas,
runs the tests, and applies static analysis to both languages with exhaustive error handling
and branch coverage enforced. A rule nobody checks automatically is a rule the codebase will
quietly stop following.

## The sampling engine

I designed and built the sampling engine as a multi-threaded Rust application on embedded
Linux, collecting and processing data from two microcontrollers running at different sample
rates, along with the data processor downstream of it.

The protocol for talking to those microcontrollers is a library crate that implements both
ends of the conversation, so the same code can be used in Rust firmware on the
microcontroller side instead of being reimplemented against the same document. I also built an
experimental firmware crate, running without an operating system, to exercise exactly that.

This part of the work meant a lot of time with an oscilloscope — debugging across the signal
and firmware boundary, making hardware modifications, and unblocking engineers on timing and
signal integrity problems.

## Toolchains

I introduced Nix development environments, which were adopted across the team and the CI
pipeline, pinned so that local development and automated builds run identical toolchains. It
removes a whole category of argument about whose machine a failure belongs to.

I mentored the team throughout, through detailed pull request reviews and ad-hoc
conversations.

## Stack

Rust, Go, Cap'n Proto, MQTT, NNG, embedded Linux, Nix, AsciiDoc, PlantUML.
