// The show-rule form with the closing sections emitted from a code block
// rather than written as markup children. `split-closing` reads direct
// children, so this is the shape that says whether a caller building the
// closing in a loop still lands on the right side of the split.

#import "/src/lib.typ": backmatter, frontmatter, indorsement, mainmatter

#show: frontmatter.with(
  subject: "Closing Sections",
  memo-for: "TEST/CC",
  memo-from: "TEST/DO",
  date: datetime(year: 2026, month: 3, day: 11),
)

#show: mainmatter

Alpha top paragraph.

Bravo closing paragraph.

#{
  backmatter(
    authority-line: "FOR THE COMMANDER",
    signature-block: ("FIRST M. LAST, Maj, USAF", "Duty Title"),
    attachments: ("Lone attachment",),
  )
  for endorser in (("SECOND N. LAST, Capt, USAF", "Duty Title"),) {
    indorsement(
      from: "TEST/DO",
      to: "TEST/CC",
      action: "approve",
      approval-authority: true,
      signature-block: endorser,
    )[
      Indorsement body paragraph.
    ]
  }
}
