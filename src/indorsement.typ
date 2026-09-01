// An indorsement forwards a memorandum onward with the endorser's own
// commentary and signature, per AFH 33-337 Chapter 14.
//
// Call it as a function, `#indorsement(..)[Body]`. As a show rule it wraps the
// whole remainder of the document, which leaves room for exactly one.

#import "primitives.typ": *
#import "body.typ": *

#let indorsement(
  from: none,
  to: none,
  signature-block: none,
  // An indorsement has a closing section of its own, so it takes an authority
  // line on the same terms as the memorandum.
  authority-line: none,
  signature-blank-lines: 4,
  signing-field: none,
  date: none,
  // Fill-in widget for an omitted `date`, anchored in the date slot of the
  // indorsement header (see `date-placeholder-slot`). Without one the slot is
  // ruled for a handwritten date.
  date-field: none,
  // Format of indorsement: "standard" (same page), "informal" (no header), or "separate_page" (starts on new page)
  format: "standard",
  // Decision action. `none` (default) displays no action line at all.
  // "approve" or "disapprove" underlines the selected option and strikes the
  // other; "undecided" displays the pair with neither marked.
  action: none,
  // Role this indorsement plays in the coordination chain, which selects the
  // wording of the action line: the approval authority (the last indorsement
  // in the chain) Approves / Disapproves, every coordinating official before
  // it Concurs / Nonconcurs. The caller owns this because only it can see
  // whether further indorsements follow.
  approval-authority: false,
  content,
) = [#{
  assert(
    format in ("standard", "informal", "separate_page"),
    message: "format must be \"standard\", \"informal\", or \"separate_page\"",
  )

  if format != "informal" {
    assert(from != none, message: "from is required")
    assert(to != none, message: "to is required")
  }


  let actual-date = date
  let ind-from = first-or-value(from)
  let ind-for = to

  // An empty body renders as zero layout through render-body's filter, so the
  // spacing reserved *for* the body is suppressed too: the header→body gap
  // (when no action is present) and the action→body trailing gap. Left in,
  // they add a blank-line stride above the signature and push it off AFH
  // 33-337's "fifth line below the last line of text" anchor.
  //
  // A caller with no body passes `[]`.
  let body-empty = content == []

  let effective-action = if action == none or type(action) != str or action.trim() == "" {
    none
  } else {
    action
  }

  if format != "informal" {
    // Stepped outside the `context` below, which reads it: a step inside would
    // read and update the same counter.
    counters.indorsement.step()

    context {
      let config = query(<usaf-memo-config>).first().value
      let memo-style = config.at("memo-style", default: "usaf")
      let original-subject = config.subject
      let original-date = config.original-date
      let original-from = config.original-from

      let indorsement-number = counters.indorsement.get().at(0, default: 1)
      let indorsement-label = format-indorsement-number(indorsement-number)

      let ind-date = align(right)[#if actual-date != none { display-date(actual-date, memo-style: memo-style) } else { date-placeholder-slot(field: date-field) }]

      // Separate-page header body: restates the original memo's identity (FROM,
      // date, subject) on its own line, since the indorsement no longer shares a
      // page with the action document. Rendered as a non-breakable, sticky unit
      // so it travels to the next page *with* the content it heads rather than
      // being stranded at the bottom of a page.
      // `original-from` / `original-subject` are content fields, and a content
      // field lowers to a markup block whose newlines read as spaces in the
      // enclosing paragraph — mid-sentence that lands a stray space before the
      // following comma. `box` gives each its own paragraph context, where
      // Typst trims the edge spaces (the same treatment the inline reference
      // gets in `render-subject-section`), and keeps the phrase unbroken.
      let separate-page-body = block(breakable: false, sticky: true)[
        #[#indorsement-label to #box(original-from), #display-date(original-date, memo-style: memo-style), #box(original-subject)]
        #blank-line()
        #grid(columns: (auto, 1fr), ind-from, ind-date)
        #blank-line()
        #grid(columns: (auto, auto, 1fr), "MEMORANDUM FOR", "  ", ind-for)
      ]

      // Standard header: terse "Nth Ind, FROM    date" line, used when the
      // indorsement stays on the same page as the action document. Same
      // non-breakable + sticky treatment so the two header lines never split
      // across a page boundary and never detach from the body/signature below.
      let standard-header = block(breakable: false, sticky: true)[
        #blank-line()
        #grid(columns: (auto, 1fr), [#indorsement-label, #box(ind-from)], ind-date)
        #blank-line()
        #grid(columns: (auto, auto, 1fr), "MEMORANDUM FOR", "  ", ind-for)
      ]

      if format == "separate_page" {
        // Explicit separate-page indorsement always begins on a fresh page.
        pagebreak()
        separate-page-body
      } else {
        // AFH 33-337: a standard indorsement that no longer fits on the action
        // document's page moves to a separate page, where it carries the fuller
        // separate-page identifying header (it has lost its visual link to the
        // original). Auto-upgrade to that header when the indorsement is pushed
        // to a new page, rather than printing the terse same-page header at the
        // top of a continuation page where it no longer makes sense.
        //
        // Detection: because the header is a non-breakable, sticky unit, Typst
        // moves it wholesale to the next page when it would not fit — so a
        // pushed indorsement lands at the top content margin. If the header's
        // resolved position is at the top of its page, it was pushed; emit the
        // separate-page body (no extra pagebreak — we are already at page top).
        // Otherwise the header flows in place with the standard form.
        let stride = line-stride()
        // here().position().y is the resolved flow position of this header. On a
        // continuation page the first content sits at the top margin; allow one
        // line stride of tolerance for baseline/rounding.
        let pushed-to-new-page = here().position().y <= spacing.margin + stride
        if pushed-to-new-page {
          separate-page-body
        } else {
          standard-header
        }
      }
    }
    // Header→content gap. Skipped when there is neither an action line nor
    // body to follow — render-signature-block supplies its own 4-line gap.
    if effective-action != none or not body-empty {
      blank-line()
    }
  }

  if effective-action != none {
    render-action-line(
      effective-action,
      approval-authority: approval-authority,
      trailing-blank-line: not body-empty,
    )
  }

  if not body-empty {
    context {
      let memo-style = query(<usaf-memo-config>).first().value.at("memo-style", default: "usaf")
      render-body(content, memo-style: memo-style)
    }
  }

  render-signature-block(
    signature-block,
    closing-line: format-authority-line(authority-line),
    signature-blank-lines: signature-blank-lines,
    signing-field: signing-field,
  )
  // Labelled so `mainmatter` can split the closing off the body; `split-closing`.
}<usaf-memo-closing>]
