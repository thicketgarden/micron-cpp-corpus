#!/usr/bin/env python3
"""
browse.mu — a Lynx/w3m-style text-web-browser entry point for a NomadNet
node, built on HTML2Micron.

Install as an *executable* page on a NomadNet node (e.g.
`~/.nomadnetwork/storage/pages/browse.mu`, `chmod +x browse.mu`). NomadNet
runs it as a subprocess per request and uses stdout as the page body — see
the "Executable Micron pages" section of the NomadNet Guide.

Request field values arrive as environment variables prefixed `field_`
(actual form fields) or `var_` (literal key=value pairs written in a
link's field spec) — confirmed straight from NomadNet's own source, not
guessed: the *client* adds these prefixes itself when it builds a request
(`nomadnet/ui/textui/Browser.py`, `request_data["var_"+key] = value` for
literal pairs and `request_data["field_"+w.field_name] = ...` for actual
fields) before NomadNet's node-side dispatcher passes them straight
through as the subprocess environment (`nomadnet/Node.py`, `serve_page`).
The consequence that's easy to get backwards: *this script* reads
`os.environ["var_url"]`, but when *authoring* an outbound link's field
spec it writes plain `url=...` — the "var_" prefix is added by the client
when the link is followed, never written by the page author.

Not every Micron client necessarily reproduces NomadNet's own var_/field_
split faithfully for every case (the Go link's `*` wildcard submits a
named field, which real NomadNet sends as field_url — but this isn't
guaranteed elsewhere), so `_resolve_navigation()` below decides what a
submitted value *is* by its shape (does it look like a linkstore token?)
rather than trusting the prefix alone.

Why this needs its own link_resolver (HTML2Micron's library default just
resolves relative hrefs to absolute and passes http(s) URLs through
unchanged): a bare NomadNet/Reticulum client has no independent way to
fetch an arbitrary internet URL — *this script's host* is the one with
internet access. So every link discovered on a converted page is
rewritten to re-enter this same script with the new target instead of
pointing at the raw destination — click a link on a converted Wikipedia
page, and NomadNet sends you right back through this script with the new
target.

Outbound links are shortened through linkstore.py (a small local SQLite
short-link table, TTL 3 hours) rather than embedding even a shortened
form of the real URL: every link becomes `url=<6-char token>`, resolved
back to the real target when it's followed. That's a bigger saving than
any string-shortening trick (path-only, protocol-relative, etc.) could
give — constant-size regardless of how long or deeply-nested the real
URL is — which matters on a page with dozens of links over a
bandwidth-constrained connection. A link older than the TTL (or from a
different node run, if the store was cleared) shows a friendly expired
message instead of a crash.

The address bar doubles as a search box, Lynx/w3m-style: text that looks
like a URL or a bare domain is fetched directly; anything else is treated
as a search query and sent to Mojeek — confirmed directly (fetched with
this project's own default mobile UA, no JS): Mojeek's `/search?q=...`
returns real, direct result links in plain static HTML with no bot
challenge, unlike DuckDuckGo's `/html/` endpoint (previously used here),
which now serves an "anomaly" image-selection CAPTCHA to every static
request regardless of UA, and Bing, whose response ships a
"PoWChallengeSolver" proof-of-work script gating real results behind JS
execution. Startpage returned an explicit CAPTCHA page outright. None of
that is a promise Mojeek stays this way forever — bot-friendliness on a
public search engine's HTML endpoint is inherently something that can
change on their end without notice, the exact way DuckDuckGo's did — so
if this one also starts blocking, re-run the same check
(fetch_bytes + look for a CAPTCHA/challenge/anomaly marker) against a
few alternatives before picking a replacement.
"""

import itertools
import os
import re
import sys
import textwrap
from urllib.parse import parse_qsl, quote, urlencode, urljoin, urlsplit, urlunsplit

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import linkstore
from html2micron import HTMLToMicronConverter, ImagePolicy, sanitize_field_value

