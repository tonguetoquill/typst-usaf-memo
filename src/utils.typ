// Spacing, normalization, and formatting helpers shared across the template.

#import "config.typ": CLASSIFICATION_COLORS, counters, paragraph-config, spacing

// Measured height of one wrapped body line, set once in `frontmatter`.
#let LINE_STRIDE = state("LINE_STRIDE")

/// The height one wrapped line of body text occupies.
///
/// Read from `LINE_STRIDE` (cached in `frontmatter`), falling back to an inline
/// measurement when the cache is unset. Reads state, so callers must already be
/// in a `context`.
///
/// -> length
#let line-stride() = {
  let stride = LINE_STRIDE.get()
  if stride == none {
    let one-line = measure(par(spacing: 0pt)[x]).height
    stride = measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
  }
  stride
}

/// Creates vertical spacing equivalent to multiple blank lines.
///
/// Adds `count` wrapped-line strides on top of the natural inter-paragraph
/// gap, so a blank line occupies exactly the same vertical space as a line
/// produced by natural paragraph wrapping.
///
/// - count (int): Number of blank lines to create
/// -> content
#let blank-lines(count) = {
  if count <= 0 { return }
  context { v(line-stride() * count) }
}

/// Creates vertical spacing equivalent to one blank line.
///
/// -> content
#let blank-line() = blank-lines(1)

/// Checks if a value is "falsey" (none, false, empty array, empty string, or
/// empty content).
///
/// A caller may hand a field over as a `str` or as content, so both empty
/// shapes count: `""` and `[]`. Empty content is what an emptied markup block
/// and `join()`-over-nothing both produce.
///
/// - value (any): The value to check for "falsey" status
/// -> bool
#let falsey(value) = {
  (
    value == none
      or value == false
      or (type(value) == array and value.len() == 0)
      or (type(value) == str and value == "")
      or value == []
  )
}

/// Scales content uniformly to fit a fixed-size box, preserving aspect ratio.
///
/// Used for letterhead seals and emblems, whose source images vary in size.
///
/// - width (length): Maximum width for the content (default: 2in)
/// - height (length): Maximum height for the content (default: 1in)
/// - alignment (alignment): Content alignment within the box (default: left+horizon)
/// - body (content): Content to scale and fit
/// -> content
#let fit-box(width: 2in, height: 1in, alignment: left + horizon, body) = context {
  let s = measure(body)
  let f = calc.min(width / s.width, height / s.height) * 100% // ratio
  // `reflow: true` so layout respects the scaled size rather than the original.
  box(width: width, height: height, clip: true)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// Shrinks content to fit within a maximum width, never enlarging it.
///
/// Measures `body` at its current font size and scales it down uniformly only
/// when it is wider than `width`; content that already fits keeps its set size
/// (the scale is capped at 100%). Unlike `fit-box`, height flows naturally and
/// small content is never scaled up. Used for the letterhead caption (unit
/// designation): a long name is shrunk to the width that clears the seal rather
/// than running underneath it. Pass a non-wrapping `box` as `body` so the
/// measured width is the single-line width and the result stays on one line.
///
/// Empty content measures 0pt wide and has no scale to compute, so it is returned
/// as-is rather than divided by; a non-positive `width` likewise admits no scale
/// that fits, so the body is left at its set size instead of being flipped or
/// collapsed.
///
/// - width (length): Maximum width the content may occupy
/// - alignment (alignment): Horizontal placement within the reserved width
/// - body (content): Content to fit (typically a non-wrapping `box`)
/// -> content
#let fit-to-width(width, alignment: left, body) = context {
  let s = measure(body)
  if s.width <= 0pt or width <= 0pt { return body }
  let f = calc.min(1, width / s.width) * 100% // ratio, capped so it only shrinks
  box(width: width)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// The date pattern a memo style prints, per AFH 33-337. Exported so a caller
/// that pre-formats the date matches this package instead of restating it.
///
/// - memo-style (str): `"usaf"` or `"daf"`
/// -> str
#let date-pattern(memo-style: "usaf") = if memo-style == "daf" {
  "[month repr:long] [day padding:none], [year]"
} else {
  "[day padding:none] [month repr:long] [year]"
}

/// Formats a date for the memo heading.
///
/// - str, content: shown as-is (a fixed placeholder, or ink the caller already
///   formatted through [`date-pattern`]).
/// - datetime: USAF style `DD Month YYYY`; DAF style `Month DD, YYYY`.
///
/// - date (str | content | datetime): Date to format for display
/// - memo-style (str): `"usaf"` or `"daf"`
/// -> content
#let display-date(date, memo-style: "usaf") = {
  assert(
    memo-style in ("usaf", "daf"),
    message: "memo-style for display-date must be \"usaf\" or \"daf\"",
  )
  // A caller that pre-formatted — to keep a click-to-edit region the package
  // cannot mint itself — passes the finished ink through untouched.
  if type(date) in (str, content) {
    date
  } else {
    date.display(date-pattern(memo-style: memo-style))
  }
}

