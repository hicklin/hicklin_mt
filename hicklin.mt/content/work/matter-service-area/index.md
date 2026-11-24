+++
title = "The Service Area cluster"
description = "Owned the Matter Service Area cluster from specification through implementation and certification tests, delivered to the 1.4 deadline, and ran the retrospective that changed how the next cycle was planned."
weight = 40

[extra]
# Candidate image: the members meeting recognition slide — check with the CSA
# whether it can be published before using it.
# local_image = "work/matter-service-area/members-meeting-recognition.jpg"
+++

Service Area lets a device be told which parts of a home to operate in and report progress
through them — the cluster that makes "clean the kitchen and the hallway" a thing a robot
vacuum can be asked to do. I owned it, from the specification through the SDK implementation
and the certification tests, and it shipped in Matter 1.4.

This was the one where I was most involved in the specification itself rather than
implementing someone else's. It is also the hardest implementation I did on the SDK.

## Specification

The work started months before the ballot, on the reasoning that a cluster of this size
would need the lead time. That turned out to be right about the lead time and wrong about
what the early review would cover: most of the early discussion settled peripheral
questions — the names of rooms, the names of structures — while the core behaviour attracted
serious scrutiny only once balloting began. A lot of consequential feedback therefore arrived
late, which is the sort of thing you can only really see in hindsight and across a whole
cycle.

## Implementation

Two constraints shaped it. The cluster carries variable-length lists of named areas and
maps, and it runs on devices where dynamic allocation is something to be avoided and buffer
handling is where the bugs live.

So the interesting parts were the boundaries. I built a wrapper type for area structures to
keep their invariants in one place rather than at every call site, and a memory delegate so
that storage decisions were the application's to make rather than the cluster's. Name
truncation needed to be correct and consistent, which led to adding a general
`CopyCharSpanToMutableCharSpanTruncate` to the SDK's own span utilities and then driving its
adoption, since the bug it prevents was not unique to my cluster. I removed a use of
`memcpy` while fixing the skip-area logic. Several fixes in the list below are me finding
state the server could report inconsistently and closing it off.

The specification kept moving throughout: nullable qualities removed, field names changed,
an error condition dropped. Each of those had to land in the XML, the implementation, the
test plan and the test scripts without the four drifting apart.

## Tests

I contributed to the test plan and implemented the SEAR test scripts, then got them running
in CI against the reference application, the same arrangement I had set up for the robotic
vacuum device type. The PICS definitions needed keeping current alongside them.

## August

Twenty-two of my pull requests merged in August 2024. That is what getting this cluster
over the feature cutoff actually looked like, and I would rather state the number than
describe it. The cause was structural rather than personal: the implementation of the ballot
specification sat in review past the cutoff, and the specification and SDK freeze fell on the
same day, which leaves no room for a specification change made two days before the deadline.

## The retrospective

Having spent a release cycle inside that, I documented the workflow problems as they
happened and then ran a retrospective with the other cluster developers to check whether what
I had seen was general. It was. I presented the findings and a set of recommendations to the
Matter technical leads and executives.

The recommendations were about sequencing rather than effort: stagger the specification, XML
and SDK freezes instead of landing them together; set soft milestones so contributors and
reviewers can tell whether they are on schedule; constitute dedicated review groups for new
features; allow work that misses a cutoff to continue into the next release rather than
being rushed; and write down the accepted SDK patterns so that review time goes on substance
instead of re-litigating settled questions.

Some of this fed into how subsequent cycles were planned. It is the contribution I would
point to first if asked what I did beyond writing code, because the cluster helped one
release and the process affects every contributor in every release after it.

I was recognised for this work at a Matter members meeting.

## Evidence

All merged.

- [#33991](https://github.com/project-chip/connectedhomeip/pull/33991) — the Service Area server implementation
- [#33752](https://github.com/project-chip/connectedhomeip/pull/33752) — the cluster XML definition
- [#33569](https://github.com/project-chip/connectedhomeip/pull/33569) — common location data types, used beyond this cluster
- [#34701](https://github.com/project-chip/connectedhomeip/pull/34701) — the relative position namespace
- [#34814](https://github.com/project-chip/connectedhomeip/pull/34814) — the area structure wrapper
- [#35176](https://github.com/project-chip/connectedhomeip/pull/35176) — the memory delegate
- [#35360](https://github.com/project-chip/connectedhomeip/pull/35360) and [#35444](https://github.com/project-chip/connectedhomeip/pull/35444) — adding a truncating span copy to the SDK, then driving its adoption
- [#35075](https://github.com/project-chip/connectedhomeip/pull/35075) — skip-area logic, and removing a `memcpy`
- [#35722](https://github.com/project-chip/connectedhomeip/pull/35722) — checking for selected areas before acting
- [#34887](https://github.com/project-chip/connectedhomeip/pull/34887) — integrating Service Area into the RVC reference application
- [#35326](https://github.com/project-chip/connectedhomeip/pull/35326) — the SEAR certification tests running in CI

[All 79 of my merged pull requests to the Matter SDK](https://github.com/project-chip/connectedhomeip/pulls?q=is%3Apr+author%3Ahicklin+is%3Amerged).
