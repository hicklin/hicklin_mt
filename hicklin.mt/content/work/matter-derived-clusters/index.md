+++
title = "Derived clusters and Mode Base"
description = "Designed the derived-cluster pattern for the Matter C++ SDK with lead engineers from Google and Apple, implemented Mode Base on it, and made the core SDK changes it required."
weight = 20

[extra]
# Add the photo of the members meeting talk here, then uncomment:
# local_image = "work/matter-derived-clusters/derived-cluster-pattern-talk.jpg"
+++

Matter defines several clusters that behave identically but carry distinct cluster
identifiers; the run and clean modes of a robot vacuum, a dishwasher's mode, a laundry
washer's mode. Each needs its own identity on the wire while sharing all of its behaviour.

The question was how the SDK should represent that. The straightforward answer, a separate
implementation per cluster, means the same logic is written and reviewed several times, and
every subsequent specification change has to be applied to each copy. In practice that
means the copies drift, and the ones nobody is actively working on are the ones that drift
silently.

## Designing the pattern

I worked with lead engineers from Google and Apple to design what became the derived-cluster
pattern: one base implementation holding the behaviour, instantiated per derived cluster
with its own identifier. One place to fix a bug, one place for a specification change to
land, and new derived clusters cost almost nothing to add.

Some of that design was argued out in public review threads, which has the useful property
that the reasoning is still there to read; the rest happened in one-to-one conversations
with Matter tech leads. I later presented the pattern to the wider membership at a Matter
members meeting.

## The core SDK changes it needed

Making the pattern work meant changing parts of the SDK outside my clusters, and that is
where most of the care went.

Mode Base needed attribute persistence that the existing API did not provide, so I expanded
it. On review and further thought, the expanded API was too easy to use incorrectly from a
cluster implementation, so I reverted it and introduced a `SafeAttributePersistenceProvider`
in its place. Reverting your own merged change to a widely used platform API is not a
comfortable thing to do, but shipping an interface that invites misuse across every future
cluster is worse.

The rest was allocation and lifetime discipline, because this code runs on constrained
devices. I replaced a `std::set` in Mode Base with an `IntrusiveList` to take dynamic
allocation out of the path, fixed a leak in delegate destruction, and made mode changes
check whether the requested mode was already active rather than doing the work regardless.

Alongside this I brought the Mode Select XML definitions into line with successive
specification revisions. Those pull requests carry the longest comment threads of anything
I worked on that year, which is a fair reflection of where the disagreements were.

## Evidence

All of the below are merged.

- [#27504](https://github.com/project-chip/connectedhomeip/pull/27504) — the Mode Base implementation, and the pattern itself
- [#27611](https://github.com/project-chip/connectedhomeip/pull/27611) — expanding the attribute persistence provider API
- [#28302](https://github.com/project-chip/connectedhomeip/pull/28302) — reverting that, and adding `SafeAttributePersistenceProvider`
- [#28163](https://github.com/project-chip/connectedhomeip/pull/28163) — replacing `std::set` with `IntrusiveList`
- [#28267](https://github.com/project-chip/connectedhomeip/pull/28267) — fixing a leak when destroying Mode Base delegates
- [#28610](https://github.com/project-chip/connectedhomeip/pull/28610) — not re-entering a mode that is already active
- [#26508](https://github.com/project-chip/connectedhomeip/pull/26508) and [#27249](https://github.com/project-chip/connectedhomeip/pull/27249) — tracking the specification through two revisions
- [#28575](https://github.com/project-chip/connectedhomeip/pull/28575) — reporting changes in supported modes

[All 79 of my merged pull requests to the Matter SDK](https://github.com/project-chip/connectedhomeip/pulls?q=is%3Apr+author%3Ahicklin+is%3Amerged).
