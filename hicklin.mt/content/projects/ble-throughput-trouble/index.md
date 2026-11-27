+++
title = "How much will Bluetooth Low Energy carry?"
description = "Took a question nobody could answer — how much data will Bluetooth Low Energy actually carry — down to the packet level, fixed what was wrong upstream, and left behind a worked example and the theory to use it."
weight = 50

[taxonomies]
tags = ["Rust", "Embedded Rust", "Documentation", "OSS"]
+++

- **Role** — Lead Embedded Systems Engineer. Investigation for a product team, contributed upstream under my employer's open-source process
- **Period** — December 2024 to March 2025
- **Outcome** — Feasibility proven to the product team; three pull requests merged upstream, including a high-throughput example and a written guide to the theory behind it; two defects reported, one of them in the project's own test suite

My team was asked whether a product could stream a sustained, high-bandwidth feed of data to
a phone. The device had both Wi-Fi and Bluetooth Low Energy, and we proposed Bluetooth —
mainly on security and user experience grounds.

Bluetooth Low Energy establishes its connections securely as part of the protocol itself:
the two devices pair and agree encryption before any application data moves, and that
machinery is specified rather than left to whoever writes the product. Getting comparable
guarantees over Wi-Fi would have meant the device standing up its own access point for a
phone to join, which is both more steps for a user to get wrong and a period during which
the device is advertising a network that anyone nearby can attempt to join. Being short
range helps as well: an attacker has to be close enough to be noticed.

That left an awkward question. Bluetooth Low Energy was designed for small, infrequent
messages — a heart-rate reading, a button press, a sensor value every few seconds. A
continuous high-rate stream is the opposite. Nothing in the documentation tells you how much data it will carry, because
the answer is not a number: it depends on a stack of configuration choices at different
layers of the protocol, several of which interact, and some of which are negotiated between
the two devices at connection time rather than chosen by you.

So the honest answer to "can we do this?" was "nobody here knows, and the specification will
not tell us." The only way to get a trustworthy answer was to go and measure.

## Finding the ceiling

I spent weeks at the packet level: two development boards, an Ellisys Bluetooth analyser,
and a long series of experiments changing one parameter at a time to see what each one
actually cost. How often the two devices are allowed to talk, how much they may say in each
exchange, how a large message gets chopped up for transmission and reassembled at the far
end, and which radio mode is in use — each has a throughput consequence, and the consequences
are not independent.

This is genuinely confusing rather than merely unfamiliar. There are three different size
limits involved, with names close enough to swap without noticing, and working out which one
applied where took a careful back-and-forth with the project's maintainer in one of my pull
request threads. The naming in this part of the specification is a trap, and the trap is what
the eventual documentation had to address.

We got it to around 176 kB/s sustained — roughly 1.4 Mbit/s — which was enough to demonstrate
a working, secure stream to the product manager at the rate the product needed.

{{ dimmable_image(src="max-ble-throughput.png", alt="A Bluetooth protocol analyser trace showing packets sent back to back across an 80 millisecond window at 176 kB/s") }}

*Peak measured throughput on the analyser: 176 kB/s across an 80 ms window, with the packets
back to back and almost no idle time left on the link.*

## Fixing it where it was broken

Three things were wrong in the open-source Bluetooth host implementation we were building
on, and I fixed them there rather than in our own copy.

The first was a two-character bug with a real consequence. The size limit passed to the send
call was being set to the payload length, which is always wrong, because encoding adds four
to six bytes of header in front of the payload. Any send at the stated maximum would fail.
Three lines changed, in two files, after a conversation with the maintainer in which we
established which of the three size limits was the correct one to use.

The second was a gap rather than a fault: the project had examples for several
configurations but not for the one that used a serial Bluetooth adapter, which is the setup
most people reaching for high throughput on a desktop will have.

The third I could only report. Running the same example across two of one chip variant
failed above a particular payload size, while the same code across two *different* variants
worked — including at much larger sizes. I wrote it up with the cases that worked and the
cases that did not, traced the failure down to the specific call that returned a buffer-full
error, and offered a hypothesis about a mismatch between two layers' maximum sizes. That
report pulled in maintainers from the chip support project as well, and the discussion
established it was a known limitation there rather than a bug in the Bluetooth host.

## A test that only looked like it passed

While working on this I noticed that the project's main integration test passed in about two
seconds and printed almost nothing. It was passing because of how its timeout was written:
the result was treated as success before either side of the connection had the chance to
finish, so the test reported a pass without ever having run the thing it tested.

I reported it with the log that gives it away. The maintainer fixed it the same day.

I did not write that fix, and I am not claiming it. But a test suite that reports success
without testing anything is worse than having no test, because it actively tells you not to
look — and this had been running green in continuous integration for some time. It is the
same failure mode I spend a lot of my time hunting: the difference between a test and the
appearance of one.

## What I wanted to leave behind

The fix for "nobody knows what throughput Bluetooth Low Energy gives you" is not a number in
my notebook. It is a worked example someone else can run.

So the last contribution was the largest: a high-throughput example across several chip
families, with a detailed guide covering the Bluetooth theory needed to choose the right
configuration for a given application — which parameters matter, what each one trades away,
and how they interact.

Whatever the product went on to do, the upstream work does not depend on it: anyone asking
the same question now starts from a working example rather than from weeks with a
packet sniffer. That is the whole argument for contributing upstream rather than patching
locally, and it is why I spent three years at the same company arguing for a process that
made it possible to do so — [its own piece of work](@/projects/dyson-open-source/index.md).

## Other contributions in the same spirit

Smaller, but the same instinct — fix it once, in the place where everyone gets the fix:

- Two additions to **heapless**, the allocation-free data structure library used across
  embedded Rust: equality comparison for its double-ended queue, and fallible conversion
  from a fixed-size array. The second is a small story in itself: the original pull request
  stalled for months behind a change request from a reviewer who had become inactive, so I
  closed it and opened a fresh one, which was reviewed and merged.
- A documentation correction to **nix**, the Rust bindings to the POSIX system calls, where
  the example for POSIX message queues did not explain the system limits that will stop it
  working.

## Stack

Rust, embedded Rust, Bluetooth Low Energy, Ellisys Bluetooth analysers, Wireshark, ESP32, HCI.

## Evidence

- [Fix for the send size limit](https://github.com/embassy-rs/trouble/pull/256) — three lines, and the thread establishing which limit was correct
- [Missing serial HCI examples](https://github.com/embassy-rs/trouble/pull/291)
- [High throughput example and guide](https://github.com/embassy-rs/trouble/pull/319) — the example, the theory, and the review
- [Payload size failure across chip variants](https://github.com/embassy-rs/trouble/issues/260) — the investigation as I reported it
- [The test that was a false pass](https://github.com/embassy-rs/trouble/issues/283)
- heapless: [equality for Deque](https://github.com/rust-embedded/heapless/pull/521), [conversion from an array](https://github.com/rust-embedded/heapless/pull/591)
- nix: [message queue documentation](https://github.com/nix-rust/nix/pull/2670)
