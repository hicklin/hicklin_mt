+++
title = "Matter in Rust: cluster patterns"
description = "Identified a gap in an independent Rust implementation of the Matter standard, designed and documented the patterns for implementing cluster behaviour, and was granted a membership exemption to present the work at a members meeting."
weight = 15

[taxonomies]
tags = ["Rust", "Standards", "API design", "Documentation", "Technical leadership", "OSS"]
+++

- **Role** — Open-source contributor, unpaid. In my own time at first, then full time
- **Period** — Summer 2025 to January 2026
- **Outcome** — Four implementation patterns designed, documented and adopted; two clusters implemented; presented at the Matter members meeting in Barcelona, November 2025

Matter is the smart-home interoperability standard, written and maintained by around 300
member companies including Apple, Google and Amazon. It is what lets a device from one
manufacturer work with an app from another. The standard is split into functional building
blocks called *clusters*, and every certified device implements them identically.

The reference implementation everyone builds on is written in C++. `rs-matter` is an
independent implementation in Rust, under the same project umbrella — which matters because
these devices are network-facing, long-lived, rarely updated and built on constrained
hardware, which is close to a worst case for memory-safety bugs in C++.

Having spent two years working on the C++ SDK, I thought the move to Rust was the right one,
and I wanted to work on it. So I did, in my own time to begin with, and then full time for
several months after leaving my job.

## The gap

At the time, `rs-matter` concerned itself with the protocol and the data model but not with
cluster-specific behaviour. It could carry a correctly formed message about a light, but the
rules the standard lays down for how that light must actually behave were left to whoever was
building the device.

That is a reasonable place for a young project to stop, and the wrong place to stay. The
behaviour is where interoperability is won or lost, it is specified in detail, and leaving it
to each device maker means every one of them reimplements it and gets it subtly differently —
which is the problem the standard exists to solve. I made that case to the project's lead
developer, and then took on the work.

## Patterns before clusters

Clusters are not uniform. Some are plain data with no specified behaviour at all; some have
substantial logic; some are meaningfully coupled to each other. Implementing them one at a
time, each in whatever way suited it, would have produced an SDK that was different in every
corner.

So I designed a set of patterns first, graded by how much the standard demands of a given
cluster:

- **Simple handler** — clusters that are purely data, with no specified logic and no
  dependence on anything else. Most measurement clusters.
- **Implemented handler** — clusters whose behaviour is specified and lives in the SDK.
- **Hooks-based handler** — the same, but where part of the behaviour has to reach the actual
  device, so the SDK implements the specified logic and calls out to the application for the
  parts only it can know.
- **Coupled clusters** — clusters whose behaviour depends on the state of another cluster.

The useful property is that a contributor adding a cluster now starts by deciding which
pattern it falls under, rather than by inventing a structure. And someone using the SDK knows
what shape of work a given cluster will ask of them before they start.

## Two clusters, chosen for the hard case

I then implemented On/Off and Level Control. They look like the simplest clusters in the
standard — a switch and a dimmer — and they are not. They are coupled: what a level change is
allowed to do depends on the on/off state, turning the device on has to restore a level, and
the startup behaviour of one is defined in terms of the other. That coupling is among the more
awkward things the standard specifies, so implementing these two proved out the pattern that
mattered most rather than the one that was easiest.

They also exposed a problem worth solving properly. A real device's state changes for reasons
that have nothing to do with Matter — somebody presses the physical button on the lamp. The
cluster has to reflect that and report it correctly, so I designed an out-of-band API for
both clusters: a way for the application to tell the cluster that reality has changed
underneath it, rather than the cluster assuming it is the only thing in control.

## Documentation as the deliverable

The patterns were only worth having if other people could use them, so I wrote them up
properly: what each pattern is for, how to implement one as a contributor, how to use one as
a consumer of the SDK, with diagrams, and a table listing every cluster in the standard
against the pattern it falls under. It is in the repository rather than in a wiki, so it is
reviewed and it goes stale visibly.

I also set up reproducible Nix development environments for the project and fixed the
integration test runner to take a target flag, which is the sort of thing I do to a codebase
more or less on reflex.

## Barcelona

I presented this work with the project's lead developer at the Matter members meeting in
Barcelona in November 2025, with a live demonstration: a lamp driven over Matter by the Rust
implementation. By then I had left my job, so I was no longer there on behalf of a member
company and was not entitled to attend. The membership granted me an exemption on the
strength of the contributions.

{{ dimmable_image(src="rs-matter-talk-barcelona.jpg", alt="The opening slide of the talk projected at the Matter members meeting: the word rs-matter above the Rust logo, a row of hearts, and the Matter logo", full_width=true) }}

*The opening slide in Barcelona, November 2025.*

I am still working on `rs-matter` — currently a refactor of its error-handling API.

## Evidence

All merged, in a public repository.

- [Pattern documentation](https://github.com/project-chip/rs-matter/blob/main/docs/Matter_clusters-Implementation_usage_and_support.md) — the patterns, how to implement and use them, and the per-cluster support table
- [#304](https://github.com/project-chip/rs-matter/pull/304) — Level Control
- [#316](https://github.com/project-chip/rs-matter/pull/316) — On/Off, and the coupling between the two
- [#320](https://github.com/project-chip/rs-matter/pull/320) — separating "set the attribute" from "set the device" in the hooks trait
- [#324](https://github.com/project-chip/rs-matter/pull/324) and [#325](https://github.com/project-chip/rs-matter/pull/325) — the out-of-band APIs
- [#331](https://github.com/project-chip/rs-matter/pull/331) — the pattern documentation
- [#285](https://github.com/project-chip/rs-matter/pull/285) and [#303](https://github.com/project-chip/rs-matter/pull/303) — Nix development environments
- [#302](https://github.com/project-chip/rs-matter/pull/302) — target flag for the integration test runner

[All my commits to `rs-matter`](https://github.com/project-chip/rs-matter/commits?author=hicklin).
