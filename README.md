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

**`tier4-generated/`, 5 pages.** What an executable page actually serves. A
NomadNet page with the executable bit is a program; the corpus held the sources
and none of the output, which is the Micron a reader receives and the shape most
likely to hide a bug, because no human wrote it.

`scripts/generate_dynamic.py` runs them under NomadNet's own contract
(`Node.py`: minimal environment carrying only `PATH`, `link_id`,
`remote_identity` and the request's `field_*`/`var_*`) and freezes stdout.
**Manual, never CI**: regenerating per run would re-introduce timestamps and node
state, and the corpus is frozen on purpose. Generation produces files; CI
compares files.

Every output is run three times on the same input and dropped unless all three
match. `PROVENANCE.tsv` records the script, the exact request, the source commit
and the licence.

### Known coverage boundary: dynamic pages

**Dynamic coverage is 5 representative pages, deliberately.** Of 39 executable
pages, most exit before printing: they need sibling modules this corpus never
fetched (it takes `*.mu` only), or hardware, or a running node.

Widening it means fetching each dynamic page's whole directory with its
dependencies. **Deferred, and not a known gap.** The five cover the common
shapes, they are parser-clean and render-clean, and the dynamic set surfaced no
bug the static pages had not already found, which is evidence the pipeline
handles machine-generated Micron rather than evidence it is under-tested. More
of a shape already proven adds little.

Revisit only if a dynamic-page bug turns up in the field. This note exists so
that decision is a decision, and so anyone chasing such a bug knows exactly
where the corpus stopped.
