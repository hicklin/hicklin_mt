+++
title = "Ultrasonic data-logger"
description = "Greenfield design and development of an ultrasonic data-logger, and the communication specification and protocol architecture for the system around it."
weight = 10

[extra]
# local_image = "work/sensoteq/measurement_timing.svg"
+++

A nine-month fixed-term contract with Sensoteq, designing and building a greenfield
ultrasonic data-logger, and architecting the communications across the system it sits in.

## Specifying before building

The logger did not exist in isolation. It sat between microcontrollers sampling beneath it
and cloud services above it, with separate teams working on each part. The interesting
problem was not the signal processing; it was that the boundaries between those components
were undefined, and each team was working to its own assumptions about what the others
would send.

So I wrote the specification first. A version-controlled document covering the behaviour
and communication interface of every component in the system, with state machines, sequence
diagrams, and normative prose using SHALL, SHOULD and MAY to separate mandatory
requirements from recommendations. It was written in asciidoc with PlantUML, lived in git,
and was reviewed through pull requests like any other source.

I don't treat a specification as documentation produced after the fact. It is the thing
that lets two engineers working on different components disagree and resolve it by
reading, rather than by discovering the mismatch on hardware weeks later.

## A layered protocol

I designed the communications as three layers: a component layer holding each component's
messages, channels and behaviour; a framing layer common to the whole system; and a
transport layer. Messaging patterns map onto transports by rule rather than by preference,
so that there is one correct answer to how any two components should talk.

The framing layer exists to solve a specific problem. Cap'n Proto messages are not
self-describing, so a receiver has to already know the structure it is unmarshalling into.
Rather than carry a separate type tag that could disagree with its payload, I made the root
message a union of per-component message groups, each itself a union of that component's
message types. The discriminant and the data are therefore the same object, and a message
whose declared type doesn't match its contents is not representable.

I chose Cap'n Proto over Protocol Buffers for three reasons: zero-copy deserialisation,
which mattered because some of these messages are large; its type system; and the quality
of its Rust support.

## Making the specification difficult to bypass

A specification that exists only in prose decays. I wrote wrapper libraries in both Rust
and Go over the code generated from the schemas, giving each language the same ergonomic
API and, more importantly, the same validation. Message types validate their inputs on
construction and return an error instead of yielding a malformed message, so the
constraints the specification states are enforced at the point of use rather than trusted
to each caller.

Generating both libraries from one set of schemas keeps the two implementations honest
about the same contract. CI then checks that the generated code is current, runs the unit
tests, and applies static analysis to both languages with exhaustive error handling and
branch coverage enforced. A rule nobody checks automatically is a rule the codebase will
quietly stop following.

## The sampling engine and data processor

I designed and developed the sampling engine as a multi-threaded Rust application on
embedded Linux, collecting and processing data from two microcontrollers running at
different sample rates, along with the data processor downstream of it. The protocol for
talking to the microcontrollers is a library crate that implements both ends, so the same
code can be used in Rust firmware on the microcontroller side. I also built an
experimental `no_std` firmware crate to exercise that.

This part of the work meant a lot of time with an oscilloscope. Debugging across the signal
and firmware boundary, making hardware modifications, and unblocking engineers on timing and
signal integrity issues.

## Toolchains

I introduced Nix flake development environments, which were adopted across the team and the
CI pipeline, pinned so that local development and automated builds run identical
toolchains. It removes a whole category of argument about whose machine a failure belongs
to.

I mentored the team throughout via detailed pull request reviews and ad-hoc conversations.

## Stack

Rust, Go, Cap'n Proto, MQTT, NNG, embedded Linux, Nix, asciidoc, PlantUML.
