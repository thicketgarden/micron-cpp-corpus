#!/usr/bin/env python3
"""Freeze the Micron that executable NomadNet pages produce.

A page with the executable bit is a PROGRAM. NomadNet runs it and serves its
stdout; the .mu file on disk is source. The corpus held the sources and none of
the OUTPUT, which is the Micron a reader actually receives and the shape most
likely to hide a parser or layout bug, because no human wrote it.

MANUAL, NOT CI. Regenerating per run would re-introduce timestamps, randomness
and node state, and the corpus is frozen on purpose. This produces files; CI
compares files.

The invocation matches Node.py:132-146 exactly: the program is run with a
MINIMAL environment holding only PATH, link_id, remote_identity and any
field_*/var_* the request carried. Nothing else is inherited.

  ./generate_dynamic.py --probe          what runs, what it produces, is it stable
  ./generate_dynamic.py --write          freeze the stable ones into tier4-generated/

⚠ This EXECUTES third-party code from the corpus sources. It is a deliberate,
manual step, run on scripts that were read first.
"""

import argparse, hashlib, os, pathlib, subprocess, sys, time

TIMEOUT = 15

# Representative request shapes rather than every page. Each entry is a page and
# the request that exercises one thing: an empty form, a submission carrying
# field data, a built list, an error path.
# Pages known to vary intermittently, excluded by name. names.mu passed a
# three-run gate and failed a two-run one on the same input, which means it
# varies on something slower than three runs apart. A page that reproduces most
# of the time is worse in a frozen corpus than one that never does.
EXCLUDE = {"lora-rnode/pages/names.mu"}

CASES = [
    ("empty-form",   {}),
    ("submitted",    {"field_search": "reticulum", "var_do_search": "1"}),
    ("no-results",   {"field_search": "zzzzzzzzzznotathing", "var_do_search": "1"}),
]

IDENT = {
    # Fixed, so a page that echoes them stays reproducible.
    "link_id": "00000000000000000000000000000000",
    "remote_identity": "11111111111111111111111111111111",
}


def run(page: pathlib.Path, fields: dict):
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin")}
    env.update(IDENT)
    env.update(fields)
    try:
        p = subprocess.run([str(page)], stdout=subprocess.PIPE,
                           stderr=subprocess.DEVNULL, env=env,
                           cwd=str(page.parent), timeout=TIMEOUT)
        return p.returncode, p.stdout
    except subprocess.TimeoutExpired:
        return None, b""
    except Exception:
        return None, b""


def executable_pages(corpus: pathlib.Path):
    """From the manifest, which records the real mode. A shebang is not the
    marker: static pages carry one, and #!c=3600 is a page directive."""
    man = corpus / "MANIFEST.tsv"
    out = []
    for line in man.read_text().splitlines()[1:]:
        f = line.split("\t")
        if len(f) >= 6 and f[5] == "100755":
            p = corpus / f[0]
            if p.exists():
                out.append((p, f[1], f[2], f[4]))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--corpus", default=".")
    ap.add_argument("--probe", action="store_true")
    ap.add_argument("--write", action="store_true")
    a = ap.parse_args()
    corpus = pathlib.Path(a.corpus).resolve()

    pages = executable_pages(corpus)
    print(f"{len(pages)} executable page(s) in the manifest\n")

    outdir = corpus / "tier4-generated"
    rows = []
    kept = 0
    for page, url, sha, lic in pages:
        if any(str(page).endswith(x) for x in EXCLUDE):
            print(f"  EXCLUDED (varies intermittently)  {page.name}")
            continue
        os.chmod(page, 0o755)                      # the fetch dropped the bit
        for case, fields in CASES:
            rc, out1 = run(page, fields)
            if rc is None or not out1.strip():
                continue
            # A body of nothing but NomadNet directives is not a page. A script
            # that failed on a missing dependency still prints its #! header,
            # and freezing that as corpus would be freezing the failure.
            body = b"\n".join(l for l in out1.split(b"\n")
                               if not l.startswith(b"#!") and l.strip())
            if len(body) < 32:
                continue
            # THREE runs, not two. A page that varies can match twice by luck,
            # and one did: names.mu read stable on one request shape and
            # unstable on another. Anything that varies at all is excluded.
            stable = all(run(page, fields)[1] == out1 for _ in range(2))
            h = hashlib.sha256(out1).hexdigest()[:12]
            rel = str(page.relative_to(corpus))
            print(f"  {'STABLE ' if stable else 'UNSTABLE'} rc={rc} {len(out1):6}B {h}  "
                  f"{rel}  [{case}]")
            if not stable:
                continue
            kept += 1
            if a.write:
                outdir.mkdir(exist_ok=True)
                slug = rel.replace("/", "__").removesuffix(".mu")
                dest = outdir / f"{slug}--{case}.mu"
                dest.write_bytes(out1)
                rows.append("\t".join([
                    str(dest.relative_to(corpus)), url, sha,
                    time.strftime("%Y-%m-%d"), lic, "generated",
                    " ".join(f"{k}={v}" for k, v in sorted(fields.items())) or "(no fields)",
                ]))
    print(f"\n{kept} stable output(s)")
    if a.write and rows:
        (corpus / "tier4-generated" / "PROVENANCE.tsv").write_text(
            "path\tsource_url\tcommit\tgenerated\tlicense\tkind\trequest\n"
            + "\n".join(rows) + "\n")
        print(f"wrote {len(rows)} file(s) to tier4-generated/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