# Pre-filled as a suggestion in the address bar on the no-args info
# screen only (see main()) -- not "Home"'s own destination anymore
# (see build_nav_bar's comment on the Home link for why). Change this
# to whatever site makes sense to suggest first for a given deployment.
HOME_URL = "https://example.com"
SEARCH_URL = "https://www.mojeek.com/search"
WIDTH = 72
MAX_IMAGES_ON = 6
MAX_IMAGES_OFF = 0
# This script runs under an external hard time budget (a Micron preview
# extension's own script timeout, confirmed directly: 15s by default).
# Passed as HTMLToMicronConverter's deadline_seconds, not just relied
# on as an outer kill switch -- an outer timeout can only produce
# *nothing at all* (the process gets killed mid-run, no partial output
# possible); the library needs to know its own budget to gracefully
# stop fetching/rendering more images and fall back to placeholders for
# the rest instead. Confirmed as a real, necessary fix on a real page:
# nasa.gov with Render JS on took 13-17s across repeated runs (profiled:
# real network I/O plus img2contourascii's own ~850ms-per-image color-
# quantization cost, not a fixable inefficiency), exceeding this budget
# often enough to matter. 10s leaves real headroom below the 15s
# external limit for this script's own startup, output writing, and the
# small, expected overshoot from an image render already in progress
# when the deadline is reached (confirmed empirically: ~11.8-12.1s
# actual total from a 10s deadline, comfortably under 15s across
# repeated runs).
CONVERSION_DEADLINE_SECONDS = 10

_BARE_DOMAIN_RE = re.compile(r"^[\w.-]+\.[a-zA-Z]{2,}(/.*)?$")
_INTERNAL_PATH = ":/page/browse.mu"

# Shown only on the initial no-args home screen (see main()) -- a
# first-time visitor to this page has no other explanation of what it
# does or how to drive it anywhere else in the UI, so this is the one
# place that has to cover it. Kept to plain paragraphs/short lines
# (no nested lists/tables) since it's the very first thing rendered,
# before any real content, and needs to stay legible on a narrow
# terminal-width client.
#
# Wrapped at HOME_SCREEN_WRAP_WIDTH rather than left as one long
# logical line per paragraph -- this text is written directly to
# stdout, bypassing the converter's own word-wrap (that only applies
# to *converted page* content, not this script's static Micron).
# textwrap.fill() is safe here specifically because every `!...`!/
# `_..._` span below is either short (a single word/phrase, so it
# can't straddle a wrap point) or, where it wraps a longer phrase
# (the opening sentence), closes well before any wrap point -- Micron
# resets bold/underline at the end of every physical line, so a
# formatting token split across a wrap would silently lose the
# second half of its own styling. Confirmed by inspecting the
# wrapped output directly: no `!/`_ pair straddles a line break.
HOME_SCREEN_WRAP_WIDTH = 100


def _wrap_home_paragraph(text: str) -> str:
    return textwrap.fill(text, width=HOME_SCREEN_WRAP_WIDTH, break_long_words=False, break_on_hyphens=False)


HOME_SCREEN_TEXT = "\n" + "\n\n".join([
    _wrap_home_paragraph(
        "`!This is a text-based web browser for NomadNet/Reticulum.`! "
        "It fetches a regular web page and converts it into Micron, "
        "images included (drawn as ASCII/ANSI art) — so you can browse "
        "the ordinary internet from inside a mesh network client."
    ),
    "`_Getting started`_\n" + _wrap_home_paragraph(
        "Type a URL (like `!example.com`!) or a search term into the box "
        "above and choose `!Go`!. Text that doesn't look like a URL is "
        "sent to a search engine automatically — there's no separate "
        "search box to find."
    ),
    "`_Following links`_\n" + _wrap_home_paragraph(
        "Any link found on a converted page becomes a normal Micron link "
        "you can follow directly, the same as a link on this page. Some "
        "pages also have their own search box, which shows up as an "
        "editable field with its own `!Search`! link right on the page — "
        "typing into it searches that site directly, not this browser's "
        "own address bar."
    ),
    "`_Options`_\n" + _wrap_home_paragraph(
        "`!Load images`! turns picture rendering on or off — images cost "
        "real bandwidth over a mesh link, so turning this off gives a "
        "faster, text-only page. `!Render JS`! runs the page's own "
        "JavaScript before converting it (slower — a real browser launch "
        "under the hood) for pages that otherwise show up blank or "
        "broken; leave it off unless a page needs it."
    ),
    _wrap_home_paragraph("Click `!Home`! at any time to come back to this page."),
]) + "\n"


def field(name):
    """A request field can arrive as either field_<name> (an actual form
    field the user typed into) or var_<name> (a literal value baked into
    a link's field spec, which is how our own outbound links carry their
    target) — accept either. Only used for fields where the two cases
    don't need different handling (unlike "url" — see _resolve_navigation()).
    """
    return os.environ.get(f"field_{name}") or os.environ.get(f"var_{name}")


def resolve_input(text: str) -> str:
    """Address-bar-and-search-box, in one field: URL-shaped input is
    fetched directly, anything else becomes a Mojeek query.
    """
    text = text.strip()
    if text.startswith("http://") or text.startswith("https://"):
        return text
    if " " not in text and _BARE_DOMAIN_RE.match(text):
        return "https://" + text
    return SEARCH_URL + "?" + urlencode({"q": text})


