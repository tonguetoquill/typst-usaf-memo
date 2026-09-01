// One rendering function per section of the memorandum, each placing its
// section where AFH 33-337 Chapter 14 puts it.

#import "config.typ": *
#import "utils.typ": *

// AFH 33-337 does not specify letterhead placement; the geometry below follows
// standard USAF memo convention.
#let render-letterhead(
  title,
  caption,
  font,
  letterhead-seal: none,
  letterhead-seal-subtitle: none,
  letterhead-emblem: none, // optional image placed opposite the seal (right side)
  letterhead-emblem-height: 1in, // emblem fit-box height; reduce for shorter emblems
) = {
  font = ensure-array(font)
  // `upper` takes content as readily as `str`, so the letterhead's uppercasing
  // survives a title or caption handed over as markup.
  title = upper(join-lines(title))
  caption = upper(join-lines(caption))

  // Letterhead corner geometry. The seal (left) and emblem (right) share one
  // reference band so the corners stay in parity: both bleed `corner-overhang`
  // past the page margin and center on the same axis (`band-center`). The
  // emblem may be shorter than the band but stays centered on that axis.
  let corner-overhang = 0.5in
  let corner-width = 2in
  let band-height = 1in // seal height; also the emblem's reference band
  let band-top = -band-height / 2 // puts the band center at dy 0
  let band-center = band-top + band-height / 2

  // The centered title/caption is placed content (not width-constrained), so a
  // long caption would otherwise render on one line and run underneath the seal.
  // Bound the caption to the width that stays clear of the seal on both sides
  // and auto-shrink it to fit: the seal reaches `band-height - corner-overhang`
  // into the text area, so reserving that plus a gutter on each side keeps the
  // centered caption from touching the seal. `layout` resolves the text-area
  // width so the bound tracks the page/margins.
  let caption-gutter = 0.25in
  let caption-clear = (band-height - corner-overhang) + caption-gutter
  place(
    dy: 0.625in - spacing.margin,
    box(
      width: 100%,
      fill: none,
      stroke: none,
      layout(size => place(
        center + top,
        align(center)[
          #set text(12pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
          #title\
          #v(1pt)
          #if not falsey(caption) {
            fit-to-width(
              size.width - 2 * caption-clear,
              alignment: center,
              box(text(10.5pt)[#caption]),
            )
          }
        ],
      )),
    ),
  )

  if letterhead-seal != none {
    let seal-body = if falsey(letterhead-seal-subtitle) {
      block[
        #fit-box(width: corner-width, height: band-height)[#letterhead-seal]
      ]
    } else {
      // Isolate seal column from document `font-size`: stack `em` spacing and subtitle
      // must not scale with body text (see frontmatter `set text(size: font-size)`).
      // Subtitle is wrapped in `box` so it stays on one line and may extend past
      // the seal's 2in column rather than wrapping.
      block[
        #set text(9pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
        // Spacing applies between positional stack children only, not one `[…]` body.
        #stack(
          spacing: 0.5em,
          fit-box(width: corner-width, height: band-height)[#letterhead-seal],
          box(upper(join-lines(letterhead-seal-subtitle))),
        )
      ]
    }
    place(
      left + top,
      dx: -corner-overhang,
      dy: band-top,
      seal-body,
    )
  }

  if letterhead-emblem != none {
    // Mirror the seal: same overhang and width, centered on the seal's band
    // axis. Placing the emblem's top at `band-center - height/2` keeps its
    // center on `band-center` for any (possibly shorter) emblem height.
    place(
      right + top,
      dx: corner-overhang,
      dy: band-center - letterhead-emblem-height / 2,
      block[
        #fit-box(width: corner-width, height: letterhead-emblem-height, alignment: right + horizon)[#letterhead-emblem]
      ],
    )
  }
}

// AFH 33-337 "Date": "Place the date 1 inch from the right edge, 1.75 inches from the top"
#let render-date-section(date, memo-style: "usaf") = {
  align(right)[#display-date(date, memo-style: memo-style)]
}

// AFH 33-337 "MEMORANDUM FOR": "Place 'MEMORANDUM FOR' on the second line below the date"
#let render-for-section(recipients, cols) = {
  blank-line()
  grid(
    columns: (auto, auto, 1fr),
    "MEMORANDUM FOR",
    "  ",
    align(left)[
      #if type(recipients) == array {
        create-auto-grid(recipients.map(upper), column-gutter: spacing.tab, cols: cols)
      } else {
        upper(recipients)
      }
    ],
  )
}

