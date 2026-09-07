#!/usr/bin/env python3
"""Capture Micron from live NomadNet nodes and freeze it as corpus pages.

WHY OVER THE NETWORK. Most executable pages in this corpus never run here: they
need sibling modules, data files, hardware or a node that a *.mu-only fetch does
not provide. The node has all of it. Asking the node for the page gives the real
generated Micron directly, which is also exactly what the device meets.

FROZEN, NEVER RE-FETCHED. A generated page moves: readings change, timestamps
advance, the latest post is not the latest for long. Capture once, freeze the
snapshot, and treat it as a fixed page from then on. Re-fetching and re-diffing
against a live node compares against a moving target and will fail for reasons
that have nothing to do with the parser.

  ./fetch_live_pages.py --listen 120          watch announces, list what is out there
  ./fetch_live_pages.py --fetch <hash> --path /page/index.mu
  ./fetch_live_pages.py --from targets.tsv    hash<TAB>path per line

Needs a Reticulum interface that can reach the network the nodes are on. This
machine's config has an AutoInterface only, which is LAN discovery; see
TESTNET.md beside this script for the interface block to add.
"""

import argparse, os, pathlib, sys, time

try:
    import RNS
except ImportError:
    sys.exit("needs rns: uv pip install rns")

APP_NAME = "nomadnetwork"
ASPECT = "node"
TIMEOUT = 30

_seen = {}


def _announce_handler_factory():
    class H:
        aspect_filter = f"{APP_NAME}.{ASPECT}"
        receive_path_responses = False

        def received_announce(self, destination_hash, announced_identity, app_data):
            name = ""
            if app_data:
                try: name = app_data.decode("utf-8", "replace")[:48]
                except Exception: pass
            h = RNS.hexrep(destination_hash, delimit=False)
            if h not in _seen:
                _seen[h] = name
                print(f"  {h}  {name}")
    return H()


def listen(seconds):
    RNS.Transport.register_announce_handler(_announce_handler_factory())
    print(f"listening {seconds}s for {APP_NAME}.{ASPECT} announces\n")
    t0 = time.time()
    while time.time() - t0 < seconds:
        time.sleep(1)
    print(f"\n{len(_seen)} node(s) heard")


def fetch(hash_hex, path, outdir):
    """One page over a Link. Returns the raw bytes the node served."""
    dest_hash = bytes.fromhex(hash_hex)
    if not RNS.Transport.has_path(dest_hash):
        RNS.Transport.request_path(dest_hash)
        t0 = time.time()
        while not RNS.Transport.has_path(dest_hash) and time.time() - t0 < TIMEOUT:
            time.sleep(0.5)
    if not RNS.Transport.has_path(dest_hash):
        print(f"  no path to {hash_hex}", file=sys.stderr)
        return None

    identity = RNS.Identity.recall(dest_hash)
    dest = RNS.Destination(identity, RNS.Destination.OUT, RNS.Destination.SINGLE,
                           APP_NAME, ASPECT)
    link = RNS.Link(dest)
    t0 = time.time()
    while link.status != RNS.Link.ACTIVE and time.time() - t0 < TIMEOUT:
        time.sleep(0.2)
    if link.status != RNS.Link.ACTIVE:
        print(f"  link to {hash_hex} did not establish", file=sys.stderr)
        return None

    box = {}
    def on_response(receipt): box["data"] = receipt.response
    def on_failed(receipt):   box["data"] = None
    link.request(path, data=None, response_callback=on_response,
                 failed_callback=on_failed, timeout=TIMEOUT)
    t0 = time.time()
    while "data" not in box and time.time() - t0 < TIMEOUT + 5:
        time.sleep(0.2)
    link.teardown()

    data = box.get("data")
    if not data:
        print(f"  no response for {hash_hex}{path}", file=sys.stderr)
        return None
    if isinstance(data, str):
        data = data.encode("utf-8")

    outdir.mkdir(parents=True, exist_ok=True)
    slug = f"{hash_hex[:16]}__{path.strip('/').replace('/', '__')}"
    if not slug.endswith(".mu"):
        slug += ".mu"
    dest_file = outdir / slug
    dest_file.write_bytes(data)

    # Provenance, per file. A live snapshot is only meaningful with the node,
    # the path and the moment it was taken.
    prov = outdir / "PROVENANCE.tsv"
    if not prov.exists():
        prov.write_text("path\tnode_hash\tpage_path\tcaptured\tkind\tnote\n")
    with prov.open("a") as fh:
        fh.write(f"{dest_file.name}\t{hash_hex}\t{path}\t"
                 f"{time.strftime('%Y-%m-%d')}\tlive-snapshot\t"
                 f"frozen; never re-fetch to diff\n")
    print(f"  {len(data):6} B  {dest_file.name}")
    return data


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--listen", type=int, metavar="SECONDS")
    ap.add_argument("--fetch", metavar="NODE_HASH")
    ap.add_argument("--path", default="/page/index.mu")
    ap.add_argument("--from", dest="targets", metavar="FILE")
    ap.add_argument("--out", default="tier5-live")
    a = ap.parse_args()

    RNS.Reticulum()
    outdir = pathlib.Path(a.out)

    if a.listen:
        listen(a.listen)
    elif a.fetch:
        fetch(a.fetch, a.path, outdir)
    elif a.targets:
        for line in pathlib.Path(a.targets).read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            # Trailing "# comment" columns are for the reader, not the fetch.
            parts = [c.split("#")[0].strip() for c in line.split("\t")]
            parts = [c for c in parts if c]
            if not parts:
                continue
            fetch(parts[0], parts[1] if len(parts) > 1 else "/page/index.mu", outdir)
            # One request per node, and a pause between nodes. The network asks
            # for at most one a day; this is a single pass, so the only thing
            # left to get right is not arriving as a burst.
            time.sleep(2)
    else:
        ap.print_help()
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
