// The memorandum body: AFH 33-337 "The Text of the Official Memorandum" §1-12.

#import "body.typ": *

/// Splits content at the first closing section, into the part `render-body`
/// numbers and the part that reaches the page untouched.
///
/// Applied as a show rule, `mainmatter` is handed the whole remainder of the
/// document — the closing sections along with the body. They cannot go through
/// `render-body`: it rebuilds what it is given from a buffer of paragraphs,
/// tables, and block quotes, so the placement a signature block is made of is
/// dropped and the lines that survive are numbered as body text. Hence the
/// split, ahead of the rebuild rather than inside it; `backmatter` and
/// `indorsement` label their output to mark where it falls.
///
/// Everything from that first marker on stays together, including any prose a
/// caller wrote between two closing sections: past the signature block, a
/// memorandum's body is over.
///
/// Three shapes carry a marker, and the split reads all three: `it` itself,
/// where a closing section is all there is; a direct child; and the `child` of
/// a `styled` element, which is what a `set` or `show` rule written after
/// `#show: mainmatter` wraps the remainder of the document in. Both halves are
/// put back under those styles, since the rule was written to cover both.
///
/// What it does not read is a marker a caller nested inside a container of
/// their own — a `block`, a `grid` cell. A closing section built in a code
/// block or a loop is not such a case: joining content extends the sequence on
/// the left in place, so the marker stays a direct child.
///
/// - it (content): Content handed to `mainmatter`
/// -> array: the body content and the closing content
#let split-closing(it) = {
  if it.at("label", default: none) == <usaf-memo-closing> { return ([], it) }
  // `styled` is not a name in scope; its two fields identify it.
  if it.has("child") and it.has("styles") {
    let (body, closing) = split-closing(it.child)
    let restyle = part => (it.func())(part, it.styles)
    return (restyle(body), restyle(closing))
  }
  if not it.has("children") { return (it, []) }
  let children = it.children
  let boundary = children.position(child => child.at("label", default: none) == <usaf-memo-closing>)
  if boundary == none { return (it, []) }
  // `sum` over `join`: an empty half is `none` from a join and `[]` from this.
  (children.slice(0, boundary).sum(default: []), children.slice(boundary).sum(default: []))
}

/// Show rule for the memorandum body, applying AFH 33-337 paragraph numbering
/// in the style the frontmatter recorded.
///
/// - it (content): Body content
/// -> content
#let mainmatter(it) = {
  let (body, closing) = split-closing(it)
  context {
    let config = query(<usaf-memo-config>).first().value
    render-body(body, memo-style: config.at("memo-style", default: "usaf"))
  }
  closing
}
