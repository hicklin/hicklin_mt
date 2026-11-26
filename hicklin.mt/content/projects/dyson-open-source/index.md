+++
title = "Getting a hardware company into open source"
description = "Spent three years making the commercial and legal case for open-source contribution at a company that had no route to it, from first principles through to a public organisation its engineers used daily."
weight = 55

[taxonomies]
tags = ["Technical leadership", "OSS"]

[extra]
# No image candidate. The internal drafts and presentations are confidential, and
# the only public artefact is a third party's GitHub organisation page, which is
# both dull and theirs. Possibly leave this one without an image.
+++

- **Role** — Senior, then Lead Embedded Software Engineer. Self-initiated, alongside my engineering work
- **Period** — 2022 to 2025
- **Outcome** — A public organisation with 18 repositories: forks used for upstream contribution over two years, and three libraries published by the company in its own name

Dyson is a hardware company. Its products run on open-source software, as every modern
product does. When I joined there was no procedure by which an engineer could contribute
anything back to it.

That sounds like a philosophical problem and it is not. It has two concrete costs. The first
is that when you find a bug in software you ship, you cannot fix it where it is broken — you
patch your own copy and maintain that patch forever, and you do that again at every version
upgrade, indefinitely. The second is that you cannot take part in anything being built in
public, which increasingly includes the standards that decide whether your products work at
all.

## Why it stopped being optional

Matter is the smart-home interoperability standard. It is written by around 300 member
companies, including Apple, Google and Amazon, and — this is the part that matters here — it
is written *in public*, in an open repository, by named engineers working for competing
companies.

Dyson wanted the standard to accommodate its own product categories, which meant having
engineers in those discussions, writing code and specification text under their own names in
a public repository owned by someone else. There was no mechanism for that. The commercial
argument was therefore not "open source is good"; it was "a standard that shapes our future
products is being written without us in the room, and we cannot get into the room."

That work went ahead as its own arrangement, well before any general policy existed — and
then became the evidence for one. Having argued the case in the abstract for a while without
much movement, I had a concrete example to point at instead: a programme the company
considered strategically important, which had required a route into public collaboration,
which had been given one, and which had leaked nothing. The question stopped being whether
engineers could be trusted to contribute in public and became why this had to be negotiated
from scratch every time.

That shift is what made the rest winnable. It also took over a year.

## What the work actually was

Three years of working with senior leadership, legal and engineering management: making the
case, proposing how it could work in practice, and taking it through review again and again.
It was not a technical problem. It was finding a form of the proposal that the people
carrying the risk could say yes to.

It went in phases, because each one asks for more trust than the last — contributing in an
engineer's own time, then contributing in the company's name, then publishing work the
company had developed itself. Each needed its own case.

The policy that came out of it is confidential, so what I can describe is the making of it
rather than its contents. The core of the problem was that the objection is always the same
one and it is a legitimate objection: a company's engineering work is entangled with what it
intends to build, and publishing the former can disclose the latter. Treating that as an
obstacle to be argued away would have failed, and deserved to. Treating it as the design
constraint — the thing the process exists to handle, so that an engineer following the
process cannot accidentally publish something sensitive and is not left making that judgement
alone — is what got it approved.

## What exists now

The organisation is public, so the result is checkable rather than merely claimed. Its
history shows the shape of the argument as much as the outcome:

- **2023** — two repositories forked, both for the Matter work and nothing else. A route
  negotiated for one programme, which is the situation the business case described.
- **September to December 2024** — forks appear across six unrelated projects in four months:
  the Bluetooth host, the host controller interface, the data structure library, a graphics
  library, a linting tool. That burst is the general policy taking effect. The Bluetooth
  throughput work elsewhere on this site is among the first things to go through it.
- **Early 2025** — three libraries published by the company in its own name: a driver for an
  optical flow sensor, a robot communication API, and a utility for compiling git metadata
  into a binary. Generic engineering, useful to anyone, disclosing nothing.

Fifteen forks and three original projects. The eleven-month gap in the middle of that
timeline is the honest part of the story: the work was slow, and the thing that moved it was
having a programme already running that nothing bad had happened to.

## Why I spent three years on it

Because the alternative is a company that cannot fix the software it ships, and engineers who
maintain private patches against upstream in perpetuity. That is a maintenance cost that
compounds quietly and never appears on anyone's plan, and it is also a bad place to be an
engineer — your best work is invisible and your worst work is permanent.

It is the same instinct as everything else on this site: fix the thing once, in the place
where the fix belongs, where it outlasts your involvement.

For a client, the relevant point is narrower. If your position on open-source contribution
is unresolved, or your legal function has never been asked the question, I have done this
before and I know which arguments work and which ones get you politely declined.

## Evidence

- [github.com/dysonltd](https://github.com/dysonltd) — the public organisation, 18 repositories
- [`commitment-issues`](https://github.com/dysonltd/commitment-issues), [`universal-robot`](https://github.com/dysonltd/universal-robot), [`paa5100je-pwm3901`](https://github.com/dysonltd/paa5100je-pwm3901) — the three libraries published in the company's own name
- The internal business case, proposed workflow and presentations are confidential
