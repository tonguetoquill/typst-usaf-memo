"""Closing sections survive `#show: mainmatter`.

Applied as a show rule, `mainmatter` receives the whole remainder of the
document — `backmatter` and any `indorsement` along with the body. Those must
be split back out before `render-body` rebuilds the body from its paragraph
buffer, or they lose the placement they are made of and their surviving lines
are numbered as body paragraphs.

The two fixtures are the same memorandum written both ways. Rendering them to
the same glyphs at the same positions is the invariant.
"""

from pathlib import Path
import sys
import tempfile

try:
    import pymupdf
    import typst
except ImportError as exc:
    raise SystemExit(
        "This regression check requires the Python packages 'typst' and 'pymupdf'."
    ) from exc


REPO_ROOT = Path(__file__).resolve().parent.parent
FONT_PATHS = [str(REPO_ROOT), str(REPO_ROOT / "fonts")]
FIXTURES = {
    "show rule": REPO_ROOT / "dev_assets" / "test_closing_sections_showrule.typ",
    "function": REPO_ROOT / "dev_assets" / "test_closing_sections_function.typ",
}
# The signature block anchors 4.5in from the page's left edge (AFH 33-337), not
# at the 1in left margin the body sits on.
SIGNATURE_ANCHOR_PT = 4.5 * 72


def render(fixture: Path) -> list[tuple[float, float, str]]:
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as compiled:
        output_path = Path(compiled.name)
    try:
        typst.compile(
            str(fixture),
            output=str(output_path),
            root=str(REPO_ROOT),
            font_paths=FONT_PATHS,
        )
        spans = []
        for page in pymupdf.open(output_path):
            for block in page.get_text("dict")["blocks"]:
                if block.get("type") != 0:
                    continue
                for line in block["lines"]:
                    text = "".join(span["text"] for span in line["spans"]).strip()
                    if text:
                        spans.append((round(line["bbox"][0], 1), round(line["bbox"][1], 1), text))
        return spans
    finally:
        output_path.unlink(missing_ok=True)


def main() -> int:
    rendered = {name: render(path) for name, path in FIXTURES.items()}

    if rendered["show rule"] != rendered["function"]:
        only = set(map(repr, rendered["show rule"])) ^ set(map(repr, rendered["function"]))
        raise AssertionError(
            "`#show: mainmatter` and `#mainmatter[…]` rendered differently: "
            + ", ".join(sorted(only))
        )

    lines = rendered["show rule"]
    by_text = {text: (x, y) for x, y, text in lines}

    for expected in ("FOR THE COMMANDER", "Attachment:", "1st Ind, TEST/DO", "Approve / Disapprove"):
        if expected not in by_text:
            raise AssertionError(f"Closing section did not render: {expected!r}")

    for name in ("FIRST M. LAST, Maj, USAF", "SECOND N. LAST, Capt, USAF"):
        x, _ = by_text[name]
        if abs(x - SIGNATURE_ANCHOR_PT) > 1.0:
            raise AssertionError(
                f"Signature block {name!r} sits at x={x:.1f}pt, not the "
                f"{SIGNATURE_ANCHOR_PT:.0f}pt AFH 33-337 anchor — it was rebuilt as body text."
            )

    numbered = [text for _, _, text in lines if text.startswith(("3.", "4.", "5.", "6."))]
    if numbered:
        raise AssertionError(f"Closing section lines took body paragraph numbers: {numbered}")

    print(f"Closing-section check passed: {len(lines)} lines identical across both forms.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
