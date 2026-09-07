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
