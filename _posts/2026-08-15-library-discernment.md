---
title: Library Discernment
tags: [ open-source, software-engineering ]
category: [ Blog ]
---

This is extracted from a document I wrote ~2 years ago about making it easy to
find and assess-for-fit internal libraries. Some of these items are both an
evaluation criterion and a suggestion for the production of high-quality
libraries.

Also relevant is [Linux Dev Time Episode 151](https://latenightlinux.com/linux-dev-time-episode-151/).

## Guiding Principles

The [OpenSSF](https://openssf.org/) publishes additional guiding questions for
[assessing open-source software fit via the lens of
security](https://best.openssf.org/Concise-Guide-for-Evaluating-Open-Source-Software).
Many of these questions apply to internal libraries, too.

### 2-Tier Documentation

Documentation for shared libraries serves at least 2 audiences: the first needs
an example or two that they can run with no extra setup or hassle. We call this
the “copy-paste-run” assessment: it answers questions like “Does the library
work?” and “How easy is it to glue together with our system?” This audience also
tends to be what Michelle Bu calls the “[eager
developer](https://increment.com/apis/api-design-for-eager-discerning-developers/).”
They often want to see code run quickly so they can save time and are typically
going to need the least complex parts of the library.

The second audience, Bu’s “[discerning
developer](https://increment.com/apis/api-design-for-eager-discerning-developers/),”
needs to be able to see the full range of supported functionality. They should
be able to absorb the essential vocabulary of the library by scanning
documentation aimed at them. Documentation for this audience should answer the
question “Is this library adaptable to my complex use-case?”

Thinking about these two audiences naturally leads us to 2 tiers of documentation:

1. The “Getting Started” guide should have short, minimally complex examples
   that are easy to understand and run. The Getting Started documentation can be
   included in the project’s README or in a published documentation site,
   typically on or near the landing page. This also means that the library
   should be designed to package a streamlined interface for simpler use cases:
   without this interface, the first tier of documentation will be hard to make
   concise and compelling. This makes fit assessment challenging.
1. The “Reference” section should clearly and concisely articulate the library’s
   core concepts (its vocabulary) and then spell out the various ways they can
   be combined. This also means the library should be designed around
   well-defined and composable domain objects[^1]. As a matter of programming,
   the streamlined interface that supports simpler examples is typically a
   straightforward composition of core concepts from the Reference layer.

Other useful principles for organizing documentation include the [Diátaxis
framework](https://diataxis.fr/), in which “Getting Started” is often part of a
“Tutorials” section. Diátaxis also incorporates how-to guides and explanation
sections. Each section fulfills different reader needs. Example Diátaxis-style
documentation can be found on [internal tool]. For developers
assessing library usefulness, all four Diátaxis sections provide useful
information.

### Working Consumer Repositories

Seeing real-world uses of the library in action aids understanding and assessing
the library. Teams are able to break down how the library fits into typical
software structures and use cases, and they have additional points of contact
and reference for assessing fit. Consumers who come together around a library
also spark community.

Libraries should document known consumers to help potential consumers assess
fit. For example, the documentation may link to a pre-filled code search on
GitHub that shows library use. Or the documentation may highlight top projects
that use the library well, which allows the maintainers to control for the
quality of recommended examples.

This is subtly different from the “Used by engineers from” taglines on project
sites like [httpie](https://httpie.io/), which use brand-name recognition to
persuade potential consumers of fit. The goal of linking to (curated) example
consumers is to build community and to provide new directions of exploration for
fit assessment.

### Engineering Principles

Every library embodies values and principles from its contributing
engineers[^2]. Kate Gregory’s [Emotional
Code](https://www.youtube.com/watch?v=uloVXmSHiSo) demonstrates that programmers
leave behind traces of human emotion in their code. Similarly, we leave evidence
of design tradeoffs, technical style, and domain language[^3] in the
crystallization of our thoughts in the form of code.

Library consumers also need to be able to determine if the engineering
principles embodied by the library are a match for their use case. For example,
a core application for payment processing may not want to use a library that
embodies experimental principles and that lives on the bleeding edge: it may
prefer a library that emphasizes stability and security. On the other hand, a
new data processing system prototype may find the experimental frontier exciting
to help flesh out the cutting edge library’s design and implementation.
Developers regularly assess engineering principles embodied by libraries fit and
share these assessments among their peers.

Documenting these principles concisely, whether alongside other documentation or
in a project’s README file, helps engineering teams quickly assess principle
fit. These principles are often also found in Getting Started guides. For
example, the Rust Programming Language makes its guiding principles prominently
visible. [“Empowering everyone to build reliable and efficient software” is
explained by the further breakdown](https://github.com/rust-lang/rust):

> Why Rust?
>
> - Performance: Fast and memory-efficient, suitable for critical services,
>   embedded devices, and easily integrate with other languages.
> - Reliability: Our rich type system and ownership model ensure memory and
>   thread safety, reducing bugs at compile-time.
> - Productivity: Comprehensive documentation, a compiler committed to providing
>   great diagnostics, and advanced tooling including package manager and build
>   tool ([Cargo](https://github.com/rust-lang/cargo)), auto-formatter ([rustfmt](https://github.com/rust-lang/rustfmt)), linter ([Clippy](https://github.com/rust-lang/rust-clippy)) and editor support
>   ([rust-analyzer](https://github.com/rust-lang/rust-analyzer)).

Rust makes clear what users can expect from it—if these principles do not align
with a particular project, Rust may not be the right fit. Rust also uses these
principles to guide RFCs and the direction of the language. Other projects leave
these principles implicit, instead [documenting overall
design](https://serde.rs/#design) or [providing a technical roadmap and
direction](https://github.com/dotnet/roslyn/blob/main/docs/wiki/Roadmap.md).

Principles embody several facets of a library and its maintaining team (this
list is non-exhaustive):

- **Technical decisions.** Examples: choice of programming style (functional or
  object-oriented?), data structures (mutable or immutable?), or API style
  (fluent interfaces? builder patterns?).
- **Design decisions.** Examples: stable, experimental, opinionated, flexible,
  narrowly focused, general framework. Is the library batteries included or
  minimalist?
- **Maintenance decisions.** Examples: Is the library community driven via open
  source or innersource or is it built to serve a specific user? Do the  library
  maintainers welcome outside contributions? Do they have a clear vision for the
  library? What [security
  principles](https://best.openssf.org/Concise-Guide-for-Evaluating-Open-Source-Software)
  are embodied?

All projects fall somewhere on each of these spectra: articulating the
principles embodied by each library enables potential consumers to make informed
decisions about the tradeoffs of using a particular library. As with
documentation, it also helps maintainers: having a clear set of principles helps
teams decide which features, pull requests, or changes to accept and which to
decline.

## Notes

[^1]: “Object” is used here in a generic sense (as in “artifact” or “widget”)
    rather than in the typical programming sense (as in “object orientation”).

[^2]: Ruha Benjamin argues that “social norms, ideologies, and practices are a
    constitutive part of technical design” (Race After Technology, 2019; p. 41).
    We cannot readily separate creators and creations.

[^3]: See [Young et al 2023, Stretching the Glasgow Haskell Compiler: Nourishing
    GHC with Domain Driven
    Design](https://dl.acm.org/doi/pdf/10.1145/3609025.3609476), esp. §3.2
    Design Principle: Use a Ubiquitous Language, and the [accompanying
    talk](https://youtu.be/vkC1AixG5EQ).
