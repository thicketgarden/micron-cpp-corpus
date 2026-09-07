#!/usr/bin/env python3
"""Extract NomadNet's Guide topics from Guide.py as .mu files.

The Guide is the canonical Micron corpus: written by the format's author, and
TOPIC_MARKUP is the Micron specification written in Micron. It ships as Python
string constants rather than as files, so it has to be lifted out.

PARSED, NOT EXECUTED. Guide.py is read with ast and never imported, so nothing
in NomadNet runs to produce this. That matters because the alternative is
importing a module that pulls urwid and reaches for a running application.

One wrinkle, and it is the most valuable part of the corpus. TOPIC_MARKUP is
built in three steps (Guide.py:2038-2039): the literal assignment, then its own
source appended with `= escaped, then a closing block. That gives escaped
literal toggles nested inside a literal block, which nothing written by hand
covers. The two augmenting steps are reproduced here explicitly rather than
evaluated, and --verify checks the reconstruction against the real module.

  ./extract_guide.py --nomadnet-path <site-packages/nomadnet> --out tier3-canonical
  ./extract_guide.py ... --verify        # import once, compare, write nothing

GPL-3.0-or-later: the extracted text is NomadNet's, by Mark Qvist.
"""

import argparse, ast, pathlib, sys

# Guide.py:2038-2039, transcribed. A change upstream should break --verify
# rather than silently produce a shorter TOPIC_MARKUP.
MARKUP_TAIL = (
    "\n`=\n\n>Closing Remarks\n\nIf you made it all the way here, you should be "
    "well equipped to write documents, pages and applications using micron and "
    "Nomad Network. Thank you for staying with me.\n"
)
RECURSION_NOTE = "[ micron source for document goes here, we don't want infinite recursion now, do we? ]\n\\`="


def topics_from_source(path):
    tree = ast.parse(pathlib.Path(path).read_text())
    out = {}
    for node in tree.body:
        if isinstance(node, ast.Assign) and isinstance(node.value, ast.Constant) \
                and isinstance(node.value.value, str):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id.startswith("TOPIC_"):
                    out[t.id] = node.value.value
    if "TOPIC_MARKUP" in out:
        base = out["TOPIC_MARKUP"]
        out["TOPIC_MARKUP"] = base + base.replace("`=", "\\`=") + RECURSION_NOTE + MARKUP_TAIL
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--nomadnet-path", required=True)
    ap.add_argument("--out", default="tier3-canonical")
    ap.add_argument("--verify", action="store_true")
    a = ap.parse_args()

    guide = pathlib.Path(a.nomadnet_path) / "ui" / "textui" / "Guide.py"
    if not guide.exists():
        print(f"no Guide.py at {guide}", file=sys.stderr)
        return 1
    topics = topics_from_source(guide)

    if a.verify:
        sys.path.insert(0, str(pathlib.Path(a.nomadnet_path).parent))
        import nomadnet, urwid                                  # noqa: E402
        import nomadnet.ui.TextUI as T                          # noqa: E402
        class _UI: screen = urwid.raw_display.Screen(); colormode = T.COLORMODE_TRUE
        class _App: config = {"textui": {"theme": T.THEME_DARK}}; ui = _UI()
        nomadnet.NomadNetworkApp.get_shared_instance = staticmethod(lambda: _App())
        from nomadnet.ui.textui import Guide                    # noqa: E402
        bad = 0
        for name, text in sorted(topics.items()):
            real = getattr(Guide, name, None)
            if real != text:
                bad += 1
                print(f"  MISMATCH {name}: parsed {len(text)} B, module {len(real or '')} B")
        print("  verify: all topics match" if not bad else f"  verify: {bad} MISMATCHED")
        return 1 if bad else 0

    outdir = pathlib.Path(a.out)
    outdir.mkdir(parents=True, exist_ok=True)
    for name, text in sorted(topics.items()):
        slug = name[len("TOPIC_"):].lower().replace("_", "-")
        p = outdir / f"guide-{slug}.mu"
        p.write_text(text if text.endswith("\n") else text + "\n")
        print(f"  {p}  {text.count(chr(10)) + 1} lines  {len(text)} B")
    return 0


if __name__ == "__main__":
    sys.exit(main())
