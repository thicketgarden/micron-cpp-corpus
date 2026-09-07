#!/usr/bin/env python3
"""Generate Micron the way a git-over-Reticulum node does, from pinned markdown.

Nodes like Aleph do not serve authored .mu. They run rngit, which converts
markdown to Micron on the fly. That output is a different shape from anything a
person writes by hand: true-colour spans with explicit resets, nested styles
wrapping links, box-drawing tables, literal blocks around code. Those
combinations are exactly the ones a hand-written test case never reaches.

rngit's page server cannot be used for this. RNS/Utilities/rngit/pages.py is a
NomadNetworkNode: its constructor builds an RNS.Destination, registers request
handlers and announces itself. Running it means running a node.

One layer down is a pure function. MarkdownToMicron in rngit/util.py imports in
about 0.13 s, pulls in only re and RNS, and converts a string to a string. That
is what this uses, so generation is offline and deterministic.

NOTHING HERE IS COMMITTED. The output is generated into a gitignored directory
from inputs pinned by commit SHA, so the corpus stays reproducible without
redistributing anyone's markdown. Run it before the parity suite.

  ./generate_tier2.py --out tier2-generated
"""

import argparse, base64, json, pathlib, subprocess, sys

# Pinned inputs. A SHA, not a branch: a moving input makes a moving corpus.
SOURCES = [
    ("markqvist/Reticulum", "ea98db4f53dcf0defc0e71a16e60d28b1229c4e6", ["README.md", "docs/markdown/interfaces.md", "docs/markdown/understanding.md"]),
    ("markqvist/NomadNet",  "ad10301569a39d4f43b3d21ae9fc392602c937ca", ["README.md"]),
    ("markqvist/LXMF",      "795fdaa2b0777c13033787d933d1afc94a2377cb", ["README.md"]),
]


def gh_json(path):
    out = subprocess.run(["gh", "api", path], capture_output=True, text=True)
    if out.returncode != 0:
        return None
    return json.loads(out.stdout)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="tier2-generated")
    ap.add_argument("--width", type=int, default=80)
    a = ap.parse_args()

    try:
        from RNS.Utilities.rngit.util import MarkdownToMicron
    except ImportError:
        print("needs rns installed: uv pip install rns", file=sys.stderr)
        return 1

    outdir = pathlib.Path(a.out)
    outdir.mkdir(parents=True, exist_ok=True)
    written = 0
    for repo, ref, paths in SOURCES:
        for p in paths:
            meta = gh_json(f"repos/{repo}/contents/{p}?ref={ref}")
            if not meta or "content" not in meta:
                print(f"  SKIP {repo}/{p}: not fetchable", file=sys.stderr)
                continue
            md = base64.b64decode(meta["content"]).decode("utf-8", "replace")
            sha = meta.get("sha", ref)[:12]
            micron = MarkdownToMicron(max_width=a.width).format_block(md)
            name = f"rngit-{repo.split('/')[1].lower()}-{pathlib.Path(p).stem.lower()}.mu"
            dest = outdir / name
            dest.write_text(micron if micron.endswith("\n") else micron + "\n")
            print(f"  {dest}  {micron.count(chr(10)) + 1} lines  from {repo}@{sha}")
            written += 1
    print(f"generated {written} page(s), not committed")
    return 0 if written else 1


if __name__ == "__main__":
    sys.exit(main())
