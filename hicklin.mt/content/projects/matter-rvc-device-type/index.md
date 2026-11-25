+++
title = "Matter: The robotic vacuum device type"
description = "Owned a robot vacuum's definition in a global standard and the reference application the whole ecosystem tests against — and replaced conformance checking done by hand at scheduled events with tests that run on every commit."
weight = 30

[taxonomies]
tags = ["C++", "Standards", "Test automation", "Technical leadership", "OSS"]

[extra]
# Candidate image: a state diagram of the robot vacuum's operational states, drawn
# from the published specification. Public information, your own drawing. Check
# which release to draw from.
# local_image = "projects/matter-rvc-device-type/rvc-operational-states.svg"
+++

- **Role** — Senior Embedded Software Engineer at Dyson, contributing to the Matter SDK on behalf of a member company
- **Period** — August 2023 to February 2024
- **Outcome** — The reference robot vacuum application shipped in the SDK; its certification tests run in CI on every commit

Matter is the smart-home interoperability standard, written and maintained by around 300
member companies including Apple, Google and Amazon. It is what lets a device from one
manufacturer work with an app from another. The standard is split into functional building
blocks called *clusters*, and every certified device implements them identically — so a
cluster's definition has to be agreed by the membership, implemented in a shared open-source
SDK that device makers build against, and covered by tests that certify a product conforms.

A *device type* is the next layer up: the standard's description of a kind of product —
which clusters it must implement, and how they must behave together. I owned the robotic
vacuum device type in the SDK, and the reference application that goes with it.

The Operational State cluster underneath it belonged to someone else; there I contributed to
the implementation rather than owning the cluster.

## Operational State in the SDK

My contributions there were mostly about states the original implementation handled too
loosely. Pausing and resuming were permitted from states where they made no sense, so I
constrained them to the states where they are meaningful and wrote the tests that pin that
down. Operational errors were being handled incorrectly. I also added the command that sends
a robot vacuum back to its dock, on both the cluster and the device side.

The robot vacuum's variant of Operational State is a derived cluster, built on the pattern I
had designed earlier (see [Derived clusters and Mode Base](@/projects/matter-derived-clusters/index.md)).
A pattern is only useful if the people applying it understand why it is shaped the way it is,
so a good deal of my involvement here was explaining how it works and how to implement
against it, in reviews and in conversation, rather than writing the code myself.

## The device type and its reference application

The device type was the greater part of the work. Because a device type constrains how
clusters behave *together*, most of the engineering is in the seams: a run mode that may only
change in certain operational states, a clean mode that interacts with charging and docking,
start-up behaviour whose meaning shifted during the cycle.

Alongside it I built the reference application — the example implementation that the rest of
the ecosystem develops and tests against. That makes its correctness a shared concern rather
than mine alone: a bug in the reference application becomes a bug in everyone's understanding
of what the device type means. A fair number of the pull requests below are me finding and
fixing exactly that — docked and charging states that stayed set after they should have
cleared, a misleading error code, items left behind by changes to the standard.

## Four things that have to agree

The standard, the test plan, the implementation and the test scripts all moved during the
cycle, and a device type is only meaningful when all four say the same thing. I contributed
to the standard and the test plan alongside writing test scripts, which meant disagreements
surfaced as I wrote them rather than at a scheduled interoperability event.

The part with the longest reach is the least visible: getting the robot vacuum's
certification tests to run against the reference application in CI. Certification tests are
how the standard's claims get enforced on real products. Before, conformance was checked by
someone running the tests by hand, at scheduled events. Afterwards it was checked on every
commit. I also fixed the parts of the shared Python test infrastructure that stood in the
way, which other device types got for free.

## Evidence

All merged. Links go to the pull requests themselves.

- [#29103](https://github.com/project-chip/connectedhomeip/pull/29103) and [#29159](https://github.com/project-chip/connectedhomeip/pull/29159) — the reference robot vacuum application
- [#32079](https://github.com/project-chip/connectedhomeip/pull/32079) — running the certification tests against the reference application in CI
- [#31872](https://github.com/project-chip/connectedhomeip/pull/31872) — enabling those tests in CI
- [#31429](https://github.com/project-chip/connectedhomeip/pull/31429) — a new certification test written from scratch, and a substantial rewrite of another
- [#30795](https://github.com/project-chip/connectedhomeip/pull/30795) — restricting pause and resume to states where they are meaningful
- [#28942](https://github.com/project-chip/connectedhomeip/pull/28942) — incorrect handling of operational errors
- [#31242](https://github.com/project-chip/connectedhomeip/pull/31242) and [#31289](https://github.com/project-chip/connectedhomeip/pull/31289) — the return-to-dock command, cluster and device side
- [#29257](https://github.com/project-chip/connectedhomeip/pull/29257) — docked and charging states failing to clear
- [#31451](https://github.com/project-chip/connectedhomeip/pull/31451) — removing items deprecated by changes to the standard
- [#31866](https://github.com/project-chip/connectedhomeip/pull/31866) — a fix to the shared Python test infrastructure

[All 79 of my merged pull requests to the Matter SDK](https://github.com/project-chip/connectedhomeip/pulls?q=is%3Apr+author%3Ahicklin+is%3Amerged).
