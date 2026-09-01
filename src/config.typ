// Spacing, typography, and color constants for the memorandum layout.

#let spacing = (
  line: .5em, // `par.leading`: the gap between line boxes
  tab: 0.5in, // Tab stop for multi-column recipient alignment
  margin: 1in, // AFH 33-337 §4: "Use 1-inch margins on the left, right and bottom"
)

#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC", "NimbusRomNo9L")
// AFH 33-337 §5: "Use 12 point Times New Roman font for text". NimbusRomNo9L is
// a metric-compatible clone of it; Liberation Mono, which sets raw text, is one
// of Courier New and carries its regular weight alone.
#let DEFAULT_BODY_FONTS = ("NimbusRomNo9L",)
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)
#let LETTERHEAD_COLOR = rgb("#355e93")  // Faded USAF blue

// AFH 33-337 "The Text of the Official Memorandum" §2: "Number and letter each
// paragraph and subparagraph". The spec gives four levels; deeper nesting falls
// back to an underlined bare number.
#let paragraph-config = (
  counter-prefix: "par-counter-",
  numbering-formats: ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n))),
)

// DAF (Headquarters) memo body: first-line indent for unnumbered paragraphs; nested
// items start at 1in, then +0.5in per additional nesting depth.
#let daf-paragraph = (
  top-first-line-indent: 0.5in,
  nested-first-level-indent: 1in,
  nested-step: 0.5in,
)

#let counters = (
  indorsement: counter("indorsement"),
)

// DoD/CAPCO standard marking colors, except CONFIDENTIAL and CUI, which this
// template sets black.
#let CLASSIFICATION_COLORS = (
  "TOP SECRET": rgb(255, 103, 31),
  "SECRET": rgb(200, 16, 46),
  "CONFIDENTIAL": rgb(0, 0, 0),
  "CUI": rgb(0, 0, 0),
  "UNCLASSIFIED": rgb(0, 122, 51),
)
