// Paragraph numbering, nesting, and indentation for the memorandum body.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-memo-table

/// Gets the numbering format for a specific paragraph level.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> str | function
#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

/// Calculates indentation for USAF-style paragraphs from explicit counter values.
///
/// - level (int): Paragraph nesting level (0-based)
/// - level-counts (dictionary): Maps level index strings to their current counter values
/// -> length
#let calculate-indent-from-counts(level, level-counts) = {
  if level == 0 {
    return 0pt
  }
  let total-indent = 0pt
  for ancestor-level in range(level) {
    let ancestor-value = level-counts.at(str(ancestor-level), default: 1)
    let ancestor-format = get-paragraph-numbering-format(ancestor-level)
    let ancestor-number = numbering(ancestor-format, ancestor-value)
    total-indent += measure([#ancestor-number#"  "]).width
  }
  total-indent
}

/// Calculates fixed indentation for DAF paragraph levels.
///
/// First nested level starts at `nested-first-level-indent` (1in); deeper levels
/// add `nested-step` (0.5in) per additional depth.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> length
#let calculate-daf-indent(level) = {
  if level <= 0 {
    return 0pt
  }
  daf-paragraph.nested-first-level-indent + (level - 1) * daf-paragraph.nested-step
}

#let reset-levels-from(level-counts, start, max-levels) = {
  for child in range(start, max-levels) {
    level-counts.insert(str(child), 1)
  }
  level-counts
}