// AFH 33-337 "FROM:": "Place 'FROM:' in uppercase, flush with the left margin,
// on the second line below the last line of the MEMORANDUM FOR element"
#let render-from-section(from-info) = {
  blank-line()
  from-info = join-lines(from-info)

  grid(
    columns: (auto, auto, 1fr),
    "FROM:", "  ", align(left)[#from-info],
  )
}

/// Whether a `references` entry carries no citation text.
///
/// Blank entries reach the template routinely — a stub entry left under
/// `references:` for the user to fill in. Such an entry must not count as a
/// reference: a lone blank one would otherwise satisfy the "exactly one
/// reference" test below and render as an empty `()` after the subject.
///
/// - entry (any): A single `references` element
/// -> bool
#let blank-reference(entry) = falsey(entry) or entry == []

/// Drops `references` entries that carry no citation text and normalizes the
/// result to an array, so blank placeholder entries neither render on their
/// own nor affect the inline-vs-block decision.
///
/// - references (array | none): Raw reference entries
/// -> array
#let compact-references(references) = ensure-array(references).filter(entry => not blank-reference(entry))

// AFH 33-337 "SUBJECT:": "In all uppercase letters place 'SUBJECT:', flush with the
// left margin, on the second line below the last line of the FROM element"
#let render-subject-section(subject-text, inline-reference: none) = {
  blank-line()
  let content = if not blank-reference(inline-reference) {
    // `subject-text` is a content field, so it is boxed for the same reason the
    // inline reference is: a markup block's edge newlines would otherwise read
    // as a space, doubling the one before the parenthesis.
    [#box(subject-text) (#box(inline-reference))]
  } else {
    [#subject-text]
  }
  grid(
    columns: (auto, auto, 1fr),
    "SUBJECT:", "  ", content,
  )
}

// AFH 33-337: only render References block for two or more references.
// A single reference is rendered inline after the SUBJECT text instead.
#let render-references-section(references) = {
  let references = compact-references(references)
  if references.len() >= 2 {
    blank-line()
    grid(
      columns: (auto, auto, 1fr),
      // Spread the entries as enum items lettered "(a) (b) (c)" per AFH 33-337.
      "References:", "  ", enum(..references, numbering: "(a) ", body-indent: 0pt),
    )
  }
}

// AFH 33-337 "Signature Block": "Start the signature block on the fifth line below
// the last line of text and 4.5 inches from the left edge of the page or three
// spaces to the right of page center"
// AFH 33-337 "Do not place the signature element on a continuation page by itself"
// AFH 33-337 long-name example: "Signature block adjusted to the left" when a
// long name would otherwise exceed the right margin.
//
// A closing line may open the section above the block, and AFH 33-337 gives it
// one geometry across the two documents that have one: on the second line below
// the text at the block's own anchor, with the signature then five lines below
// the line rather than below the body. The memorandum's occupant is the
// authority line, "FOR THE COMMANDER"; the personal letter's is the
// complimentary close, "Sincerely", which the handbook bars the authority line
// from. Hence the neutral parameter, and hence case belongs to the caller — the
// authority line is uppercased, "Sincerely" is not.

/// The memorandum's occupant of that slot, uppercased per AFH 33-337. Blank is
/// no line: the handbook forbids one where the commander signs.
///
/// - value (str | content | none): The authority line as authored
/// -> content | none
#let format-authority-line(value) = if falsey(value) { none } else { upper(value) }

