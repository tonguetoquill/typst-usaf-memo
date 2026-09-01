// The memorandum body: AFH 33-337 "The Text of the Official Memorandum" §1-12.

#import "body.typ": *

/// Splits content at the first closing section: the part `render-body` numbers,
/// and the part that reaches the page untouched.
///
/// `render-body` rebuilds what it is given from a buffer of paragraphs, tables,
/// and block quotes. A closing section through it loses the placement it is
/// made of, and its surviving lines take body paragraph numbers. Applied as a
/// show rule, `mainmatter` is handed those sections along with the body;
/// `backmatter` and `indorsement` label their output to mark the boundary.
///
/// Everything from the first marker on stays together, prose a caller wrote
/// between two closing sections included.
///
/// A marker is found on `it` itself, on a direct child, or inside the `styled`
/// element that a `set` or `show` rule after `#show: mainmatter` wraps the
/// remainder in; both halves come back under those styles. A marker a caller
/// nested in a container of their own — a `block`, a `grid` cell — is not
/// found. A closing section built in a code block or a loop is not nested:
/// joining content extends the sequence on the left in place, so its marker
/// stays a direct child.
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