/// The horizontal offset at which a paragraph's *text* sits: its indent plus
/// the width of the number label that precedes it.
///
/// This is where a later block of the same paragraph — a continuation, a block
/// quote — lines up, so the two callers share one measurement rather than each
/// spelling it. A top-level paragraph carries no indent and its label is the
/// left margin itself, so the offset is zero.
///
/// - level (int): Nesting level (0-based)
/// - level-counts (dictionary): Current counter values per level
/// - indent-fn (function): `(level, level-counts) -> length`
/// -> length
#let paragraph-text-offset(level, level-counts, indent-fn) = {
  if level <= 0 { return 0pt }
  let current-value = level-counts.at(str(level), default: 1)
  let number-text = numbering(get-paragraph-numbering-format(level), current-value)
  indent-fn(level, level-counts) + measure([#number-text#"  "]).width
}

/// Formats a paragraph (or continuation) with a given indent strategy.
///
/// - body (content): Paragraph content
/// - level (int): Nesting level (0-based)
/// - level-counts (dictionary): Current counter values per level
/// - indent-fn (function): `(level, level-counts) -> length`
/// - continuation (bool): If true, adds number-label width to alignment
/// -> content
#let format-par(body, level, level-counts, indent-fn, continuation: false) = {
  if continuation {
    // Offset the first line only, which is how the numbered paragraph this
    // block continues is set: its own wrapped lines return to the left margin
    // too, so the two read as one paragraph.
    [#h(paragraph-text-offset(level, level-counts, indent-fn))#body]
  } else {
    let indent-width = indent-fn(level, level-counts)
    let current-value = level-counts.at(str(level), default: 1)
    let number-text = numbering(get-paragraph-numbering-format(level), current-value)
    [#h(indent-width)#number-text#"  "#body]
  }
}

// AFH 33-337 "The Text of the Official Memorandum" §1-12: number and letter
// each paragraph and subparagraph as 1. / a. / (1) / (a); leave a top-level
// paragraph flush left and a lone paragraph unnumbered (§2); indent each
// subparagraph to align with the first character of its parent's text.
//
// Rendering takes two passes. The first lays the content out hidden, so that
// Typst's own show rules resolve, and buffers each paragraph, table, and block
// quote with the nesting level it was found at. The second emits the buffer,
// where those show rules are out of scope and numbering can be assigned in
// document order.
#let render-body(content, memo-style: "usaf") = {
  let PAR_BUFFER = state("PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("NEST_DOWN")
  NEST_DOWN.update(0)
  let NEST_UP = counter("NEST_UP")
  NEST_UP.update(0)
  let IS_HEADING = state("IS_HEADING")
  IS_HEADING.update(false)
  // Tracks whether the next paragraph is the first block in a list item.
  // When true, the next `show par` captures a numbered item; subsequent
  // paragraphs within the same item are continuations (no new number).
  let ITEM_FIRST_PAR = state("ITEM_FIRST_PAR")
  ITEM_FIRST_PAR.update(false)

  let first-pass = {
    show par: p => context {
      let nest-level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is-heading = IS_HEADING.get()
      let is-first-par = ITEM_FIRST_PAR.get()

      // Determine if this is a continuation block within a multi-block list item.
      // A continuation is a non-first paragraph inside a list item (nest-level > 0).
      let is-continuation = nest-level > 0 and not is-first-par

      PAR_BUFFER.update(pars => {
        pars.push((
          content: text([#p.body]),
          nest-level: nest-level,
          kind: if is-heading { "heading" } else if is-continuation { "continuation" } else { "par" },
        ))
        pars
      })

      // After the first paragraph of a list item, mark subsequent ones as continuations
      if nest-level > 0 and is-first-par {
        ITEM_FIRST_PAR.update(false)
      }

      p
    }
    // Tables are buffered whole; nothing inside one takes a paragraph number.
    show table: t => context {
      PAR_BUFFER.update(pars => {
        pars.push((
          content: t,
          nest-level: -1,
          kind: "table",
        ))
        pars
      })
      t
    }
    // AFH 33-337 numbers paragraphs and letters subparagraphs, and a body
    // sometimes has to hold lines that are neither: a roster of names, a quoted
    // passage, an address. The block quote is where an author says so — its
    // content reaches the page verbatim, taking no number, letter, or bullet.
    //
    // Returning `none` rather than the quote is what makes that true: the
    // quote's own paragraphs are never laid out here, so the `show par` above
    // never sees them and cannot number them. The buffered body is emitted in
    // the second pass, where these show rules are out of scope. Typst's own
    // block-quote framing (padding, attribution) is dropped with the element.
    //
    // The nesting level rides along so a quote inside a list item lines up with
    // that item's text (see the emission below).
    show quote.where(block: true): q => context {
      let nest-level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      PAR_BUFFER.update(pars => {
        pars.push((
          content: q.body,
          nest-level: nest-level,
          kind: "quote",
        ))
        pars
      })
      none
    }
    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
      }

      // List and enum items become paragraphs carrying a nesting level. No
      // `context` wrapper: state updates do not need one, and one here fails
      // to converge on a body with many list items.
      show enum.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      show list.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }

      {
        // `show par` does not capture an element that fills its paragraph
        // whole, so a zero-width space follows each wrapper to keep some
        // content outside it.
        show strong: it => {
          [#it#sym.zws]
        }
        show emph: it => {
          [#it#sym.zws]
        }
        show underline: it => {
          [#it#sym.zws]
        }
        show raw: it => {
          [#it#sym.zws]
        }
        [#content#parbreak()]
      }
    }
  }
  // Use place() to prevent hidden content from affecting layout flow
  place(hide(first-pass))

  // Second pass: consume par buffer
  //
  // PAR_BUFFER item dictionary layout:
  //   item.content    — the paragraph body, table element, or block-quote body
  //   item.nest-level — nesting depth (−1 for tables)
  //   item.kind       — "par", "heading", "table", "continuation", or "quote"
  context {
    let heading-buffer = none
    let heading-level = 0
    // Zero-width paragraphs are dropped, so an empty body emits nothing and
    // collapses to zero vertical space. A table is kept whatever it measures.
    let items = PAR_BUFFER.get().filter(item =>
      item.kind == "table" or measure(item.content).width > 0pt
    )
    if items.len() == 0 { return }
    // Only top-level paragraphs count for AFH 33-337 §2 numbering purposes
    let par-count = items.filter(item => item.kind == "par").len()
    let total-count = items.len()

    // Numbers are tracked in a dictionary keyed by level index (as a string)
    // rather than in counters, whose updates do not propagate out of the
    // nested contexts this loop runs in.
    let max-levels = paragraph-config.numbering-formats.len()
    let level-counts = (:)
    for lvl in range(max-levels) {
      level-counts.insert(str(lvl), 1)
    }

    let i = 0
    let any-emitted = false
    for item in items {
      i += 1
      let kind = item.kind
      let item-content = item.content

      // A buffered heading runs into this element only when the two belong to
      // the same item: a later block of this list item ("continuation"), or,
      // at top level, the next paragraph. The first block of the *next* item,
      // a table (nest-level −1, so the level test alone excludes it), a block
      // quote (verbatim: a heading prepended to it would be ink the author did
      // not put inside the quote), and another heading all fail the test, and
      // each would otherwise carry the heading's text somewhere it was not
      // authored. Those emit the heading on its own line, the treatment a
      // heading before a table takes.
      if heading-buffer != none {
        let runs-in = (
          kind not in ("heading", "quote")
            and item.nest-level == heading-level
            and (heading-level == 0 or kind == "continuation")
        )
        if runs-in {
          item-content = [#strong[#heading-buffer.] #item-content]
        } else {
          if any-emitted { blank-line() }
          strong[#heading-buffer.]
          any-emitted = true
        }
        heading-buffer = none
      }

      // Buffer this heading for the next element to run into. The level it was
      // captured at rides along: the run-in test needs it, and the buffer is
      // read one iteration later, by which time `item` is the *next* element.
      if kind == "heading" {
        heading-buffer = item-content
        heading-level = item.nest-level
        continue
      }

      let nest-level = item.nest-level
      let indent-fn = if memo-style == "daf" {
        (level, _counts) => calculate-daf-indent(level)
      } else {
        (level, counts) => calculate-indent-from-counts(level, counts)
      }
      let final-par = {
        if kind == "table" {
          render-memo-table(item-content)
        } else if kind == "quote" {
          // A block quote is the body's unlabeled block: no number, no letter,
          // no bullet — the author's lines as written. It is placed, not
          // processed, which is what lets a memorandum carry a roster of names,
          // an address, or a quoted passage without AFH 33-337 numbering
          // claiming the first line of it.
          //
          // Two things are imposed, and both serve that reading.
          //
          // Where the block starts: at the offset where the text of the
          // paragraph it sits in starts, so a quote inside a subparagraph hangs
          // under that subparagraph's text instead of falling back to the left
          // margin. `pad` shifts the whole block, where a continuation takes a
          // first-line `h(..)`: a quote is kept for its line structure, and
          // lines that wrapped back to the margin would read as a block other
          // than the one authored. Top level offsets by 0pt — flush at the
          // margin, where an unnumbered line belongs.
          //
          // How its own paragraphs are spaced: `par.leading` and `par.spacing`
          // are both half an em in a memorandum, so a paragraph break inside
          // the quote would land on the page as an ordinary line break and read
          // as one block where the author wrote two. A blank line — what the
          // body puts between its own paragraphs — keeps that break visible.
          let quoted = {
            set par(spacing: spacing.line + line-stride())
            item-content
          }
          let offset = paragraph-text-offset(nest-level, level-counts, indent-fn)
          if offset == 0pt { quoted } else { pad(left: offset, quoted) }
        } else if kind == "continuation" {
          // Continuation block within a multi-block list item:
          // indent to align with preceding numbered paragraph's text, no new number.
          // level-counts still holds the value of the preceding numbered paragraph.
          if memo-style == "daf" and nest-level == 0 {
            item-content
          } else {
            format-par(item-content, nest-level, level-counts, indent-fn, continuation: true)
          }
        } else if memo-style == "daf" {
          if nest-level > 0 {
            let par = format-par(item-content, nest-level, level-counts, indent-fn)
            level-counts.insert(str(nest-level), level-counts.at(str(nest-level), default: 1) + 1)
            level-counts = reset-levels-from(level-counts, nest-level + 1, max-levels)
            par
          } else {
            // DAF top-level paragraphs are unnumbered and first-line indented.
            // Reset nested counters so each new top-level paragraph restarts children.
            level-counts = reset-levels-from(level-counts, 0, max-levels)
            [#h(daf-paragraph.top-first-line-indent)#item-content]
          }
        } else if par-count > 1 {
          let par = format-par(item-content, nest-level, level-counts, indent-fn)
          level-counts.insert(str(nest-level), level-counts.at(str(nest-level)) + 1)
          level-counts = reset-levels-from(level-counts, nest-level + 1, max-levels)
          par
        } else {
          // AFH 33-337 §2: "A single paragraph is not numbered"
          item-content
        }
      }

      // Blank line between paragraphs. The header→body gap (i.e. before
      // the first emitted paragraph) is the caller's responsibility —
      // emitting it here would put the v() inside a nested
      // `context { for … }` block, where it does not combine with the
      // preceding header section's block-spacing the same way as a
      // top-level blank-line() call.
      if any-emitted { blank-line() }
      any-emitted = true
      if i == total-count {
        // AFH 33-337 "Signature Block": "Do not place the signature element on a
        // continuation page by itself." The signature block that follows has no
        // keep-with-previous of its own — Typst has no such property — so the
        // anchor comes from this side: a sticky last element is carried onto the
        // next page along with the signature instead of breaking away from it.
        //
        // Bounded, because a sticky block does not *split* at a page boundary,
        // it relocates whole; applied to a half-page block that turns an
        // ordinary mid-paragraph break into a wholesale jump. A third of the
        // text block covers what a memorandum actually ends on — a closing
        // paragraph, a short table — while leaving the long block to be divided
        // by the break, which leaves its own tail on the continuation page for
        // the signature to sit under.
        //
        // The budget is a fixed fraction rather than the space actually left
        // below this element, which is the question one would rather ask. A
        // position-dependent test cannot be answered honestly here: on the first
        // layout pass `here()` resolves against an empty introspector and reports
        // the top of the page, so every element measures as fitting and
        // relocates — and from the top of its new page the same test agrees, so
        // the wrong answer is a fixed point that later passes never revisit.
        let available-width = page.width - spacing.margin * 2
        let relocation-budget = (page.height - spacing.margin * 2) / 3
        let element-height = measure(final-par, width: available-width).height
        block(sticky: element-height <= relocation-budget)[#final-par]
      } else {
        // A plain block, so that the document-wide `set block(above:
        // spacing.line)` contributes the same 0.5em above every paragraph as it
        // does above the last one. A bare emission skips `block.above` and
        // visibly compresses the gap.
        block[#final-par]
      }
    }

    // A heading with nothing after it never ran into anything, and the buffer
    // dies with the loop unless it is drained here. Sticky for the same reason
    // the last item is: a standalone heading is one line, so it keeps with the
    // signature block rather than opening a page alone.
    if heading-buffer != none {
      if any-emitted { blank-line() }
      block(sticky: true)[#strong[#heading-buffer.]]
    }
  }
}


