+++
title = "The robotic vacuum device type"
description = "Owned the Matter robotic vacuum device type and its reference example application, contributed to the Operational State SDK implementation, and got the certification tests running against the app in CI."
weight = 30

[extra]
# Candidate image: a PlantUML state diagram of the RVC operational states, drawn
# from the published 1.3 specification. Public information, your own drawing.
# local_image = "work/matter-rvc-device-type/rvc-operational-states.svg"
+++

I owned the robotic vacuum device type in the Matter SDK and the reference example
application for it. The Operational State cluster underneath it belonged to someone else;
there I contributed to the SDK implementation rather than owning the cluster.

## Operational State in the SDK

My contributions to Operational State were mostly about states that the original
implementation handled too loosely. Pause and resume were permitted from states where they
made no sense, so I constrained them to the compatible states and wrote the tests that pin
that down. Operational errors were being handled incorrectly in a way that could leave a
device reporting a state it was not in. I also added the `GoHome` command on the RVC
variant of the cluster, on both the cluster and the device side.

Operational State is a derived cluster, built on the pattern I had
designed earlier (see [Derived clusters and Mode Base](@/work/matter-derived-clusters/index.md)).
A pattern is only useful if the people who have to apply it understand why it is shaped the
way it is, so a good deal of my involvement here was explaining how it works and how to
implement against it, in reviews and in conversation, rather than writing the code myself.

## The device type and its example app

The device type work was the greater part of it. A device type in Matter is a composition
of clusters with constraints on how they behave together, so most of the engineering is in
the seams: a run mode that may only change in certain operational states, a clean mode
that interacts with charging and docking, startup modes whose meaning shifted twice during
the cycle.

Alongside it I built the reference example application, which is what the rest of the
ecosystem develops and tests against. That makes its correctness a shared concern rather
than mine alone — a bug in the reference app becomes a bug in everyone's understanding of
the device type. A fair number of the pull requests below are me finding and fixing exactly
that: docked and charging states that stayed true after they should have cleared, a
misleading error code, deprecated items left behind by specification changes.

## Four things that have to agree

Specification, test plan, SDK implementation and test scripts all moved during the cycle,
and a device type is only meaningful when all four say the same thing. I contributed to the
specification and test plan alongside implementing the test scripts, which meant the
disagreements surfaced as I wrote them rather than at a test event.

The piece I am most pleased with is the least visible: getting the RVC certification tests
to run against the example application in CI. Before that, agreement between the app and
the test plan was established by someone running the tests by hand and only at test events.
Afterwards it was established on every commit. I also fixed the parts of the shared Python
test infrastructure that stood in the way, which other device types got for free.

## Evidence

All merged.

- [#29103](https://github.com/project-chip/connectedhomeip/pull/29103) and [#29159](https://github.com/project-chip/connectedhomeip/pull/29159) — the RVC example application
- [#32079](https://github.com/project-chip/connectedhomeip/pull/32079) — running the RVC certification tests against the example app in CI
- [#31872](https://github.com/project-chip/connectedhomeip/pull/31872) — enabling the RVC Python tests in CI
- [#30795](https://github.com/project-chip/connectedhomeip/pull/30795) — restricting Operational State pause and resume to compatible states
- [#31429](https://github.com/project-chip/connectedhomeip/pull/31429) — tests for those states
- [#28942](https://github.com/project-chip/connectedhomeip/pull/28942) — incorrect handling of operational errors
- [#31242](https://github.com/project-chip/connectedhomeip/pull/31242) and [#31289](https://github.com/project-chip/connectedhomeip/pull/31289) — the RVC `GoHome` command, cluster and device side
- [#29257](https://github.com/project-chip/connectedhomeip/pull/29257) — docked and charging states failing to clear
- [#31451](https://github.com/project-chip/connectedhomeip/pull/31451) — removing deprecated RVC items after specification changes
- [#31866](https://github.com/project-chip/connectedhomeip/pull/31866) — `--app-pid` flag for the shared Python test support

[All 79 of my merged pull requests to the Matter SDK](https://github.com/project-chip/connectedhomeip/pulls?q=is%3Apr+author%3Ahicklin+is%3Amerged).
