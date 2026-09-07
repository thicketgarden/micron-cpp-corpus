# Reaching live nodes, to capture generated pages

`fetch_live_pages.py` needs a Reticulum interface that can actually reach the
nodes. This machine's `~/.reticulum/config` carries an `AutoInterface` only,
which is LAN discovery and finds nothing beyond the local network.

**Do not trust a hostname from memory.** The endpoints in this file were taken
from the live directory, which is the same interface-discovery data nodes
announce, surfaced over the web:

```sh
curl -s https://directory.rns.recipes/api/directory/discovered | python3 -m json.tool | less
curl -s https://directory.rns.recipes/api/directory/submitted  | python3 -m json.tool | less
```

Each entry carries `status`, `lastHeard` and a ready-to-paste `config` block. If
one below has gone quiet, take a fresh one from there rather than guessing.

Add one under `[interfaces]` in `~/.reticulum/config`. All of these were online
and heard from within the hour when this was written:

```ini
  [[cybercore]]
    type = TCPClientInterface
    enabled = yes
    target_host = rns.cybercore.uk
    target_port = 4242

  [[RMAP World]]
    type = TCPClientInterface
    enabled = yes
    target_host = rmap.world
    target_port = 4242

  [[NEPAMesh]]
    type = TCPClientInterface
    enabled = yes
    target_host = reticulum.nepamesh.com
    target_port = 4242
```

⚠ **`TCPClientInterface`, not `BackboneInterface`.** Much of the directory is
now Backbone, which arrived in RNS 1.5; a `uv tool install rns` may be older.
Check with `rnstatus --version`. A TCP client works on every version and reaches
the same network.

⚠ **The AutoInterface warnings are separate and harmless.** `carrier loss on
utun0` is Reticulum trying multicast discovery over a VPN tunnel. It costs
nothing but noise. To silence it, name a real interface:
`devices = en0` under the AutoInterface block.

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