#let render-signature-block(
  signature-lines,
  closing-line: none,
  signature-blank-lines: 4,
  signing-field: none,
) = {
  signature-lines = ensure-array(signature-lines)
  // Blank is no line, whichever occupant the caller passes.
  if falsey(closing-line) { closing-line = none }
  // AFH 33-337 allows two equivalent anchors: 4.5in from the left edge, or three
  // spaces right of page center. On 8.5in stock these coincide (page center =
  // 4.25in; three TNR-12pt spaces ≈ 0.25in), so we use 4.5in as the canonical
  // anchor. pad() is relative to the text area, hence (4.5in - margin).
  let default-pad = 4.5in - spacing.margin
  context {
    // Measure each line at its rendered settings to detect long-name overflow.
    // The closing line shares the anchor, so it joins the measurement: the
    // wider of the two decides the shift and they stay aligned.
    let body-width = page.width - 2 * spacing.margin
    let anchored-lines = signature-lines
    if closing-line != none { anchored-lines.push(closing-line) }
    let widest = 0pt
    for line in anchored-lines {
      let w = measure(text(hyphenate: false, line)).width
      if w > widest { widest = w }
    }
    let stride = line-stride()
    // If the widest line would overflow the right margin at the standard
    // anchor, shift the block left just enough to fit. Clamp at 0 so the
    // block never crosses the left margin.
    let available = body-width - default-pad
    let left-pad = if widest > available {
      let shifted = body-width - widest
      if shifted < 0pt { 0pt } else { shifted }
    } else {
      default-pad
    }
    block(breakable: false)[
      #let gap = stride * signature-blank-lines
      // AFH 33-337: "fifth line below the last line of text" = four blank lines
      // between the text and the signature block. Carried INSIDE the
      // unbreakable block rather than emitted ahead of it, which keeps the gap
      // and the block one indivisible unit. The total space above the block is
      // identical either way — `block.above` still contributes the same 0.5em —
      // but a gap left outside can be consumed at the foot of one page while
      // the block starts at the top margin of the next.
      //
      // The closing line takes one of those lines above it and the gap then
      // measures from the line, not from the text. Inside the block, so no page
      // break can put it on a different page from the signature.
      #if closing-line != none {
        v(stride)
        pad(left: left-pad, text(hyphenate: false, closing-line))
      }
      #if signing-field != none {
        // The signing field covers those blank lines — where a signature is
        // actually written — so it is placed over the gap. It is placed BEFORE
        // the gap is emitted: `place` anchors at the current flow position, so
        // placing it after `v(gap)` anchors the box at the first name line and
        // paints it down over the printed signature block. Anchored here it
        // still travels with the block onto whatever page the block lands on,
        // since the gap is inside the unbreakable block rather than ahead of
        // it. The current position is below the closing line when there is
        // one, which is where the signature is written.
        //
        // The widget keeps its own size (the helper's default is 50pt tall and
        // it positions itself, so an `align` around it does nothing) and is
        // offset to the BOTTOM of the gap: it always ends where the printed
        // name begins, and whatever the gap has beyond the widget's height
        // stays clear between the body text and the widget's frame.
        let widget-height = {
          let h = measure(signing-field).height
          if h > 0pt { h } else { 50pt }
        }
        let drop = gap - widget-height - 3pt
        place(
          dx: left-pad,
          dy: if drop > 0pt { drop } else { 0pt },
          box(width: body-width - left-pad, height: widget-height, signing-field),
        )
      }
      #v(gap)
      #align(left)[
        #pad(left: left-pad)[
          #text(hyphenate: false)[
            #for line in signature-lines {
              // AFH 33-337: "indent the next line to begin under the third character
              // of the line above" — 2-character indent ≈ 1em in Times New Roman 12pt
              par(hanging-indent: .5em, line)
            }
          ]
        ]
      ]
    ]
  }
}

// The indorsement decision line is an "either / or" pair. Which pair prints
// follows from the indorsement's role in the coordination chain rather than
// from the endorser's choice, so the caller supplies the role and the same
// three `action` values carry over both pairs. The caller also suppresses the
// line entirely; reaching here means one is wanted.

// The option pair for each role, ordered (affirmative, negative).
#let APPROVAL_OPTIONS = ("Approve", "Disapprove")
#let COORDINATION_OPTIONS = ("Concur", "Nonconcur")

// Maps each `action` value to the index of the option it selects within
// whichever pair is rendered (`none` selects neither).
#let ACTION_SELECTIONS = (
  "undecided": none,
  "approve": 0,
  "disapprove": 1,
)

#let render-action-line(action, approval-authority: false, trailing-blank-line: true) = {
  assert(
    action in ACTION_SELECTIONS,
    message: "action must be one of " + ACTION_SELECTIONS.keys().map(k => "\"" + k + "\"").join(", "),
  )
  let options = if approval-authority { APPROVAL_OPTIONS } else { COORDINATION_OPTIONS }
  let selected = ACTION_SELECTIONS.at(action)
  // Underline the selected option; strike the one it was chosen over. When
  // neither is selected both render plain. An underline keeps the option on
  // the line's own baseline — the box it replaces had to be nudged with
  // `baseline` to sit straight — and reads as a mark made on the page, where a
  // ruled rectangle in a PDF carrying real AcroForm widgets reads as one more
  // fillable field.
  let render-option(index) = {
    let option = options.at(index)
    if selected == none {
      option
    } else if selected == index {
      underline(option)
    } else {
      strike(option)
    }
  }
  // No leading blank-line: the caller (indorsement.typ) already emits the
  // header→content gap once. The action line's `block(sticky: true)`
  // additionally inherits `block.above: spacing.line` so the visual gap
  // above matches the gap above a body's first paragraph.
  //
  // Keep the action line with the following content (body or signature block)
  // using the same sticky-block pattern that body.typ applies to the last
  // paragraph, per AFH 33-337 §11 orphan-prevention rules.
  block(sticky: true)[#render-option(0) / #render-option(1)]
  // Trailing blank-line places the body's first paragraph one line below
  // the action, mirroring the gap above it. Suppressed when the body is
  // empty so the signature block's own 4-line gap lands on AFH 33-337's
  // "fifth line below the last line of text" anchor.
  if trailing-blank-line {
    blank-line()
  }
}

