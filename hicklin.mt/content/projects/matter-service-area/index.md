+++
title = "Matter: The Service Area cluster"
description = "Implemented one of the harder parts of a global smart-home standard against a specification I helped design, delivered it to the release deadline, then ran the retrospective that changed how the next cycle was planned."
weight = 40

[taxonomies]
tags = ["C++", "Standards", "Technical leadership", "Test automation", "OSS"]

[extra]
# Candidate image: the members meeting recognition slide — check with the CSA
# whether it can be published before using it.
# local_image = "projects/matter-service-area/members-meeting-recognition.jpg"
+++

- **Role** — Lead Embedded Engineer at Dyson, contributing to the Matter SDK on behalf of a member company
- **Period** — February to September 2024
- **Outcome** — Shipped in Matter 1.4; 31 merged pull requests; recognised at a Matter members meeting

Matter is the smart-home interoperability standard, written and maintained by around 300
member companies including Apple, Google and Amazon. It is what lets a device from one
manufacturer work with an app from another. The standard is split into functional building
blocks called *clusters*, and every certified device implements them identically — so a
cluster's definition has to be agreed by the membership, implemented in a shared open-source
SDK that device makers build against, and covered by tests that certify a product conforms.

I implemented one of those clusters, Service Area, and was closely involved in designing
its specification.

## What it does

Service Area is what lets a device be told which parts of a home to operate in, and report
its progress through them. It is the cluster that makes "clean the kitchen and the hallway"
something you can ask a robot vacuum to do, in a way that works from any manufacturer's app.

It was the hardest thing I implemented on the SDK, and the closest I came to missing a
deadline.

## Specification

The specification document was owned and largely written by a colleague at iRobot. My
involvement was in its design — the meetings where the cluster's behaviour was worked out —
rather than in writing it. My own commits to the document are small and specific: renaming
two fields, removing an error condition that could not arise, editorial corrections.

Those changes came out of implementing the thing. Writing the code is what surfaced the
ambiguous field name and the impossible error, and the right place to fix them was the
specification rather than a workaround underneath it. The specification and the
implementation were being written at the same time, by people who talked to each other.

We started months before the specification went to ballot, on the reasoning that a cluster
this size would need the lead time. That was right about the lead time and wrong about what
early review would cover. Most of the early discussion settled peripheral questions — what
rooms should be called, what data structures should be named — while the core behaviour drew
serious scrutiny only once formal balloting began. So the consequential feedback arrived
late, with the least time available to act on it.

## Implementation

Two constraints shaped it. The cluster carries variable-length lists of named areas and
maps, and it runs on devices where allocating memory at runtime is something to avoid and
where buffer handling is where bugs live.

The interesting work was therefore at the boundaries. I built a wrapper type for area data
so its rules were enforced in one place instead of at every point of use, and a storage
delegate so that the application decides how the data is kept rather than the cluster
imposing it. Truncating over-long names correctly and consistently turned out to be a
general problem rather than mine alone, so I added a safe truncating copy to the SDK's own
string helpers and then pushed for its adoption across the codebase. I removed a use of
`memcpy` while fixing the logic for skipping an area mid-operation. Several of the fixes
listed below are cases where the cluster could report a state it was not actually in.

The specification kept moving while all this was happening: fields that had been allowed to
be empty no longer were, names changed, an error condition was dropped. Each change had to
land in four places at once — the specification, the machine-readable definition the SDK
generates code from, the implementation, and the tests — without any of them drifting apart.

## Tests

I contributed to the test plan, then got the cluster's certification tests working and
running automatically in CI against the reference application — the same arrangement I had
already set up for the robotic vacuum device type. That meant fixing the test scripts for
six of the cluster's test cases so that they passed and could run unattended.

This matters more than it sounds. Certification tests are how the standard's claims get
enforced on real products. Before, conformance was checked by someone running the tests by
hand, at scheduled interoperability events. Afterwards it was checked on every commit.

## August

Twenty-two of my pull requests merged in August 2024. That is what getting this cluster over
the deadline actually looked like.

The cause was structural rather than personal. The implementation of the balloted
specification sat in review past the point where new features had to be finalised, and the
deadlines for freezing the specification and freezing the SDK fell on the same day — which
leaves nowhere to put a specification change made two days before.

## The retrospective

Having spent a release cycle inside that, I documented the workflow problems as they
happened, then ran a retrospective with the other cluster developers to test whether what I
had seen was general rather than particular to me. It was. I presented the findings and a
set of recommendations to the standard's technical leads and executives.

The recommendations were about sequencing rather than working harder: stagger the
specification, definition and SDK freezes instead of landing them on one day; set soft
milestones so contributors and reviewers can tell whether they are on schedule; form
dedicated review groups for new features; let work that misses a cutoff continue into the
next release instead of being rushed; and write down the accepted implementation patterns so
review time goes on substance rather than re-arguing settled questions.

Some of this fed into how later cycles were planned.

I was recognised for this work at a Matter members meeting.

## Evidence

All merged. Links go to the pull requests themselves.

- [#33991](https://github.com/project-chip/connectedhomeip/pull/33991) — the Service Area implementation
- [#33752](https://github.com/project-chip/connectedhomeip/pull/33752) — the cluster definition the SDK generates from
- [#33569](https://github.com/project-chip/connectedhomeip/pull/33569) — shared data types for describing locations in a home
- [#34701](https://github.com/project-chip/connectedhomeip/pull/34701) — naming positions relative to a space
- [#34814](https://github.com/project-chip/connectedhomeip/pull/34814) — the area data wrapper
- [#35176](https://github.com/project-chip/connectedhomeip/pull/35176) — the storage delegate
- [#35360](https://github.com/project-chip/connectedhomeip/pull/35360) and [#35444](https://github.com/project-chip/connectedhomeip/pull/35444) — adding a safe truncating string copy to the SDK, then driving its adoption
- [#35075](https://github.com/project-chip/connectedhomeip/pull/35075) — skip-area logic, and removing a `memcpy`
- [#35722](https://github.com/project-chip/connectedhomeip/pull/35722) — checking for selected areas before acting
- [#34887](https://github.com/project-chip/connectedhomeip/pull/34887) — integrating the cluster into the reference robot vacuum application
- [#35326](https://github.com/project-chip/connectedhomeip/pull/35326) — the certification tests running in CI

[All 79 of my merged pull requests to the Matter SDK](https://github.com/project-chip/connectedhomeip/pulls?q=is%3Apr+author%3Ahicklin+is%3Amerged).
