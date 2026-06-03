+++
title = "The Ghost in the Build"
date = "2026-05-29"
+++

**This article contains a significant amount of technical terminology. You may use AI to aid your understanding. If you feel uncomfortable while reading, it's recommend closing the page immediately👻.**

## Intro

Every piece of software you've ever installed is, at its core, an act of faith.

Not faith in the code itself — you can read the code, audit it, tear it apart line by line. Faith in something murkier: the chain of hands that code passed through before becoming the program running on your machine. Someone compiled it somewhere, on some system, using some tools. You weren't there. You didn't watch. You clicked install anyway, and moved on with your day.

For most software, this is a reasonable bargain. For **Bitcoin Core**, it is unacceptable. The project exists for one significant purpose: to resist corruption or tampering by removing the necessity of human trust as much as possible.

---

## Jia Tan: what patience can accomplish

In the spring of 2024, a Microsoft engineer named Andres Freund noticed that SSH logins on a Debian system were taking about half a second longer than they should. It was the kind of anomaly most people would blame on a network hiccup and forget. Freund did not forget. He pulled the thread.

What he found, buried inside XZ Utils (A compression library so mundane that most Linux users couldn't have named it) — was a backdoor of extraordinary craftsmanship. It had been nearly two years in the making, introduced gradually, methodically, by a contributor known only as Jia Tan.

That maybe a fake name. What is real is the method.

Jia Tan appeared in the XZ Utils repository in late 2021 as an ordinary contributor, submitting small, useful patches. They were helpful. They were responsive. In retrospect, their patience is the most chilling detail of the whole story. It was not enthusiasm; it was calculation. Over months, they gradually manipulated the project’s existing maintainer — a lone developer who had publicly spoken about struggling with mental health issues, until he granted Jia Tan commit access. With the long-term groundwork laid, they executed a true covert payload injection. The tradecraft was exceedingly sophisticated: the malicious code bypassed direct modifications to the source code entirely, nestled instead deep within routine test files. These obfuscated binary blobs left zero footprint during static analysis, designed to be parsed and triggered as a backdoor only when the build scripts executed specific automated pipelines.

The code was clean, also the repository was clean. The poison was completely hidden in the build process.

What makes this story genuinely unsettling is not the technical ingenuity. It's that Jia Tan exploited nothing that most of us would recognize as a vulnerability. They exploited **care*. The open-source community runs on an implicit belief in mutual goodwill — people contribute because they want to help, and the community accepts help because it needs it. Jia Tan wore that belief like a costume and walked through every door it opened.

Four years earlier, attackers had done the same thing from the outside. The SolarWinds breach of 2020 required no years of community trust-building, no social engineering, no patience. The attackers compromised the automated pipeline that turns source code into a shippable product — and inserted a backdoor directly into the official binary before it ever left the building. Eighteen thousand organizations have downloaded this document, including the U.S. Department of the Treasury, the State Department, and even the Nuclear Security Administration, as well as numerous Fortune 500 companies, renowned universities, and major medical institutions around the world. All of them were running a signed, official binary containing code their vendor had never written.

Two attacks. Opposite approaches. One found the crack from the outside; the other from within. However, both converged on exactly the same blind spot: the build process — that dark passage between the code a developer writes and the program a user runs.

---

## The Gitian era: the best answer anyone had

To understand where Bitcoin Core is going, you first have to appreciate where it has been.

For most of its history, Bitcoin Core used a tool called Gitian to solve what's known as the **"Reproducible Builds"** problem. Here's the problem: if I compile the Bitcoin Core source code and you compile the same source code, we should produce bit-for-bit identical binaries. If we don't, then either one of our machines is doing something different — or something has been tampered with, somewhere, by someone.

Gitian achieved this by having multiple developers build inside identical virtual machines: use the same Ubuntu snapshot, the same container configuration, and then comparing their results. If every builder produced the same cryptographic hash, the binary was declared trustworthy. In the early days, developers recognized that signature attestation relies on the convergence of independent build results, even if the build environment itself remained murky.

In fact, this was not a small achievement. For almost a decade, Gitian functioned reliably and raised Bitcoin Core's security posture far above the industry standard. The developers who built and maintained it were thinking about **Software Supply Chains** long before most organizations knew the phrase existed. That foresight should not go unrecognized.

But Gitian has an inherent flaw, which can be summarized in one word: **Implicit**.

Gitian runs scripts inside a virtual machine. It assumes the base operating system snapshot is clean. It inherits the ambient environment of a running Unix system: the libraries that happen to be present, the locale settings, the PATH variables, the hundred invisible things that accumulate in any long-lived system. That environment is not declared. It is not verified. It simply **is*, the way the weather simply is.

Think of it as the difference between an oral recipe and a laboratory protocol. An oral recipe relies on implicit variables: add a pinch of salt, use whatever pan happens to be on the stove. In software engineering, these unstated instructions (such as inheriting the PATH from the surrounding environment or linking to a library that 'happens' to be installed on the system) constitute undeclared dependencies. Two competent cooks following an oral recipe will produce similar dishes, just as two machines might compile similar binaries. But **similar** is not **identical*, and **similar** is not **provably** identical. The kitchen has a history — it **"breathes"** with the residue of past meals, just as a build environment silently inherits the ambient state of its host system.

The build environment, under Gitian, had a history too. And in that history — implicit, vast, and largely unexamined — an attacker has **room to work**.

---

## Guix: A Pure State of Build

In a proposal merged by the Bitcoin Core project in 2019, GNU Guix was introduced to replace Gitian. Before evolving into a technical innovation, this shift was first and foremost a philosophical evolution.

Guix treats the build process as a **Pure Function** — that has no memory, no side effects, and no ambient state. If you've written object-oriented code, you know the opposite intimately: methods that silently reach into `this.config`, functions that behave differently depending on environment variables they never declared as parameters, procedures whose output changes based on what happened earlier in the program's life. A pure function has none of that; You give it exact inputs, and it returns exact outputs. Mapped to the build process: regardless of the machine or the time, as long as the inputs are determined, the build result is always consistent.

This is the property Guix enforces at the scale of an entire software build:

```
output = f(all inputs)
```

Everything the build needs: every compiler, every library, every tool, must be ***Explicitly** declared. If it isn't declared, it doesn't exist within the build process. Not "it probably won't be found." It structurally cannot exist, because the host system is entirely invisible. Network access is disabled. Timestamps are fixed to a known value. The `PATH` is wiped and reconstructed from scratch using only what's been declared.

In Guix's language (Scheme), a package declaration looks like this:

```scheme
(inputs
  (list gcc glibc openssl))
```

That list is the entire environment. There is no situation like: "the system happened to have this." There is no accumulation of prior state. Every ingredient is named, weighed, and catalogued, the way a chemistry lab protocol specifies every reagent and every condition — not because chemists are pedantic, but because **the reproducibility of the result depends on it*.

The outputs are stored with **Content-Addressed** naming: a binary's path in the system is derived from the cryptographic hash of its contents and all of its declared dependencies.

```
/gnu/store/0rv3fmddli5rfrswkm6b5yhnxvn35nha-bitcoin-core-30.0.drv
```

That long string of characters is not a label. It's a proof. Change the input by a single byte, and the hash shifts, taking the path with it. There are no silent mutations — there is nowhere for a ghost to hide.

>In addition:
>
>In software engineering, introducing `random()` is typically done for security purposes — such as preventing predictive attacks or generating cryptographic keys.
>
>But if incorporated into the compilation and build phases, it mutates into a **"ghost 👻 in the build"**
>
>Because even the slightest uncertainty (Non-determinism) — whether it involves reading the system's current time, a random memory address, or the packing order of the file system, can cause **Reproducible Builds** to completely blow up 💥

---

## What changes in engineering practice

With Guix, developers independently build Bitcoin Core from source. Not on shared infrastructure. On completely independent machines — potentially different hardware, different countries, different operational histories. If the process is sound, they all arrive at the same hash.

They submit that hash alongside a cryptographic signature — a mathematical seal that binds the result irrevocably to their identity. The collection of these signed attestations is public and auditable.

**Before (Gitian):**
```
Developer builds → Signs the binary → User downloads and trusts the signature
```

The user is trusting a person, and that person's build environment, and everyone who had access to it.

**After (Guix):**
```
Many developers build independently
        ↓
Results converge on the same hash
        ↓
The convergence itself becomes the attestation
        ↓
User verifies the convergence
```

Signatures are no longer the benchmark of trust. Consensus among independent verifiers is. If a machine is compromised, the hashes it generates will diverge from those of all other nodes. Such security breaches are not uncovered through incident response or forensic investigations, but are naturally revealed through the normal operation of the validation process—just as when you compare a rigged scale with the majority of honest scales, the cheating is immediately exposed.

**(This is essentially the same as how anti-cheating mechanisms operate in blockchain consensus nodes.)**

---

## Nix's Pragmatism and Guix's Philosophy of Trust

Users of NixOS will find all of this familiar — Nix shares the same foundational insight, the same `/store` model, the same devotion to builds as pure functions. But the two projects made a different wager at a crucial fork in the road. Nix, choosing usability, relies heavily on large pre-built **cached binary package** by default: rather than compile everything from source, you download pre-built artifacts from a trusted server. For most users, this is the right call. Compilation is slow, and a working system has more practical value than a purely philosophical pursuit.

Guix chose differently. Driven by a philosophy akin to Gentoo but enforced with strict functional guarantees, **Guix + GNU Mes** insists on building everything from source. For the Bitcoin Core project, this distinction is critical. Guix traces an unbroken chain back to what it calls the **Full-Source Bootstrap**: a minimal trust anchor of roughly 357 bytes of machine code from which the entire toolchain: compilers, linkers, standard libraries, all of it — is compiled step by step, with no preconceived assumptions and no pre-built black boxes. Because relying on a pre-built binary cache package means trusting the people behind it; and Bitcoin Core's threat model offers no room for that kind of blind faith.

This trust anchor has been fully streamlined, enabling developers in complex software engineering projects to verify build artifacts more effectively with less effort. This is Guix's founding wager on Full-Source Bootstrap, and the fundamental reason Bitcoin Core adopted Guix + GNU Mes as its build solution: the root of trust must be sufficiently minimal to allow developers to easily comprehend the build process and verify its correctness, rather than blindly rubber-stamping invisible black boxes out of convenience.

---

## The ghost hasn't gone away, it moves

Here is where the honest account gets complicated.

Guix dramatically shrinks the surface of implicit trust. But it does not eliminate trust.

In other words, Guix approaches the mathematical limit of trust, yet never reaches the **absolute zero** of **Zero Trust**.

Consider a thought experiment. Someone with Jia Tan's patience and technical sophistication targets not Bitcoin Core's source code, but a low-level dependency of Guix itself — something deep in the toolchain that all builders share, the progress of infiltration slowly enough not to raise alarms. The result would be: a perfectly reproducible binary, universally attested, signed by every independent builder. They would all produce the same hash. Users would verify the convergence and feel secure.

![1](https://static.yon.im/image/blog/the-ghost-in-the-build/1.webp)

> (Generated by ChatGPT Images)

Determinism guarantees reproducibility. But it does not guarantee **correctness**. It ensures that everyone is building the same thing — it cannot guarantee that the thing being built is clean. Guix shifts and minimizes the attack surface as much as possible; it does not dissolve it.

The **Full-Source Bootstrap** addresses this challenge at the absolute bedrock: starting from something small enough to be auditable, and compiling all the way up. Yet, being 'small enough to be audited' is not the same as 'having been thoroughly audited.'

This erects an inverted pyramid of engineering: the staggering, massive dependency ecosystem of the modern software world forms the heavy precipice, while those mere 357 bytes of machine code serve as the precarious fulcrum holding up the entire superstructure. Within this formation, every block of code derived upward requires the absolute reliability of every stone beneath it as a physical prerequisite. The chain of trust stretches endlessly with every added dependency; any micro-flaw or unexamined ghost at the bottom propagates upward through the structural stress, amplifying at the apex into a catastrophic collapse of the entire empire.

There is also a quieter problem. The verification model works when many independent builders exist. In practice, who performs these builds? People with the technical capability, the hardware, the time. The network of witnesses is real, but it is small and self-selecting. The participants know each other. They share mailing lists, conferences, professional histories. "Independent" is true in the technical sense — separate machines, separate environments — but sociology has its own meaning for the word, and the two meanings do not always agree.

None of this is a reason to prefer Gitian. It is a reason to be precise about what Guix actually achieves: it replaces a wide, murky, and relatively opaque, difficult-to-audit attack surface with a narrow, well-lit, and transparent, easily auditable one. That is meaningful progress, but "the absolute trustworthiness of the build process" is by no means a fully resolved problem.

**The ghost 👻 in the build — still lingers on.**

---

## This matters past Bitcoin Core

The use cases for Bitcoin Core are extreme, primarily because the software defends financial sovereignty for users who fundamentally distrust intermediaries, whereas most of the software we use on a daily basis does not need to shoulder such a heavy burden.

But this underlying vulnerability extends far beyond Bitcoin. Every server you administer, every tool in your deployment pipeline, every background library — all of them passed through a build process you did not witness, on machines you have never seen, by people you do not know. The victims of SolarWinds didn't know either. Andres Freund only barely caught Jia Tan.

That "barely" is the critical point. What stopped the XZ backdoor was one engineer's curiosity about SSH latency on a Friday afternoon — a fleeting moment of attention that cannot be relied upon to repeat. It wasn't a system that stopped the breach. And as for so-called coincidence. And coincidence is a terrifyingly fragile foundation for digital infrastructure......

In fact, the defensive approach offered by Guix is not limited to extreme scenarios — the principles it embodies scale in both directions:

- At the baseline, combine tools that align with the concept of **"Reproducible Builds"**  — such as **[direnv](https://direnv.net) and [Nix Flakes](https://nixos.wiki/wiki/Flakes)**, enables developers to explicitly declare engineering project dependencies and lock down the entire development environment. This ensures the exact same compiler, identical library versions, and a consistent **Runtime Environment**, regardless of the machine or the year. Developers located in different countries and regions, using different operating systems, can all access toolchains driven by the same **Declarative** specification, fully **Explicit** on their respective platforms. The **"It just works on my machine"** — **wellknown problem** becomes architecturally impossible rather than perennially managed. Setting this up does require some configuration time, but it is well worth incorporating into the standard practices of any project that takes engineering quality seriously.

- Further up the chain, build pipelines can be reconfigured to work from explicitly declared, version-locked inputs rather than trusting whatever the runner happens to have installed — the oral-recipe model replaced, at least partially, by the laboratory protocol. Guix, and Bitcoin Core's full reproducible build process, represents the far end of the spectrum: declare everything, verify everything, minimize trust to what can actually be inspected. Not every project needs that ceiling. Every project benefits from knowing it exists. Each explicit declaration, each pinned dependency, each verified build shrinks the territory where the unobserved can hide.

You will always be trusting something. The question Guix asks — and answers: is how small that something can be made.

The ghost doesn't leave. But it has less room to hide.

---

## Acknowledgments

**Bitcoin Core's Guix contribution guide: [github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md](https://github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md)**

**GNU Guix: [guix.gnu.org](https://guix.gnu.org/)**

**Nix Flakes: [nixos.wiki/wiki/Flakes](https://nixos.wiki/wiki/Flakes)**

**Reproducible Builds: [reproducible-builds.org](https://reproducible-builds.org)**

**GNU Mes: [nlnet.nl/project/GNUMes-fullsource](https://nlnet.nl/project/GNUMes-fullsource/)**

---

## References

* **[1]** Freund, A. (2024). *backdoor in upstream xz/liblzma leading to sshd compromise*. Open Source Security mailing list. [View archive](https://www.openwall.com/lists/oss-security/2024/03/29/4)

* **[2]** CISA. (2020). *Advanced Persistent Threat Compromise of Government Agencies, Critical Infrastructure, and Private Sector Organizations* (Alert AA20-352A). [View alert](https://www.cisa.gov/news-events/cybersecurity-advisories/aa20-352a)

* **[3]** Thompson, K. (1984). Reflections on trusting trust. *Communications of the ACM*, 27(8), 761–763. [View paper](https://dl.acm.org/doi/10.1145/358198.358210)

* **[4]** Dong, C. (2019). *bitcoin/bitcoin PR #15277: Add Guix-based release build system*. GitHub. [View pull request](https://github.com/bitcoin/bitcoin/pull/15277)

* **[5]** Courtès, L., & Nieuwenhuizen, J. (2023). *The Full-Source Bootstrap: Building from source all the way down*. GNU Guix Blog. [View post](https://guix.gnu.org/blog/2023/the-full-source-bootstrap-building-from-source-all-the-way-down/)

* **[6]** Zero trust architecture. (2024). *Wikipedia*. The "Zero Trust architecture" entry on Wikipedia. [View wiki](https://en.wikipedia.org/wiki/Zero_trust_architecture/)


---

## Declaration / Statement

>This article is a personal exercise in Vibe Writing. It was completed after countless rounds of dialogue with multiple large language models (LLMs) and meticulous review and polishing of every word and sentence—particularly during the process of translating between Chinese and English. The entire creative process took approximately 12 consecutive hours.
>
>Participating model providers include Claude, GLM, Gemini, GPT, Grok, DeepSeek, and Mistral (listed in order of estimated token usage).
>
>The research direction, editorial judgments, and overall decisions were made by myself; the language was refined through iterative human-machine collaboration. 
>
>Every fact stated in this article has been manually verified to minimize model hallucinations as much as possible.