/// Reserves the space a date occupies, for a date unknown at compile time.
///
/// Used for indorsements whose signing date is not known when the memo is
/// rendered: the endorser supplies it after the fact. The reserved box is one
/// line tall and sits on the baseline, so the slot lines up with where a
/// printed date would sit and takes exactly the space one would take.
///
/// `field` is the caller's fill-in widget, an interactive element such as a
/// PDF form field. It is anchored at the slot's top-left corner, the corner
/// such a widget's own rectangle grows right and down from, so one declared at
/// this slot's dimensions covers it exactly. With no widget to anchor, the slot
/// rules its baseline instead, for the endorser to date by hand.
///
/// - field (content | none): Fill-in widget to anchor in the slot
/// - width (length): Width of the slot; defaults to fit a long date such as
///   "15 September 2026".
/// -> content
#let date-placeholder-slot(field: none, width: 1in) = box(
  width: width,
  height: 1em,
  // Keep the slot's bottom edge on the line's baseline, where the printed date
  // would sit; the 1em height then reserves the line above it — the space a
  // handwritten date is written in.
  // (A positive baseline shift would drop the box a full line too low.)
  baseline: 0pt,
  stroke: if field == none { (bottom: 0.5pt + black) },
  if field != none { place(top + left, field) },
)

/// Gets the banner color for a classification marking.
///
/// Matches when `level` (trimmed) starts with a known prefix: TOP SECRET, SECRET,
/// CONFIDENTIAL, CUI, or UNCLASSIFIED. Otherwise returns black.
///
/// - level (str): Marking string shown in header/footer
/// -> color
#let get-classification-level-color(level) = {
  if level == none or type(level) != str {
    return rgb(0, 0, 0)
  }
  let s = level.trim()
  // Longest-prefix-first so e.g. "TOP SECRET" wins over "SECRET".
  let level-order = ("TOP SECRET", "SECRET", "CONFIDENTIAL", "CUI", "UNCLASSIFIED")
  for base-level in level-order {
    if s.starts-with(base-level) {
      return CLASSIFICATION_COLORS.at(base-level)
    }
  }
  rgb(0, 0, 0)
}

/// Arranges one cell or an array of them into a `cols`-wide grid, filled
/// row-major. Used for the MEMORANDUM FOR recipient list.
///
/// Cells may be content as readily as `str`, so a caller that builds each
/// recipient as markup — to keep the rendered glyphs traceable to their
/// source — passes it through unflattened.
///
/// - content (str | content | array): Cell(s) to arrange in grid
/// - column-gutter (length): Space between columns (default: 0.5em)
/// - cols (int): Number of columns for the grid (default: 3)
/// -> grid
#let create-auto-grid(content, column-gutter: .5em, cols: 3) = {
  let content-type = type(content)

  if content-type != array {
    content = (content,)
  }


  // Each row carries a trailing empty cell, so a row is `cols + 1` wide — the
  // width both this loop and the tail padding below count against.
  let cells = ()
  let i = 0
  for item in content {
    i += 1
    cells.push(item)
    if calc.rem(i, cols) == 0 {
      cells.push([])
    }
  }

  let remainder = calc.rem(cells.len(), cols + 1)
  if remainder != 0 {
    let padding-needed = (cols + 1) - remainder
    for _ in range(padding-needed) {
      cells.push([])
    }
  }

  grid(
    columns: calc.max(1, cols) + 1,
    column-gutter: .1fr,
    row-gutter: spacing.line,
    ..cells
  )
}

/// Normalizes a value to an array, wrapping a scalar and mapping `none` to `()`.
///
/// - value: Any value to normalize to array form
/// -> array
#let ensure-array(value) = {
  if value == none {
    ()
  } else if type(value) == array {
    value
  } else {
    (value,)
  }
}

/// Normalizes a scalar-or-array field to a single stacked-lines **content**
/// value, one array element per line.
///
/// A field may arrive as a `str` or as content, and `str(..)` on content is an
/// error. Joining with `linebreak()` rather than `"\n"` renders the same
/// stacked lines while accepting either shape.
///
/// A blank field lands as empty content, which stays `falsey` for callers that
/// test the result.
///
/// - value (any): Scalar or array of scalars/content to stack
/// -> content
///
/// Examples:
/// - join-lines(([a], [b])) → [a] + linebreak() + [b]
/// - join-lines(none) → []
#let join-lines(value) = {
  if value == none { return [] }
  let items = if type(value) == array { value } else { (value,) }
  // A `str` element is wrapped so the join is content-to-content throughout;
  // mixing `str` and content under `+` is not a legal Typst addition.
  let joined = items.map(item => [#item]).join(linebreak())
  // `().join(..)` is `none`, not `[]` — coerce so an empty array stays `falsey`.
  if joined == none { [] } else { joined }
}

/// The first element of an array, or the value itself when it is not one.
/// An empty array and `none` both yield `none`.
///
/// - value: Any value to extract from
/// -> any
#let first-or-value(value) = {
  if value == none {
    none
  } else if type(value) == array {
    if value.len() > 0 {
      value.at(0)
    } else {
      none
    }
  } else {
    value
  }
}


/// The ordinal suffix for an indorsement number: 1st, 2d, 3d, 4th, …
///
/// Military correspondence writes "2d" and "3d" where ordinary English writes
/// "2nd" and "3rd"; 11th through 13th take "th" as usual.
///
/// - number (int): The indorsement number (1, 2, 3, etc.)
/// -> str
#let get-ordinal-suffix(number) = {
  let last-digit = calc.rem(number, 10)
  let last-two-digits = calc.rem(number, 100)

  if last-two-digits >= 11 and last-two-digits <= 13 {
    "th"
  } else if last-digit == 1 {
    "st"
  } else if last-digit == 2 {
    "d"
  } else if last-digit == 3 {
    "d"
  } else {
    "th"
  }
}

/// An indorsement's header label: "1st Ind", "2d Ind", "3d Ind", …
///
/// - number (int): Indorsement sequence number (1, 2, 3, etc.)
/// -> str
#let format-indorsement-number(number) = {
  let suffix = get-ordinal-suffix(number)
  str(number) + suffix + " Ind"
}
