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
/// - it (content): Content handed to `mainmatter`
/// -> array: the body content and the closing content
#let split-closing(it) = {
  if not it.has("children") { return (it, []) }
  let children = it.children
  let boundary = children.position(child => child.at("label", default: none) == <usaf-memo-closing>)
  if boundary == none { return (it, []) }
  // `().join()` and a one-element join both need coercing back to content.
  let rejoin = parts => {
    let joined = parts.join()
    if joined == none { [] } else { joined }
  }
  (rejoin(children.slice(0, boundary)), rejoin(children.slice(boundary)))
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
