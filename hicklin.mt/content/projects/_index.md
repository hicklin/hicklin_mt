+++
title = "Work"
sort_by = "weight"
template = "cards.html"
insert_anchor_links = "left"

[extra]
quick_navigation_buttons = true
+++

These are case studies, not posts. Each one is a piece of work: what the problem actually was,
what I decided, and what it cost. They are not in chronological order, they are arranged roughly by how well they show what I do.

Some of this work is open source, so you do not have to take my word for any of it: the pull
requests, the review threads and the arguments are linked. Some was done for clients and
cannot be shown, so those studies describe the design and say plainly what is confidential.

Four things recur across all of it, and they are what I would want to be judged on.

**The difference between a thing and the appearance of one.** A client-certificate mode that
demands a certificate and verifies nothing against anything. A test that reports success
without ever running the test. Last-write-wins quietly discarding the change made by the one
person who could actually see the machine. Most of what I catch is this, and most of it is
caught by asking what happens when a mechanism is wrong rather than when it is right —
[in a photo server](@/projects/immich-rpi-nix/index.md), [in a Bluetooth
stack](@/projects/ble-throughput-trouble/index.md), [in a
protocol](@/projects/air-quality-datalogger/index.md).

**Making the wrong thing difficult to express.** Where the choice is mine, I would rather a
mistake be unrepresentable than documented: [a message that cannot disagree with itself about
its own type](@/projects/sensoteq/index.md), [state that carries its own valid
range](@/projects/prototyping-platform/index.md), a network that stays shut until someone
deliberately opens it. It extends to interfaces other people have to use — on one occasion to
[withdrawing a change of mine that had already been
merged](@/projects/matter-derived-clusters/index.md), because it was too easy to use
incorrectly.

**Writing it down.** Specifications, pattern documentation, a book written for people who are
not engineers. The habit has moved over the years — the earliest protocol here was documented
after it was built, [the most recent was specified before anything was
written](@/projects/sensoteq/index.md) — but the reason has not changed: a design that exists
only in code cannot be argued with, and the arguments are where the value is.

**Fixing things where they are broken.** Upstream, or in the specification, rather than
patched locally and maintained privately forever. [Merged fixes in a Bluetooth host instead of
a fork](@/projects/ble-throughput-trouble/index.md); [field names and an impossible error
corrected in a standard](@/projects/matter-service-area/index.md) rather than worked around
underneath it; and [three years spent building the policy](@/projects/dyson-open-source/index.md)
that let anyone at one employer do this at all.

Where I am describing someone else's work, or a claim I could not support, the studies say so.
