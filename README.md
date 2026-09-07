# micron-cpp-corpus

Real Micron pages, frozen as static files, for diffing a parser against
NomadNet's own.

A parser tested only on cases its author wrote is tested against its author's
reading of the format. This is the other half: pages written by other people,
for real networks, exercising combinations nobody invents on purpose.

**Nothing here is fetched at test time.** Every committed file is pinned to the
commit it came from and recorded in `MANIFEST.tsv` with its licence.

## Three tiers

**`tier1-real-world/`, 79 pages.** Pages from deployed nodes and community
networks: Chicago's network, a German-language node with guestbook and pinboard
pages, weather-station output, a broadcast node, a peer parser's own test set,
and a tree-sitter grammar's fixtures. MIT, ISC, 0BSD and Unlicense. This is what
Micron looks like when someone is using it rather than demonstrating it.

Sources here were chosen partly to exercise the rarer constructs. Tables,
images and partials appear on almost no real page, so pages that use them were
sought out deliberately rather than waiting for one to turn up.

**`tier2-generated/`, not committed.** Git-over-Reticulum nodes serve Micron
converted from markdown on the fly, and that output has a shape hand-written
pages don't: true-colour spans with explicit resets, nested styles wrapping
links, box-drawing tables, literal blocks around code.
`scripts/generate_tier2.py` reproduces it offline from markdown pinned by SHA.
Run it before the suite.

**`tier3-canonical/`, 13 pages, 116 KB.** NomadNet's Guide, by the author of the
format. `guide-markup.mu` is the Micron specification written in Micron, 1,176
lines, and it ends by embedding its own source with the literal toggles escaped,
which is an edge case worth the whole tier. **GPL-3.0**, which is why this
repository exists separately from the parser. See `LICENSING.md`.

## Use it

```sh
python3 scripts/generate_tier2.py --out tier2-generated   # tier 2, offline
find tier1-real-world tier2-generated tier3-canonical -name '*.mu'
```

`scripts/extract_guide.py` rebuilds tier 3 from an installed NomadNet. It parses
`Guide.py` with `ast` and never imports it, so no NomadNet code runs; `--verify`
checks the result against the real module.

## Adding pages

Committed files need a `MANIFEST.tsv` row: path, source URL, commit, retrieval
date, licence. **Permissive licences go in tier 1. Unlicensed material does not
go in at all**, because no licence means no permission, which is worse than an
awkward one.