/// Renders a table in the memorandum's style.
///
/// AFH 33-337 does not specify table formatting, so this follows the general
/// aesthetic of the standard: plain black borders, a bold header row, no
/// decorative fills, and the body font and size inherited from the surrounding
/// text.
///
/// - it (content): The table element to style and render
/// -> content
#let render-memo-table(it) = {
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    stroke: 0.5pt + black,
    inset: (x: 0.5em, y: 0.4em),
  )
  it
}

#let render-backmatter-section(
  content,
  section-label,
  numbering-style: none,
  continuation-label: none,
) = {
  let formatted-content = {
    // `text()` keeps the label from being laid out as a paragraph of its own.
    text()[#section-label]
    linebreak()
    if numbering-style != none {
      let items = ensure-array(content)
      enum(..items, numbering: numbering-style)
    } else {
      join-lines(content)
    }
  }

  context {
    let available-space = page.height - here().position().y - 1in
    if measure(formatted-content).height > available-space {
      // Attachments pass continuation-label ("… (listed on next page):" per AFH 33-337).
      // cc: and DISTRIBUTION: use a neutral default — "listed" applies to attachment lists only.
      let continuation-text = if continuation-label != none {
        text()[#continuation-label]
      } else {
        text()[#(section-label + " (continued on next page)")]
      }
      continuation-text
    }
    // `breakable: false` lets Typst's own breaker move the section to the next
    // page as a unit; an explicit pagebreak here would feed this context's
    // layout query back into its own input and the two would chase each other
    // until layout gave up.
    //
    // KNOWN DEFECT: which leaves the note above unreachable in the case it is
    // for. The section moves with `here()` inside it, so once it has moved the
    // test runs from the top of its new page, finds a page of free space, and
    // agrees it fits — and that answer is a fixed point. A section that runs
    // onto the next page therefore carries no "(listed on next page)" note,
    // which AFH 33-337 requires. Deciding the note from where the section
    // landed rather than from a prediction is the shape of the fix, and it
    // needs an anchor that stays behind: a zero-height marker is carried along
    // with the section, and making the heading the anchor did not converge.
    block(breakable: false, formatted-content)
  }
}

#let calculate-backmatter-spacing(is-first-section) = {
  context {
    let line-count = if is-first-section { 2 } else { 1 }
    blank-lines(line-count)
  }
}

// AFH 33-337 "Attachment or Attachments": "Place 'Attachment:' (for a single attachment)
// or '# Attachments:' (for two or more attachments) at the left margin, on the third
// line below the signature element"
// AFH 33-337 "Courtesy Copy Element": "place 'cc:' flush with the left margin, on the
// second line below the attachment element"

#let render-backmatter-sections(
  attachments: none,
  cc: none,
  distribution: none,
  leading-pagebreak: false,
) = {
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )

  if leading-pagebreak and has-backmatter {
    pagebreak(weak: true)
  }

  if attachments != none and attachments.len() > 0 {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
    let continuation-label = (
      (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" })
        + " (listed on next page):"
    )
    // AFH 33-337: a single attachment is not numbered; numbering applies to two or more.
    let numbering-style = if attachment-count == 1 { none } else { "1." }
    render-backmatter-section(attachments, section-label, numbering-style: numbering-style, continuation-label: continuation-label)
  }

  if cc != none and cc.len() > 0 {
    calculate-backmatter-spacing(attachments == none or attachments.len() == 0)
    render-backmatter-section(cc, "cc:")
  }

  if distribution != none and distribution.len() > 0 {
    calculate-backmatter-spacing((attachments == none or attachments.len() == 0) and (cc == none or cc.len() == 0))
    render-backmatter-section(distribution, "DISTRIBUTION:")
  }
}

