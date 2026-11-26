+++
title = "Air quality logging for Breathe London"
description = "Took over an unreadable codebase, made it legible, then designed the protocol that let two people reconfigure an offline instrument without either silently overwriting the other."
weight = 19

[taxonomies]
tags = ["C++", "Python", "Embedded Linux", "Yocto", "Protocol design", "Technical leadership"]

[extra]
# Image: a pollution map from the public Breathe London pilot data, or a
# photograph of an instrumented vehicle. The pilot data is published under the
# Open Government Licence. Nothing from the codebase can be used.
+++

- **Role** — Systems Developer. I owned everything running on the device: instrument protocols, data collection, processing and validation. Hardware was designed by a third party against requirements I compiled and reviewed
- **Period** — February 2018 to January 2020
- **Outcome** — Built as a product for environmental monitoring and deployed as the logging platform for the Breathe London pilot and a comparable study in Utrecht. Development ended when the company was acquired

[Breathe London](https://web.archive.org/web/20240912094503/https://breathelondon.edf.org/about.html)
was a two-year pilot led by
Environmental Defense Fund Europe with the Mayor of London, built to find out where London's
air is actually dangerous rather than where it was convenient to put a monitoring station.
Part of it was static: around a hundred sensor pods on lamp posts. The other part was
mobile — two Google Street View cars carrying reference-grade scientific instruments, driven
over roughly 600 eight-hour shifts between autumn 2018 and autumn 2019, taking a reading
every thirty metres or so.

My employer supplied the instrumentation, and I was responsible for the data-logger: the
industrial computer that talks to each scientific instrument in its own protocol, collects
and timestamps and validates what comes back, and gets it to a cloud database.

It was being built as a product — for scientists and environmental agencies running fleets of
these instruments, in fixed stations — and it was not finished when
Breathe London came along. I argued that it should be used regardless: the campaign needed a
logger on a timescale that left no room to build one, and ours was the closest thing that
existed. So the design was never shaped around this deployment. It was shaped around the
product, and this deployment turned out to be one it already fit.

For the mobile campaign that meant pairing every measurement with a position from GPS, which
turns clock accuracy from a bookkeeping concern into a spatial one: a drifting clock puts the
reading somewhere the car never was. The campaign build grew time synchronisation from the
GPS clock, including a correction for one instrument whose own firmware could not be trusted
to keep time.

It also meant that if the logger stopped working, that shift's data was gone — and a shift
was a car and a driver in London traffic for eight hours.

## Arriving as the user rather than the author

I was hired because I had already solved this problem once, from the other side. Running a
university air quality laboratory, I had spent two years replacing the previous generation of
this very logger with a system of my own in Python — more capable than the thing it replaced,
and useful enough that when I demonstrated it to the manufacturer they wanted me on the team.

So I arrived knowing the instruments, the measurements and the people who depend on them
about as well as anyone could. I had also never written a line of C or C++.

## Inheriting something unreadable

I joined in February 2018 and took the project over in May. It had been started by a
contractor, and it was impenetrable — not badly intentioned, just undocumented, unbuildable
without tribal knowledge, and impossible to reason about.

I spent the first six to eight weeks adding no features at all, learning the language it was
written in as I went. I moved it to CMake so it
built reproducibly, restructured it, wrote the documentation that let someone else build and
navigate it, and put unit testing in place with a documented convention for where tests live
and how they get picked up.

That is a hard thing to justify to management when nothing visible happens for two months,
which is part of why I also introduced the planning practices described below. But it is not
a detour. You cannot safely change code you cannot read, and everything that followed —
including the protocol work that is the real content of this project — was only possible
because the thing had become legible first.

## Talking to instruments

A logger has to speak to whatever is bolted into the vehicle, and scientific instruments are
a zoo: serial, Modbus, Ethernet, each with its own idea of what a measurement is, and
GPS alongside them emitting its own format continuously.

Rather than a driver per instrument compiled in, instruments are described by templates held
in a database and handled by a plugin structure, so that supporting a new instrument is
configuration rather than a code change and a redeployment. The same applies to the
individual measurements each instrument reports.

## Two people changing the same thing, and one of them is offline

This is the part I am most pleased with, and probably the most intricate thing I have
designed.

A logger's configuration — which instruments are attached, how they are addressed, how often
each measurement is sampled and recorded — can be changed in two places. An engineer standing
at the logger can change it there. Someone in an office can change it from the cloud. And
these things live where connectivity is poor — in a vehicle, on a lamp post, at a remote
monitoring station — offline for hours at a time.

So both can change the same setting, neither knowing about the other, and the question on
reconnection is what should have happened. The usual answer is last-write-wins, which here
means the office silently discards the change made by the engineer looking at the actual
instrument. For a programme whose output is published scientific data, silently is the
unacceptable word.

What I designed instead works like this:

- **Every change is a message in an append-only log**, never a direct write to the
  configuration.
- **Each message names its own predecessor and the last change its author believed was
  already applied.** That is what makes concurrency detectable: you can tell from the message
  itself whether its author knew about a given earlier change or not. A conflict is only
  possible where they did not.
- **Local changes win**, always. This is a judgement about reality rather than a technical
  convenience: the person at the logger can see the instrument, and the person in the office
  cannot.
- **Conflicts are graded, not binary.** Two changes to the same field mean the later one must
  not be resent. Two changes to different fields of the same thing mean a human should look
  and will probably resend. Those need different responses, so the system distinguishes them.
- **Rejection is partial, not total.** If one part of a batch conflicts, the rest still
  applies, and a new message is recorded containing exactly the part that took effect. One
  bad field does not discard an operator's whole batch of edits.
- **Rejections cascade correctly.** If adding an instrument is refused, every later change
  that referred to that instrument has to be withdrawn as well — including changes written
  before the instrument had an identity to refer to, which is handled by issuing temporary
  identifiers that later resolve to real ones.
- **Nothing is dropped silently.** Every message ends up either implemented or ignored, with
  a machine-readable explanation of why, returned to whoever submitted it.

The log is therefore also an audit trail: who changed what, when, what the system did about
it, and why. For measurements that end up in published research and policy decisions, being
able to answer "what was this instrument configured to do on that day, and who decided
that" is not an extra feature.

I designed it over a few days with a pencil and paper, adjusted it as I implemented and the
cases I had missed showed themselves, and then wrote it up: a document in the spirit of a
specification, with conformance language, covering the message format, the ordering rules and
the full lifecycle of a change. I did not go looking for prior art, and there is a great deal
of it — resolving concurrent edits made in ignorance of each other is the problem distributed
version control, operational transformation and conflict-free replicated data types all exist
to address. I would check now, not because the design was wrong, but because I would rather
know whose shoulders I am standing on.

This came after the campaign build. The version that went to London shipped in early February
2019; I started on the configuration protocol the following day, for the product generation
meant to follow. It was heavily tested and it never ran in production, because the product
was cancelled before production hardware was manufactured.

What I can claim is therefore narrower, and for my purposes here more useful: the reasoning
is still legible seven years later, and I would still defend the design, because it was
written down rather than left in the code.

It is also the earliest version of the habit that now defines how I work. Here the document
came after the implementation. By the time of
[the ultrasonic data-logger](@/projects/sensoteq/index.md) it came first.

## The platform under it, and the people on top of it

The logger ran on a custom Linux built with Yocto, with the cross-compilation toolchain that
goes with it, so the operating system was a defined artefact rather than whatever happened to
be installed.

I also built an operations tool in Django, for the service team maintaining monitoring
stations, which the mobile campaign then leaned on. The people who needed to
know whether a logger was working were drivers and technical staff, not engineers, and they
needed to know it at the start of a shift rather than in the data a week later. It showed
what was running, what was not, and errors phrased so that the person reading them could
act. Six hundred shifts is a lot of opportunities to lose a day's data to something nobody
noticed.

The same logger went on to run a comparable study in Utrecht, which is the clearest evidence
that the product thesis was right: a second programme I was not part of ran it themselves,
from setup instructions I wrote and a few calls with their team.

Over-the-air updates were designed but never finished; development was cancelled near the end
of my time there, after the company was acquired.

## Working practices

The planning process was ad hoc when I arrived. I introduced agile practices, wrote
phase-level documents describing the work ahead, and broke them into tickets my manager could
track — which gave management visibility and, more usefully, timelines that were worth
believing.

## Contributions released

Generic parts of the work went out rather than staying private, which is the same instinct
that later turned into [policy work at Dyson](@/projects/dyson-open-source/index.md):

- [`open62541Cpp`](https://github.com/bazza2jw/open62541Cpp) — C++ wrappers around the
  open62541 OPC UA implementation, which I contributed to
- [`NemaTode`](https://github.com/ckgt/NemaTode) — a C++ NMEA parser and GPS interface, which
  I contributed to
- [`ObjectPropertyTree`](https://github.com/hicklin/ObjectPropertyTree) — a property tree
  able to store arbitrary object types, which I published

## Stack

C++, Python, Django, embedded Linux, Yocto, CMake, Catch2, Modbus, serial, MQTT,
MySQL, NMEA/GPS, Docker.

## Evidence

- [Breathe London pilot](https://web.archive.org/web/20240912094503/https://breathelondon.edf.org/about.html)
  — the programme, its partners and its results. The pilot's site is no longer online, so
  these are archived copies
- [Pilot methodology](https://web.archive.org/web/20250618060042/https://breathelondon.edf.org/methodology.html)
  — the mobile monitoring campaign in detail
- The three libraries above
- The logger source, its specification and the configuration protocol document are
  confidential to the client. I am happy to walk through the design under NDA.
