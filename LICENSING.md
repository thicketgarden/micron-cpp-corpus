# Licensing: why this is a separate repository

**This corpus is mixed-licence on purpose, and that is the reason it is not
inside `micron-cpp`.**

`micron-cpp` is Apache-2.0. Some of the best test material for it is GPL-3.0,
because NomadNet is GPL-3.0 and NomadNet's Guide is the canonical Micron
document, written by the format's author. Putting those files in the library
would make the library's licensing a question every consumer has to answer.
Keeping them here means the library stays clean and the parity harness fetches
this repository at test time.

## Why testing an Apache-2.0 tool against GPL data is not a derivation problem

**Running is not distributing.** GPL-3.0 section 2 states it plainly:

> This License explicitly affirms your unlimited permission to run the
> unmodified Program.

The GPL governs copying, modifying and distributing a covered work. Feeding a
GPL-licensed document to a parser as input is none of those things, any more
than a text editor becomes GPL by opening a GPL source file.

**`micron-cpp` never contains this material.** It pins this repository as a test
dependency and reads it at test time. Nothing it distributes, no source tarball
and no release artifact, carries a byte of the Guide.

**This repository does redistribute it, and complies normally.** The Guide
extract is a modified form of NomadNet, so it is distributed here under
GPL-3.0-or-later, attributed to Mark Qvist, with the extraction method recorded
in `scripts/extract_guide.py` and the upstream version pinned in `MANIFEST.tsv`.

**Mixed licences in one repository is the aggregate case**, GPL-3.0 section 5:
separate works distributed together on one volume do not take the GPL. Every
file carries its own terms in `MANIFEST.tsv`, and nothing is combined into a
single work.

## The rule that could be broken later

⚠ **Never commit expected or golden output derived from the GPL material.**

A recorded event stream produced from the Guide is a transformation of a GPL
work, and committing it into an Apache-2.0 repository would be redistribution
under the wrong licence. The harness compares against Python live, so today
there is nothing to get wrong. Someone adding a cache to make the suite faster
would get it wrong without noticing, which is why it is written here.

## Contents

| Tier | What | Licences |
|---|---|---|
| `tier1-real-world/` | Pages from deployed nodes and networks | MIT, ISC, 0BSD |
| `tier2-generated/` | Micron produced by rngit's converter, **not committed** | inputs pinned, output not redistributed |
| `tier3-canonical/` | NomadNet's Guide, extracted from `Guide.py` | **GPL-3.0-or-later** |

`MANIFEST.tsv` records source URL, commit, retrieval date and licence for every
committed file.

## Attribution

The Guide is the work of **Mark Qvist**, from
[NomadNet](https://github.com/markqvist/NomadNet), GPL-3.0. It is included here
unmodified in substance, reformatted from Python string constants into `.mu`
files. Tier 1 pages belong to their respective authors under the licences named
in the manifest, and the full text of each licence is in `LICENSES/`.

**This is reasoning, not legal advice.** If it matters to you, read the licences
yourself.
