# Reaching live nodes, to capture generated pages

`fetch_live_pages.py` needs a Reticulum interface that can actually reach the
nodes. This machine's `~/.reticulum/config` carries an `AutoInterface` only,
which is LAN discovery and finds nothing beyond the local network.

Add one TCP client interface under `[interfaces]`:

```ini
  [[RNS Testnet Amsterdam]]
    type = TCPClientInterface
    enabled = yes
    target_host = amsterdam.connect.reticulum.network
    target_port = 4965
```

Others, if that one is down:

```ini
  [[Between the Borders]]
    type = TCPClientInterface
    enabled = yes
    target_host = reticulum.betweentheborders.com
    target_port = 4242
```

Then:

```sh
uv pip install rns                       # if the venv does not have it
scripts/fetch_live_pages.py --listen 300 # watch announces, see what is serving
scripts/fetch_live_pages.py --fetch <node-hash> --path /page/index.mu
```

Nodes worth capturing, all serving generated rather than authored Micron:
Aleph (rngit repository pages), the NomadCast node (generated index and banner),
fotografm's monitoring pages (the braille plotter especially, which is the one
page in the corpus that renders almost entirely blank today), and
ChicagoNomadNet. Announce names make them identifiable in the listen output.

## The rule that matters

**Capture once. Freeze. Never re-fetch to diff.**

A generated page moves: readings change, timestamps advance, the newest post
stops being newest. The value of a frozen snapshot is that it stays still. A
page re-fetched and re-compared fails for reasons that have nothing to do with
the parser, and that failure teaches nobody anything.

`PROVENANCE.tsv` records node hash, page path, capture date and that the file is
a live snapshot, so a reader can tell a captured page from an authored one.

⚠ Flag any page volatile enough that even one snapshot is ambiguous, for example
one whose content depends on the second it was requested. Those are worth
capturing for the renderer and worth excluding from any claim about parity
stability.
