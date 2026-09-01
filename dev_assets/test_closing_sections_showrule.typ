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

#backmatter(
  authority-line: "FOR THE COMMANDER",
  signature-block: ("FIRST M. LAST, Maj, USAF", "Duty Title"),
  attachments: ("Lone attachment",),
)

#indorsement(
  from: "TEST/DO",
  to: "TEST/CC",
  action: "approve",
  approval-authority: true,
  signature-block: ("SECOND N. LAST, Capt, USAF", "Duty Title"),
)[
  Indorsement body paragraph.
]
