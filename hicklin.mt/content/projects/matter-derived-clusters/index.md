+++
title = "Matter: Derived clusters and Mode Base"
description = "Designed an abstraction with lead engineers from Google and Apple so a family of near-identical parts of a global standard share one tested implementation."
weight = 20

[taxonomies]
tags = ["C++", "Standards", "API design", "Technical leadership", "OSS"]
+++

- **Role** — Senior Embedded Software Engineer at Dyson, contributing to the Matter SDK on behalf of a member company
- **Period** — May to October 2023
- **Outcome** — Mode Base shipped on the pattern; presented to the membership at the Matter members meeting in Boston, June 2023

Matter is the smart-home interoperability standard, written and maintained by around 300
member companies including Apple, Google and Amazon. It is what lets a device from one
manufacturer work with an app from another. The standard is split into functional building
blocks called *clusters*, and every certified device implements them identically — so a
cluster's definition has to be agreed by the membership, implemented in a shared open-source
SDK that device makers build against, and covered by tests that certify a product conforms.

This is about how that SDK represents a particular family of clusters, and the design work
behind it.

## The problem

Matter defines several clusters that behave identically but need distinct identities on the
wire — the run and clean modes of a robot vacuum, a dishwasher's mode, a laundry washer's
mode. Each is a separate thing as far as the standard is concerned, while sharing all of its
behaviour.

The straightforward way to implement that is a separate copy per cluster. It means the same
logic is written and reviewed several times, and every later change to the standard has to
be applied to each copy. In practice the copies drift, and the ones nobody is actively
working on are the ones that drift silently.

## Designing the pattern

I worked with lead engineers from Google and Apple to design what became the derived-cluster
pattern: one implementation holding the behaviour, instantiated once per derived cluster with
its own identity. One place to fix a bug, one place for a change in the standard to land,
and new members of the family cost almost nothing to add.

Some of that design was argued out in public review threads, which has the useful property
that the reasoning is still there to read; the rest happened in one-to-one conversations with
Matter tech leads. I presented the pattern to the wider membership at the Matter members
meeting in Boston in June 2023.

{{ dimmable_image(src="matter-boston-talk.jpg", alt="Presenting to a room at the Matter members meeting, pointing at a projected slide comparing the old and new ways of accessing cluster attributes") }}

*Presenting the pattern in Boston, June 2023. The slide is the before-and-after: the old way
of reaching an attribute, and the interface that replaced it. Photo by Matt Hazley.*

## The core SDK changes it needed

Making the pattern work meant changing parts of the SDK outside my own clusters, and that is
where most of the care went.

The implementation needed to save values so that they survive a power cycle, in a way the
existing mechanism didn't support — so I extended it. On review and further thought, the
extended interface was too easy to use incorrectly from inside a cluster, so I reverted it
and introduced a deliberately safer one in its place. Reverting your own merged change to a
widely used platform interface is not comfortable, but shipping something that invites misuse
by every cluster written afterwards is worse.

The rest was memory discipline, because this code runs on constrained devices where
allocating at runtime is to be avoided. I replaced a standard set container with a list whose
links live inside the elements themselves, removing allocation from that path; fixed a leak
when tearing down the per-device object a cluster calls into; and made a mode change check
whether the requested mode was already active instead of doing the work regardless.

Alongside this I brought the machine-readable cluster definitions, which the SDK generates
code from, into line with two successive revisions of the standard. Those pull requests carry
the longest comment threads of anything I worked on that year, which is a fair reflection of
where the disagreements were.

## Evidence

All merged. Links go to the pull requests themselves.

- [#27504](https://github.com/project-chip/connectedhomeip/pull/27504) — the Mode Base implementation, and the pattern itself
- [#27611](https://github.com/project-chip/connectedhomeip/pull/27611) — extending the attribute persistence interface
- [#28302](https://github.com/project-chip/connectedhomeip/pull/28302) — reverting that, and adding the safer replacement
- [#28163](https://github.com/project-chip/connectedhomeip/pull/28163) — removing allocation from a hot path
- [#28267](https://github.com/project-chip/connectedhomeip/pull/28267) — fixing a leak on teardown
- [#28610](https://github.com/project-chip/connectedhomeip/pull/28610) — not re-entering a mode that is already active
- [#26508](https://github.com/project-chip/connectedhomeip/pull/26508) and [#27249](https://github.com/project-chip/connectedhomeip/pull/27249) — tracking two revisions of the standard
- [#28575](https://github.com/project-chip/connectedhomeip/pull/28575) — reporting changes in the supported set of modes

[All 79 of my merged pull requests to the Matter SDK](https://github.com/project-chip/connectedhomeip/pulls?q=is%3Apr+author%3Ahicklin+is%3Amerged).
