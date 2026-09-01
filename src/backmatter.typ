// The memorandum's closing section: AFH 33-337 Chapter 14 "The Closing Section".

#import "primitives.typ": *

#let backmatter(
  signature-block: none,
  // "FOR THE COMMANDER", or the appropriate title, where the signer acted for
  // the commander, the command section, or the headquarters. Blank is no line.
  authority-line: none,
  signature-blank-lines: 4,
  signing-field: none,
  attachments: none,
  cc: none,
  distribution: none,
  leading-pagebreak: false,
) = {
  render-signature-block(
    signature-block,
    // Cased by the element, not by the slot: the letter's complimentary close
    // fills the same slot and must not be uppercased.
    closing-line: format-authority-line(authority-line),
    signature-blank-lines: signature-blank-lines,
    signing-field: signing-field,
  )
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-pagebreak: leading-pagebreak,
  )
}
