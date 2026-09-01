// The memorandum body: AFH 33-337 "The Text of the Official Memorandum" §1-12.

#import "body.typ": *

/// Show rule for the memorandum body, applying AFH 33-337 paragraph numbering
/// in the style the frontmatter recorded.
///
/// - it (content): Body content
/// -> content
#let mainmatter(it) = context {
  let config = query(<usaf-memo-config>).first().value
  let memo-style = config.at("memo-style", default: "usaf")
  render-body(it, memo-style: memo-style)
}