def build_nav_bar(current_url: str, images_on: bool, render_on: bool) -> str:
    images_checkbox = "?|images|1" + ("|*" if images_on else "")
    render_checkbox = "?|render|1" + ("|*" if render_on else "")
    return (
        "`B222`F9f3 HTML2Micron Browser `f`b\n"
        # "|images" and "|render" on every link we generate (here and in
        # make_link_resolver below) reference those checkbox fields by
        # name so their *current* state rides along — without it, only
        # the Go link (which submits via the `*` wildcard) preserved
        # them, and clicking any in-page content link silently reset
        # both back off.
        #
        # Deliberately carries no `url=` field at all (confirmed as a
        # real bug: it used to point at HOME_URL via a linkstore token,
        # so clicking Home actually *fetched and converted* that page
        # instead of returning to this script's own no-args info
        # screen — HOME_SCREEN_TEXT, explaining what the browser does,
        # never showed at all once a session had navigated anywhere).
        # With no `url=` submitted, var_url is simply absent on the
        # request Home makes, and _resolve_navigation() correctly falls
        # through to the (None, None, None) "no target" case.
        f"`c`[Home`{_INTERNAL_PATH}`images|render]`a\n"
        f"`<40|url`{current_url or ''}>\n"
        f"`<{images_checkbox}`> Load images  "
        f"`<{render_checkbox}`> Render JS (slow — only if the page looks blank)  "
        f"`[Go`{_INTERNAL_PATH}`*]\n"
        "-\n"
    )


def make_link_resolver():
    """Rewrite every discovered outbound link into a short-token
    self-referencing link — see the module docstring for why a token
    beats even a shortened-string form of the URL.
    """
    def resolve(href: str, base_page_url: str) -> str:
        absolute = urljoin(base_page_url, href) if base_page_url else href
        if not (absolute.startswith("http://") or absolute.startswith("https://")):
            return "#"
        token = linkstore.shorten(absolute)
        return f"{_INTERNAL_PATH}`url={token}|images|render"
    return resolve


def _bake_query_params(url: str, pairs: list) -> str:
    """Merge ``pairs`` into ``url``'s existing query string, preserving
    whatever query params it already had. Same logic as HTML2Micron's
    own document.py._bake_query_params (which folds a form's *hidden*
    inputs into its action URL at conversion time) — this is the
    matching other half, folding the *submitted* visible field values
    in at click time. Kept as a small local duplicate rather than a
    shared import: browse.mu is deliberately self-contained, per its
    existing convention (see linkstore.py living alongside it instead
    of being a library module).
    """
    parts = urlsplit(url)
    combined = parse_qsl(parts.query, keep_blank_values=True) + pairs
    return urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(combined), parts.fragment))


_FIELD_WIDTH = 30
_UNSAFE_FIELD_CHARS = re.compile(r"[^A-Za-z0-9_-]")


def _safe_field_name(name: str) -> str:
    return _UNSAFE_FIELD_CHARS.sub("_", name).strip("_") or "field"


def make_form_resolver():
    """Render a GET search form's field(s) plus a submit link that
    re-enters this same script, mirroring make_link_resolver() above —
    but a form's real target isn't known until *after* the user types
    something, so (unlike a plain link) it can't be pre-shortened to a
    single token up front. Only the form's action URL (hidden `<input>`
    values already folded in by HTML2Micron before this resolver ever
    sees it) gets a linkstore token; the user's typed value(s) travel as
    real submitted field values and get folded in at click time instead
    (see _resolve_navigation's new `form_action` branch below).

    Each call renders one form; the returned closure's counter
    namespaces every field name it emits (f0__, f1__, ...) — confirmed
    necessary on a real page (Wikipedia has two nearly-identical search
    forms on one page, both named "search"): without namespacing, two
    Micron fields sharing one name would make a bare-name field-spec
    reference ambiguous. This also makes browse.mu's own reserved names
    (url, images, render, form_action) structurally uncollidable with
    any field name a page's own form happens to use.
    """
    counter = itertools.count()

    def resolve(action_url: str, fields: list, base_page_url: str) -> str:
        idx = next(counter)
        names = [f"f{idx}__{_safe_field_name(f.name)}" for f in fields]
        token = linkstore.shorten(action_url)
        lines = [f"`<{_FIELD_WIDTH}|{name}`{sanitize_field_value(f.value)}>"
                 for name, f in zip(names, fields)]
        spec = "|".join(["form_action=" + token] + names + ["images", "render"])
        lines.append(f"`[Search`{_INTERNAL_PATH}`{spec}]")
        return "\n".join(lines)
    return resolve


