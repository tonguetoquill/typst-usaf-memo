# Changelog

All notable changes to `tonguetoquill-usaf-memo` are documented here.

---

## [4.0.0] — 2026-07-30

Synchronises the package with the downstream fork maintained in
[`tonguetoquill/airmark-quiver`](https://github.com/tonguetoquill/airmark-quiver),
which carried roughly two months of fixes that had not been merged back. All
public parameters keep this project's `kebab-case` convention; the fork's
`snake_case` spellings were translated on the way in.

### Added

- **`letterhead-emblem` and `letterhead-emblem-height`.** Optional image placed in the corner opposite the seal. The seal and emblem share one reference band, so both bleed the same 0.5 in past the margin and centre on the same axis regardless of the emblem's height.
- **CUI designation indicator block** (DoDM 5200.48, Table 1) via `cui-controlled-by`, `cui-category`, `cui-limited-dissemination`, and `cui-poc`. Rendered in the bottom-right corner of page 1 when `classification-level` starts with `"CUI"` and at least one field is set. Emitted as a bottom float so it reserves flow space (body text can never overlap it) and stays pinned to page 1.
- **`dissemination` frontmatter parameter.** Appends a dissemination control to the classification banner as `LEVEL//DISSEMINATION`.
- **`CONFIDENTIAL` and `CUI` classification colors** (both black, per DoD/CAPCO marking guidance).
- **Monospace face for raw text.** Liberation Mono (metric-compatible with Courier New) is bundled and applied to inline code and code blocks via `DEFAULT_MONO_FONTS`.
- **`signing-field` on `backmatter` and `indorsement`.** Optional content overlaid in the blank space above the signature block, for form-fillable signature widgets.
- **`date-placeholder-line` utility.** Horizontal fill-in rule sized for a handwritten date.
- **Automatic separate-page indorsement headers.** A `"standard"` indorsement pushed onto a new page now carries the fuller separate-page identifying header instead of the terse same-page form, per AFH 33-337. Indorsement headers are non-breakable and sticky, so they never split across a page boundary or detach from the content they head.
- **Long-name signature blocks.** When the widest signature line would overrun the right margin at the standard 4.5 in anchor, the block shifts left just enough to fit, per the AFH 33-337 "signature block adjusted to the left" example.

### Changed

- **Breaking: all public parameters renamed from `snake_case` to `kebab-case`** for consistency with Typst idiom. Update call sites as follows:
  - `frontmatter`: `memo_for` → `memo-for`, `memo_from` → `memo-from`, `letterhead_title` → `letterhead-title`, `letterhead_caption` → `letterhead-caption`, `letterhead_seal` → `letterhead-seal`, `letterhead_seal_subtitle` → `letterhead-seal-subtitle`, `letterhead_font` → `letterhead-font`, `body_font` → `body-font`, `font_size` → `font-size`, `memo_for_cols` → `memo-for-cols`, `classification_level` → `classification-level`, `footer_tag_line` → `footer-tag-line`, `memo_style` → `memo-style`.
  - `backmatter`: `signature_block` → `signature-block`, `signature_blank_lines` → `signature-blank-lines`, `leading_pagebreak` → `leading-pagebreak`.
  - `indorsement`: `signature_block` → `signature-block`, `signature_blank_lines` → `signature-blank-lines`.
- **Breaking: `memo-from` is now optional.** Omitting it suppresses the FROM element entirely, for a Memorandum for Record. It is no longer asserted as required.
- **Breaking: `indorsement` no longer dates itself.** `date` defaults to `none`, which renders a fill-in rule rather than stamping the compile date — an indorsement is dated when the endorser signs it, which is generally not known at compile time. Pass `date` explicitly to restore a printed date.
- **Breaking: a single reference is rendered inline** in parentheses after the SUBJECT text; the lettered `References:` block is used only for two or more, per AFH 33-337's single-reference rule.
- **Breaking: a single attachment is not numbered.** Numbering applies only to two or more attachments.
- **Default letterhead font is now `("Copperplate CC", "NimbusRomNo9L")`** and the default body font `("NimbusRomNo9L",)`; `"times new roman"` is no longer listed, as NimbusRomNo9L is a metric-compatible clone. `CopperplateCC-Bold.otf` is bundled alongside the existing Heavy weight.
- **Letterhead color darkened** from `#204093` to `#355e93`.
- **MEMORANDUM FOR recipients are uppercased** on render.
- **Blank-line spacing is measured from a single cached line stride.** The legacy `spacing.vertical` / `spacing.line-height` constants and the `BLANK_LINE_STEP` state are gone, along with `blank-lines`' `weak` parameter — AFH 33-337 counts blank lines as structural elements, so they no longer collapse against adjacent block spacing.
- **Body paragraphs are wrapped in blocks** so the document-wide `block.above` rule contributes an identical gap above every paragraph, instead of the first and middle paragraphs rendering tighter than the last.
- **Empty bodies collapse to zero layout.** Zero-width paragraphs are filtered before rendering, and an indorsement with an empty body suppresses the header→body and action→body gaps, so the signature block still lands on the "fifth line below the last line of text" anchor.
- **Frontmatter metadata is published under a `<usaf-memo-config>` label** and read with `query(<usaf-memo-config>).first()` rather than `query(metadata).last()`, so unrelated `metadata()` in user content cannot shadow it.
- **The signature-block hanging indent is now 0.5 em** (roughly two characters) rather than 2 em, per AFH 33-337's "begin under the third character of the line above".

### Fixed

- **Backmatter sections no longer destabilise layout.** `render-backmatter-section` decided whether a section fit by reading `here().position().y` and then emitting an explicit `pagebreak()`, feeding its own layout query back into its input. With the spacing changes above this could oscillate until Typst gave up ("layout did not converge within 5 attempts"), leaving page numbers off by one in the compiled output. The section is now emitted as a non-breakable block, so Typst's own breaker moves it as a unit and the continuation label is the only thing the query drives.

### Removed

- **Breaking: `auto-numbering` frontmatter parameter.** Paragraph numbering now follows AFH 33-337 unconditionally: a single paragraph is unnumbered, two or more are numbered. `render-body` no longer accepts `auto-numbering` either.
- **Breaking: `attachments` and `cc` parameters on `indorsement`.** Attachment and courtesy-copy listings belong to the originating memorandum's backmatter.
- **Breaking: `action: "none"` as a string.** Only `none`, `"undecided"`, `"approve"`, and `"disapprove"` are accepted; `render-action-line` asserts accordingly.

---

## [2.0.0] — 2026-03-11

### Added

- **Indorsement approval/disapproval action line.** New `action` parameter on `indorsement()` renders a formal "Approve / Disapprove" line matching the paper convention where the chosen option is circled.
  - `none` (default) — no action line rendered
  - `"undecided"` — both options shown, neither boxed nor struck through
  - `"approve"` — Approve boxed, Disapprove struck through
  - `"disapprove"` — Disapprove boxed, Approve struck through
- **Inline table formatting.** Tables placed inside `#mainmatter[...]` with `#table(...)` are automatically styled with 0.5 pt black cell borders, standard inset, and bold column headers, consistent with the plain formal aesthetic of USAF correspondence. Tables do not count toward AFH 33-337 §2 paragraph numbering.
- **`auto_numbering` frontmatter parameter.** Set `auto_numbering: false` to suppress base-level paragraph numbering. Explicitly bulleted or enumerated sub-items still receive hierarchical numbering with their level shifted by one.
- **Orphan/widow control for final paragraphs.** The last body paragraph before the signature block is measured; short content (fewer than four lines) is made sticky to prevent it from being orphaned on a preceding page.
- **Action line sticky to signature block.** The action line in indorsements is now kept on the same page as the body content and signature block, preventing it from appearing alone on a trailing page.

### Changed

- **`action` parameter default changed from `"none"` (string) to `none` (Typst keyword).** Callers that passed `action: "none"` explicitly should remove the parameter or pass `action: none`.
- **Paragraph body rendering refactored to a two-pass system.** The first pass collects all paragraphs, list items, headings, and tables into a `PAR_BUFFER` state; the second pass renders them with proper numbering, indentation, and orphan control. This eliminates nested-context counter propagation bugs and makes multi-block list items reliable.
- **Multi-block list items.** Subsequent paragraphs within the same list or enum item are now rendered as continuation blocks — indented to align with the item text but without a new number — rather than being treated as new numbered items.
- **Child counter reset on base-level paragraph.** When `auto_numbering: false` and a base-level paragraph is encountered, all child-level counters are reset so the next sub-item list restarts at `a.` / `(1)` as expected.
- **Heading rendering.** Headings inside `mainmatter` are prepended as inline bold text to the following paragraph rather than rendered as standalone block elements, matching AFH 33-337 style.
- **`mainmatter` changed from show rule with body parameter to a content-block function.** Usage is now `#mainmatter[...]` instead of `#show: mainmatter` followed by bare content. The show-rule form `#show: mainmatter` remains supported for backward compatibility.
- **`auto_numbering` renamed from `number_all_paragraphs`** for cleaner developer experience. The old name is no longer supported.

### Fixed

- Fixed paragraph collection for content wrapped in `strong`, `emph`, `underline`, and `raw` show rules — these no longer swallow paragraphs silently.
- Fixed vertical alignment of the boxed action text in approve/disapprove lines.
- Fixed numbering counter propagation when deeply nested items are followed by shallower items.
- Fixed body spacing bleeding into letterhead vertical spacing.
- Fixed `separate_page` indorsement format (previously `separate-page`).

---

## [1.0.0] — 2025-11-22

Initial stable release.

### Features at 1.0.0

- Composable show-rule architecture: `frontmatter` → `mainmatter` → `backmatter` → `indorsement`
- AFH 33-337 §2 hierarchical paragraph numbering (1., a., (1), (a))
- Automatic letterhead with configurable title, caption, and seal image
- Date, MEMORANDUM FOR, FROM, SUBJECT, and References sections
- Classification-level header/footer banners with DoD standard colors
- Custom footer tagline support (e.g., "semper supra" for Space Force)
- Backmatter: signature block (4.5 in from left, orphan prevention), attachments, cc, distribution with smart page-break continuation labels
- Indorsements: auto-numbered (1st Ind, 2d Ind, …), standard, informal, and separate-page formats
- ISO date string support (`"YYYY-MM-DD"`) for `date` parameters
- `font_size` parameter for font-size control per AFH 33-337 §5 (10 pt minimum)
- Font fallback so NimbusRomNo9L approximates Times New Roman on systems without the proprietary font
