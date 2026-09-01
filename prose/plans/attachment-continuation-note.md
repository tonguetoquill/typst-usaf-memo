# Spike: the backmatter continuation note

**Issue:** [#52](https://github.com/tonguetoquill/typst-usaf-memo/issues/52)
**Status:** Confirmed; candidate implemented and measured
**Risk:** Low — layout is byte-identical on every document where nothing splits

## Confirmed

The issue reproduces exactly as filed, on `main` at 516f8cc with Typst 0.14.0.

Sweeping the issue's fixture over 18–34 body paragraphs: the signature block and
the attachment list land on different pages for 24–29, and the note prints
nowhere in that band. Outside it the whole closing section travels together and
no note is owed.

The mechanism is the one the issue describes. Instrumenting the `context` in
`render-backmatter-section` with the value it tests on:

| body | `here().position().y` | page | available | needed | note |
|---|---|---|---|---|---|
| 23 (fits) | 669.82pt | 1 | 50.18pt | 49.78pt | none — correct |
| 25 (does not fit) | 72pt | 2 | 648pt | 49.78pt | none — **wrong** |
| 27 (does not fit) | 72pt | 2 | 648pt | 49.78pt | none — **wrong** |
| 29 (does not fit) | 72pt | 2 | 648pt | 49.78pt | none — **wrong** |

`72pt` is page 2's top margin. The reading is taken from inside the element that
moved, so once it has moved the test measures an empty page against a 50pt list
and agrees it fits.

The defect is also in this repository's own shipped example. `starkindustries`
breaks its `cc:` list mid-list across pages 3 and 4 with no note on page 3.

The vendored copies in `tonguetoquill/airmark-quiver`
(`quills/usaf_memo/0.2.0` and `0.3.0`) carry the same code and the same defect.

## What the band actually looks like

Measuring the room left below the signature block on the page it stays on, over
the band where the two split:

| body | 24 | 25 | 26 | 27 | 28 | 29 |
|---|---|---|---|---|---|---|
| room below signature | 70.13pt | 56.18pt | 42.24pt | 28.30pt | 14.35pt | 0.41pt |

This is the finding that decides the design. The band is a ramp, not a plateau.
Its lower half has room for the note; its upper half has none — at 29 the
signature block ends 0.41pt above the bottom margin. **No note emitted into the
flow can serve the upper half**, because there is no flow left to emit it into.
Detection was never the whole problem.

## Candidates measured

Each was implemented and swept over the same fixture.

### A — observe instead of predict

Leave a `metadata` anchor inside the signature block's unbreakable block, and
another inside the section's. The note is owed when they resolve to different
pages. The signature block is an element with real height that stays on the page
the section departs, which is the anchor the issue's ruled-out attempts lacked.

Converges everywhere, and fires in exactly 24–29 and nowhere else — the
detection problem is solved outright. But at 27–29 the note has no room on page
1 and flows onto page 2, where it prints directly above the list it claims is on
the next page. Detection alone is not enough.

### B — A, plus a room test

Add a guard: emit only when the anchor's page has room for the note. Read from
the anchor's position rather than `here()`, so the note cannot move its own
input.

Converges everywhere; correct for 24–26; honestly silent for 27–29. Never wrong,
but only half the band is served. Notably, a first attempt at this stored the
measurement in `metadata` computed inside a `context` — that is itself a query
that updates itself, and every compile went non-convergent. Reading
`location().position()` off the anchor instead is stable.

### C — A, plus reserving the note's room (recommended)

Drop the prediction entirely and make the room unconditional. Each unbreakable
block that another section can follow carries the following section's lead-in
and note line as reserved height inside itself, reclaimed with a negative `v`
immediately after. The reservation moves only where a break may fall; nothing is
drawn into it.

The reservation does not depend on whether a note is owed, so it cannot
oscillate with the decision it enables. Where the reserved block still fits, the
note is guaranteed a slot on the departing page. Where it does not, the
signature block moves with its sections — nothing splits, and nothing is owed.
The upper half of the band resolves that way, which is also the better page:
AFH 33-337 would rather not strand the closing element.

Making this reservation conditional on a section actually following is what
keeps the change inert elsewhere. A memorandum with no backmatter reserves
nothing and breaks exactly as before.

## Result

| body | 18–23 | 24–26 | 27–29 | 30–34 |
|---|---|---|---|---|
| before | no split | split, no note | split, no note | no split |
| A | no split | note, page 1 | note on the wrong page | no split |
| B | no split | note, page 1 | no note | no split |
| C | no split | note, page 1 | no split | no split |

Every combination of 0/1/2/3/7 attachments against `cc:` and `DISTRIBUTION:`
present or absent, swept over 18–35 body paragraphs — 342 compiles, 648 sections
— holds the invariant in both directions, with no compile reporting
`layout did not converge`. `dev_assets/test_continuation_note.py` is that sweep;
it reports 161 failing sections against the unfixed source.

The sweep is what makes the check worth having. A single fixture sits on one
side of the band and passes either way.

## Why the change reaches three files

The reservation belongs to the block above the section, and the sections have to
know which of them has another following. `render-backmatter-sections` therefore
collects its sections before emitting any, which is the shape the issue proposed
for handing each section its own budget. `backmatter` decides only whether any
section exists at all.

## Cost

Layout is unchanged on `usaf-template`, `ussf-template` and `daf-template` —
identical page, x, y and text for every line. `starkindustries` changes by
exactly the defect: its `cc:` list moves off page 3 as a unit and page 3 gains
the note.

The change is otherwise visible only where a memorandum's signature block ends
within about three lines of the bottom margin and backmatter follows it. There
the block now moves to the next page with its sections.

## Open

- The reservation is one line for the note. A continuation label long enough to
  wrap would want its measured height, which the block above cannot see without
  being handed the label.
- `indorsement` takes no backmatter fields, so its signature block reserves
  nothing and breaks as before. A memorandum carrying both an attachment list
  and an indorsement was checked by hand: the note prints on the departing page
  and the indorsement's own signature block does not disturb the anchor search.
- The fix syncs down to `airmark-quiver`'s vendored copies once it lands.