_TOKEN_RE = re.compile(r"^[a-z0-9]{6}$")
_FORM_FIELD_ENV_RE = re.compile(r"^(field|var)_f\d+__(.+)$")


def _collect_submitted_form_fields() -> list:
    """Recover a form submission's actual field name/value pairs from
    the request environment — every field make_form_resolver() rendered
    carries an `f<index>__` namespace prefix (see there for why), so
    matching that pattern (rather than an easy-to-miss denylist of
    reserved names) is what actually distinguishes "this env var is one
    of the form's own fields" from browse.mu's own reserved ones.
    """
    by_name = {}
    for key, val in os.environ.items():
        match = _FORM_FIELD_ENV_RE.match(key)
        if not match:
            continue
        prefix, orig_name = match.group(1), match.group(2)
        # field_ (an actual typed value) wins over var_ (a literal
        # default) if somehow both arrived for the same name.
        if orig_name not in by_name or prefix == "field":
            by_name[orig_name] = val
    return list(by_name.items())


def _resolve_navigation():
    """Figure out (target_url, display_url, error) for this request, or
    (None, None, None) for the initial no-args home screen.

    In principle var_url (a link we generated ourselves was followed) is
    always a linkstore token, and field_url (the user typed something and
    hit Go) is always raw text for resolve_input() — real NomadNet keeps
    these apart, prefixing literal field-spec pairs with var_ and actual
    named fields (like the address bar, submitted via the Go link's `*`
    wildcard) with field_. Not every Micron client necessarily replicates
    that distinction faithfully for the wildcard case, though, so rather
    than trust *which* prefix a value arrived under, decide by what the
    value itself looks like — a client that mislabels the address bar's
    real URL as var_url still resolves correctly this way instead of
    being misread as an (inevitably invalid) token lookup.

    A form submission (see make_form_resolver()) is checked first: its
    `form_action` field is a marker only that mechanism ever sets, so
    there's no shape-based ambiguity to resolve the way there is for
    `url`.
    """
    form_token = field("form_action")
    if form_token:
        base_url = linkstore.resolve(form_token)
        if base_url is None:
            return None, None, (
                "That search has expired (short links are only kept for a few "
                "hours) — go back Home and search again."
            )
        pairs = _collect_submitted_form_fields()
        target = _bake_query_params(base_url, pairs) if pairs else base_url
        return target, target, None

    value = os.environ.get("var_url") or os.environ.get("field_url")
    if not value or not value.strip():
        return None, None, None
    value = value.strip()

    if _TOKEN_RE.match(value):
        target = linkstore.resolve(value)
        if target is None:
            return None, None, (
                "That link has expired (short links are only kept for a few "
                "hours) — go back Home and navigate there again."
            )
        return target, target, None

    return resolve_input(value), value, None


def main():
    target_url, current_display_url, error = _resolve_navigation()
    images_on = field("images") is not None
    render_on = field("render") is not None

    if error:
        sys.stdout.write(build_nav_bar(None, images_on=True, render_on=False))
        sys.stdout.write(f"\n`Ff00{error}`f\n")
        return

    if not target_url:
        sys.stdout.write(build_nav_bar(HOME_URL, images_on=True, render_on=False))
        sys.stdout.write(HOME_SCREEN_TEXT)
        return

    sys.stdout.write(build_nav_bar(current_display_url, images_on, render_on))

    try:
        converter = HTMLToMicronConverter(
            link_resolver=make_link_resolver(),
            form_resolver=make_form_resolver(),
            image_policy=ImagePolicy(
                max_images=MAX_IMAGES_ON if images_on else MAX_IMAGES_OFF,
            ),
            width=WIDTH,
            deadline_seconds=CONVERSION_DEADLINE_SECONDS,
        )
        # Explicit True/False here, never the library's "auto" default —
        # this script runs under an external hard time budget (a Micron
        # preview extension's own script timeout, confirmed directly:
        # 15s by default), and Playwright's real cost (browser launch +
        # multi-second render) is exactly the kind of unpredictable
        # latency that budget can't absorb by surprise. Rendering is
        # opt-in per page via the checkbox instead of silently
        # triggering on every page whose static content happens to look
        # thin — a page that's merely short (not JS-only) would pay that
        # cost for nothing under "auto".
        body = converter.convert_url(target_url, render=render_on)
    except Exception as e:
        sys.stdout.write(f"`Ff00Couldn't load that page:`f {e}\n")
        return

    sys.stdout.write(body)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
