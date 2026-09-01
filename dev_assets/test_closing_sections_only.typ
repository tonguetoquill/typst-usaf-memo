// A memorandum whose body is empty, so the closing section is the whole of what
// `mainmatter` receives rather than one child among several. The file ends
// without a trailing newline, which is what leaves no sequence around it.

#import "/src/lib.typ": backmatter, frontmatter, mainmatter

#show: frontmatter.with(
  subject: "Closing Only",
  memo-for: "TEST/CC",
  memo-from: "TEST/DO",
  date: datetime(year: 2026, month: 3, day: 11),
)

#show: mainmatter
#backmatter(signature-block: ("FIRST M. LAST, Maj, USAF", "Duty Title"))