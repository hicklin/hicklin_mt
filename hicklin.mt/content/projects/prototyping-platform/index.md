+++
title = "A platform for building prototypes fast"
description = "Argued a prototyping team off Python and onto Go by first asking what the language was actually for, then helped build the layered module library and state protocol that most of the team's projects came to run on."
weight = 45

[taxonomies]
tags = ["Go", "Protocol design", "Embedded Linux", "API design", "Technical leadership"]

[extra]
# No image candidate. Everything here is confidential. A generic diagram of the
# three-layer module structure, redrawn from scratch with no product specifics,
# would work and would be the clearest thing on the page.
+++

- **Role** — Senior Embedded Software Engineer on the prototyping team. One of the main maintainers of the shared module library and the protocol the modules spoke
- **Period** — 2020 to 2023, alongside project work
- **Outcome** — Go adopted as the team's language; a library of composable modules that most of the team's projects came to be built from

I worked on a team whose job was to make prototypes real. Researchers with an idea,
designers with an interaction they wanted to feel, product teams wanting to know whether
something was worth committing to — they came to us, and we built the thing that let them
find out.

The constraint that shapes everything is time. A prototype has to be convincing enough to
make a decision on, and it has to exist in weeks. The failure mode is subtle: you hit the
deadline, the prototype works, and you have built nothing anyone can use again. Then the next
project starts from an empty directory.

That was roughly the position when I joined. Most things were written in Python, and there
were some reusable libraries, but nothing like the degree of reuse the work deserved — each
project was largely its own island, and the most reliable thing carried from one to the next
was the person who had worked on the last one.

## Choosing a language by asking what it was for

Within a year I had argued the team onto Go. The part I would want to be judged on is not the
conclusion but how I got there: I went round the team first and collected what people
actually needed from a language, rather than arriving with an answer and looking for
support.

What came out was specific. Builds had to be fast and the output small, because these things
are deployed to devices over a network many times a day. It had to cross-compile without
ceremony. It needed to produce a single self-contained binary, because the deployment target
was a container on a device rather than a machine someone had lovingly configured. Code had
to be readable by whoever picked it up next, because people moved between projects
constantly and inherited each other's work. And the learning curve had to be shallow: the
team were strong engineers, working in Python and C and more besides, but a language they
had to stop and study was a language that would cost us the time the whole exercise was
meant to save.

Several candidates went through those criteria, Rust among them, which lost on that last
one. Go met all of them.

Then I stopped arguing and ported one of the Python libraries to Go, so the comparison was
something the team could look at rather than a case I was making. That demonstration is what
moved it: the head of the team began encouraging people to switch shortly afterwards.

Framing the choice as a requirements exercise rather than a preference is why it was
winnable, and I think it is the only honest way to have that argument. I have watched
language advocacy fail repeatedly, and it usually fails because someone led with the answer.

## Modules in three layers

Alongside the other leads I pushed for the platform: not a framework, but a collection of
independent blocks — sensors, drivers, communication protocols, networking — that a project
assembles according to what it needs.

Each module is built in three layers, and the layering is the point:

1. **A library.** The capability itself, usable by anything, with no opinion about how it is
   deployed.
2. **An application that serves the library.** A runnable program that does the obvious thing
   with it — drive the lights, read the sensor and publish the readings — configured rather
   than coded.
3. **A container.** The same application as a deployable unit, so it can run as one service
   among several on a device.

That means a module can be consumed at whatever depth a project needs. Someone writing bespoke
firmware takes the library. Someone assembling a prototype in an afternoon takes the
container, writes no code at all, and composes running services instead. The same lights
module served both, and the cost of supporting the second case is a Dockerfile.

I wrote and maintained several of these, including ones that others then built on without
needing me. That last part is the measure of whether a platform is real: a colleague's
feedback that stuck with me was about being able to pick up a package I had written and get on
with it.

## A common language between the blocks

Composable services only compose if they can talk. Following a colleague's idea, we built a
protocol that every module implements, and I became one of its main maintainers and added a
good deal of its functionality.

It is a state synchronisation protocol over a message broker. Some modules own a piece of
state and are responsible for publishing it; others subscribe to state they care about and
can request changes to it. Because it was designed to remain compatible with the messaging
our shipping products already used, a prototype assembled from these blocks could talk to a
real product rather than to a mock of one.

Three parts of it I think were worth having:

- **State is declared in configuration, not code** — its structure, its type, and what counts
  as a valid value, including numeric ranges and permitted strings. So a module rejects a
  nonsensical value because of what it *is*, not because someone remembered to write a check.
- **Changes can be batched** so that a set of related updates is published as one coherent
  message rather than as a sequence of states the system was never really in.
- **Every change carries the reason it happened**, and that provenance propagates
  automatically: when a module changes state because something asked it to, the reason travels
  with the resulting message. Debugging a dozen talking services without that is guesswork.
  This one was not ours — it came from the production code the protocol had to stay
  compatible with, and it was the best thing we inherited. It is the same idea as the audit
  trail in [an earlier protocol of mine](@/projects/air-quality-datalogger/index.md).

I would not defend the whole design. A fair amount of it I actively disliked, and I spent
time on the side working towards a replacement built on Cap'n Proto — schema-defined
messages, generated types, no hand-written parsing — which I never got far enough to propose
properly. It is the same thinking I later got to apply
[with a clean sheet](@/projects/sensoteq/index.md).

## Testing the thing everyone depends on

I led on testing and benchmarking the platform code, which is not glamorous and is the
clearest case of leverage I can point to in that period. A bug in a prototype inconveniences
one project. A bug in a shared module is a bug in everything built on it, and the person who
eventually hits it has no idea the module is where to look. Benchmarks mattered for the same
reason: a module that is quietly slow becomes a mysterious performance problem in somebody
else's prototype.

## Around the edges

Some smaller things from the same period, in the same spirit of making the team faster rather
than any single project better: a command-line tool for the team's common tasks, packaged
properly so it installed and updated through the normal package managers on Linux and macOS;
documentation for building and flashing the team's device operating system images; and getting
PCB reviews into a shared cloud tool, which turned reviewing a board from an appointment into
something you could just do.

## Stack

Go, Python, Docker, Balena, embedded Linux, Yocto, MQTT, Altium.

## Evidence

This work is confidential and there is nothing to link. What exists instead is the testimony
of the people I did it with, some of which speaks directly to it — the adoption of Go, the
module library, and the prototypes it shortened. I would rather show you that than ask you to
take my word for it.
