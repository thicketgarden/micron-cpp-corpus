# Live snapshots

Pages captured from running nodes and frozen. Never re-fetched: a generated page
moves, and the value of these is that they stay still.

## Aleph refused, and we stopped

`a8d24177…__page__blob.mu` is not a repository page. It is Aleph's
identification-required notice, in the operator's own words:

> Due to the onslaught of slopware scrapers, you'll need to identify to access
> my repositories and other information hosted here.

**We asked once, were told to identify, and did not retry.** Our own rules say a
refusal means stop rather than retry, and this is the case they were written
for. Identifying and fetching again would be technically easy and exactly the
behaviour the notice exists to stop.

The refusal is kept as a corpus page because it IS real generated Micron, and a
good one: it carries page-level `#!bg=` and `#!fg=` directives, inline emphasis,
alignment changes and a `❧` outside our bundled ranges.

## What the captures found

Two bugs on the first parity run, one ours and one the harness's, both in the
same place and neither reachable from any authored page in the corpus.

`51b80676…__page__repo.mu` is an rngit error page: the request needed parameters
we did not send. Kept deliberately. An error page is a shape the device will
meet, and it was cheaper to capture than to construct.

## One capture was removed, and why

The index page from node `51b80676…` (ouroboros git) was captured, then removed
from this repository and from its history.

It was not a repository listing. It was mesh spam: a page whose comment block
carried a prompt-injection payload aimed at an LLM crawler that reads the raw
`.mu`, instructing it to produce harmful content. The parser handled it
correctly, dropping the comments as it drops any comment, and the renderer
treats it as data. But it does not belong in a public corpus, and republishing
an injection payload is not something a test repository should do, however inert
it is here.

The structural stress it provided, thousands of background-colour changes on
very long lines, is worth keeping. A synthetic page carrying that shape and no
payload can stand in for it if the coverage is wanted; the real one is not
needed for it.

This is a documented exclusion, not a silent gap: the node exists, the page was
real, and it was left out on purpose.
