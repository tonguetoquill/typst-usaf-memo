# tonguetoquill: USAF Memo Template for Typst


[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/nibsbin/tonguetoquill-usaf-memo)
[![typst-universe](https://img.shields.io/badge/Typst-Universe-aqua)](https://github.com/nibsbin/tonguetoquill-usaf-memo)
[![nibs](https://img.shields.io/badge/author-Nibs-white?logo=github)](https://github.com/nibsbin)

> Less formatting. More lethality.

A comprehensive Typst template for creating official United States Air Force memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards. 

Maintained by [TTQ](https://www.tonguetoquill.com).

## Features

### Core Formatting
- **Full AFH 33-337 compliance** with "The Tongue and Quill" formatting standards
- **Automatic letterhead generation** with configurable organization title, caption, and seal
- **Pixel-perfect typesetting** for all memorandum components in AFH 33-337
- **Hierarchical paragraph numbering** (1., a., (1), (a)) with proper indentation
- **Comprehensive backmatter** (Attachments, CC, Distribution) with smart formatting
- **Page numbering** starting from page 2 per AFH 33-337 standards
- **Highly Configurable** with numerous parameters for customization
- **Comprehensive Indorsements** with full support for action lines, multiple indorsement types, and long indorsement chains
- **Classification markings** with color-coded header/footer banners for UNCLASSIFIED, CUI, CONFIDENTIAL, SECRET, and TOP SECRET (other banner text uses the default color), optional dissemination controls, and the DoDM 5200.48 CUI designation indicator block
- **Custom footer taglines** for service-specific branding (e.g., "semper supra" for Space Force)
- **Inline tables** with clean, formal formatting consistent with USAF correspondence standards
- **Block quotes** for the lines that take no number, letter, or bullet — a roster of names, an address, a quoted passage
- **Authority lines** ("FOR THE COMMANDER") above the signature block of the memorandum and of any indorsement

## Quick Start

### Typst.app (Easiest)

1. Go to [the package page](https://typst.app/universe/package/tonguetoquill-usaf-memo) and click "Create project in app".

2. Download the project fonts and upload them to your project folder. Recommended fonts from the `fonts/` directory are:

- `NimbusRomNo9L-Reg.otf`, `NimbusRomNo9L-RegIta.otf`, `NimbusRomNo9L-Med.otf`, `NimbusRomNo9L-MedIta.otf` — letterhead and body text (open-source Times New Roman–compatible serif)
- `Cinzel-Regular.ttf` — optional decorative font for footer taglines

You can either clone the repository to pull all fonts or download just the files you need. All font files are available from the `fonts/` directory in the repo: https://github.com/nibsbin/tonguetoquill-usaf-memo/tree/main/fonts

  - **Note:** *Times New Roman* is a proprietary Microsoft font that I can't distribute legally. After you add the *NimbusRomNo9L* files (see above), the templates use them to approximate Times.

3. Start with one of the template files:
   - `template/usaf-template.typ` for a standard Air Force memo
   - `template/ussf-template.typ` for Space Force
   - `template/starkindustries.typ` for a custom organization example

### Local Installation

1. [Install Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) 0.15.1 or newer.

2. Initialize template from Typst Universe:
```bash
typst init @preview/tonguetoquill-usaf-memo:5.0.0 my-memo
cd my-memo
```

3. Download the required fonts:
```bash
# Download the fonts used by the templates (example). Copy these into your project root or `fonts/` directory.
curl -L -o Cinzel-Regular.ttf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/Cinzel/Cinzel-Regular.ttf
curl -L -o CopperplateCC-Bold.otf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/CopperplateCC/CopperplateCC-Bold.otf
curl -L -o CopperplateCC-Heavy.otf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/CopperplateCC/CopperplateCC-Heavy.otf
curl -L -o LiberationMono-Regular.ttf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/LiberationMono/LiberationMono-Regular.ttf
curl -L -o NimbusRomNo9L-Reg.otf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/NimbusRomanNo9L/NimbusRomNo9L-Reg.otf
curl -L -o NimbusRomNo9L-RegIta.otf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/NimbusRomanNo9L/NimbusRomNo9L-RegIta.otf
curl -L -o NimbusRomNo9L-Med.otf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/NimbusRomanNo9L/NimbusRomNo9L-Med.otf
curl -L -o NimbusRomNo9L-MedIta.otf https://github.com/nibsbin/tonguetoquill-usaf-memo/raw/main/fonts/NimbusRomanNo9L/NimbusRomNo9L-MedIta.otf
```

4. Compile a template file (include `--font-path` if fonts are in a `fonts/` subfolder):
```bash
# If your fonts are located in a local `fonts/` folder, specify it:
typst compile --font-path fonts --font-path . template/usaf-template.typ my-memo.pdf
```

### Local Development

Clone [the repo](https://github.com/nibsbin/tonguetoquill-usaf-memo) and follow [these instructions](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages) to install the package locally for development.

```bash
git clone https://github.com/nibsbin/tonguetoquill-usaf-memo.git
cd tonguetoquill-usaf-memo
./build.sh  # Compile all template examples
```

### Basic Usage

Import the core functions for creating memorandums:

```typst
#import "@preview/tonguetoquill-usaf-memo:5.0.0": frontmatter, mainmatter, backmatter, indorsement
```

**Minimal Example:**
```typst
#show: frontmatter.with(
  subject: "Your Subject Here",
  memo-for: ("OFFICE/SYMBOL",),
  memo-from: ("YOUR/SYMBOL",),
)

#mainmatter[
  Your memorandum content goes here.

  - Use plus signs for numbered subparagraphs.
    - Indent with spaces for deeper nesting.

  Continue with regular paragraphs.
]

#backmatter(
  signature-block: ("NAME, Rank, USAF", "Title"),
)
```

See the [API Reference](#api-reference) section below for complete parameter documentation.

### Complete Examples

For comprehensive examples with all parameters, see:
- **Standard Air Force memo**: `template/usaf-template.typ` - Shows proper formatting with references, attachments, cc, distribution, and indorsements
- **Space Force memo**: `template/ussf-template.typ` - Space Force memorandum variant with proper formatting
- **Custom organization memo**: `template/starkindustries.typ` - Demonstrates custom letterhead and extensive use of all optional parameters

## Additional usage details

### Paragraph numbering

AFH 33-337–compliant hierarchical numbering using Typst's native enum lists.

```typst
Base paragraph numbered as 1., 2., etc.

- Level 1 subparagraph lettered as a., b., etc.
  - Level 2 subparagraph numbered as (1), (2), etc.
    - Level 3 subparagraph lettered as (a), (b), etc.

This returns to base paragraph numbering as 2.
```

### Sentence spacing

The project includes GitHub Copilot prompts in `.github/prompts/` to help with sentence spacing formatting:

- **double-space-sentence.prompt.md**: Converts single spaces after sentences to double spaces (`~ `) within memo content
- **single-space-sentence.prompt.md**: Converts double spaces back to single spaces within memo content

These prompts help ensure consistent spacing formatting in your memorandums according to your organization's preferred style.

### Smart page break handling

The template automatically manages page breaks for closing sections according to AFH 33-337 standards:

- **Attachments**: "Do not divide attachment listings between two pages"
- **Distribution**: "Do not divide distribution lists between two pages"
- **CC sections**: Consistent handling with other sections

### Inline tables

Tables can be placed directly in the memo body using standard Typst `#table(...)` syntax. The template automatically applies clean, formal formatting — 0.5pt black cell borders, standard padding, and bold column headers — consistent with the plain style of official USAF correspondence.

```typst
#table(
  columns: (1fr, 1fr, 1fr),
  table.header([Element], [Placement], [Reference]),
  [Date], [1.75 in from top, 1 in from right], [AFH 33-337 §Date],
  [Signature Block], [5th line below body text], [AFH 33-337 §Sig],
)
```

Tables do not count toward paragraph numbering and are rendered between numbered paragraphs as needed.

### Block quotes

AFH 33-337 numbers paragraphs and letters subparagraphs, and a body sometimes has to hold lines that are neither: a roster of names, a mailing address, a quoted passage. A block quote is where you say so — its content reaches the page as written, taking no number, letter, or bullet.

```typst
#quote(block: true)[
  FIRST M. LAST, Maj, USAF\
  SECOND N. LAST, Capt, USAF
]
```

A quote inside a subparagraph hangs under that subparagraph's text; one at top level sits flush at the left margin. Typst's own block-quote framing (padding, attribution) is not applied.

### Classification markings

Set `classification-level` in `frontmatter` to display color-coded banners in the page header and footer:

```typst
#show: frontmatter.with(
  // ...
  classification-level: "SECRET",
)
```

Banner color applies when the marking string (after trimming) begins with `"UNCLASSIFIED"` (green), `"SECRET"` (red), `"TOP SECRET"` (orange), `"CONFIDENTIAL"` (black), or `"CUI"` (black). Any other text still appears in bold in the header and footer but uses the default text color (black). Placement is top and bottom center of every page.

Set `dissemination` alongside it to append a dissemination control to the banner, rendered as `LEVEL//DISSEMINATION`:

```typst
#show: frontmatter.with(
  // ...
  classification-level: "CUI",
  dissemination: "SP-CTRL",        // banner reads "CUI//SP-CTRL"
  cui-controlled-by: "123 ES/CC",  // designation indicator block, page 1 bottom right
  cui-category: "PRVCY",
  cui-limited-dissemination: "FEDCON",
  cui-poc: "Jane Doe, 555-0100",
)
```

The CUI designation indicator block (DoDM 5200.48, Table 1) is rendered in the bottom-right corner of page 1 whenever `classification-level` begins with `"CUI"` and at least one `cui-*` field is set.

## API Reference

The template uses a **composable show rules architecture** where you apply each section in order: frontmatter → mainmatter → backmatter → indorsements.

### Core Functions

#### `frontmatter(...)`

Configures the memorandum header and establishes document-wide settings. Applied as a show rule.

**Required Parameters:**
- `subject`: Memorandum subject line (must be descriptive and in title case)
- `memo-for`: Recipients (string or array of office symbols)

`memo-from` is optional — omit it for a Memorandum for Record, which has no FROM element.

**Key Parameters:**
```typst
#show: frontmatter.with(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",           // Organization title
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",           // Sub-organization
  letterhead-seal: none,                                     // Organization seal image (left corner)
  letterhead-seal-subtitle: none,                            // Optional line under seal (9pt bold caps)
  letterhead-emblem: none,                                   // Optional image opposite the seal (right corner)
  letterhead-emblem-height: 1in,                             // Emblem fit-box height; reduce for shorter emblems
  date: none,                                                // Date (defaults to today; also accepts ISO string "YYYY-MM-DD")
  memo-for: ("[OFFICE1]", "[OFFICE2]"),                     // Recipients array (rendered in uppercase)
  memo-from: ("[YOUR/SYMBOL]", "[Organization]", "[Address]"), // Sender info array (omit for a Memorandum for Record)
  subject: "[Your Subject in Title Case - Required]",        // Subject line
  references: ("AFI 123-45", "AFMAN 67-89"),                // Optional references

  // Styling options
  letterhead-font: ("Copperplate CC", "NimbusRomNo9L"),     // Letterhead fonts
  body-font: ("NimbusRomNo9L",),                            // Body fonts
  font-size: 12pt,                                          // Font size (default 12pt; 10pt minimum per AFH 33-337 §5)
  memo-for-cols: 3,                                         // Recipient columns

  // Classification and branding
  classification-level: none,                               // e.g. "UNCLASSIFIED", "CUI", "CONFIDENTIAL", "SECRET", or "TOP SECRET"
  dissemination: none,                                      // Appended to the banner as "LEVEL//DISSEMINATION" (e.g. "SP-CTRL")
  footer-tag-line: none,                                    // Custom footer tagline (e.g., "semper supra")

  // CUI designation indicator block (DoDM 5200.48, Table 1) — page 1, bottom right.
  // Rendered only when classification-level starts with "CUI" and at least one field is set.
  cui-controlled-by: none,                                  // Controlling office
  cui-category: none,                                       // CUI category (e.g. "PRVCY")
  cui-limited-dissemination: none,                          // Limited dissemination control (e.g. "FEDCON")
  cui-poc: none,                                            // Point of contact

  memo-style: "usaf",                                       // "usaf" (default) or "daf"
)
```

**References placement.** A single reference is rendered inline in parentheses after the SUBJECT text; two or more are rendered as a lettered `References:` block per AFH 33-337. Blank entries are dropped before that decision, so a stub left for the user to fill in neither renders on its own nor passes as the lone reference.

**Responsibilities:**
- Sets page layout with 1-inch margins
- Renders letterhead with optional seal, optional `letterhead-seal-subtitle` under the seal, and optional `letterhead-emblem` in the opposite corner
- Renders date, MEMORANDUM FOR, FROM, SUBJECT, and references sections
- Establishes typography and spacing rules, including a monospace face for raw/code text
- Renders color-coded classification banners in header and footer when `classification-level` is set
- Renders the CUI designation indicator block when CUI indicator fields are set
- Renders custom footer tagline when `footer-tag-line` is set
- Stores configuration for downstream sections

#### `mainmatter`

Processes the memorandum body content with automatic paragraph numbering. Called with the body as content, or applied as a show rule.

```typst
#mainmatter[
  Your memorandum content goes here.
]
```

```typst
#show: mainmatter

Your memorandum content goes here.
```

As a show rule it takes the entire remainder of the document, `backmatter` and `indorsement` included; those are split back out and rendered as the closing sections they are, not numbered as body text.

**Responsibilities:**
- Applies AFH 33-337 hierarchical paragraph numbering (1., a., (1), (a))
- Handles proper indentation and spacing
- Auto-detects single vs. multiple paragraphs
- Supports inline tables with formal black-border formatting
- Places block quotes verbatim, without a paragraph number
- Inherits configuration from frontmatter

#### `backmatter(...)`

Renders the closing section including signature block and optional attachments/cc/distribution. Called as a function (not a show rule).

**Key Parameters:**
```typst
#backmatter(
  signature-block: ("[NAME, Rank, USAF]", "[Title]"),      // Signature lines (required)
  authority-line: none,                                    // e.g. "FOR THE COMMANDER"; rendered in uppercase above the signature block
  signature-blank-lines: 4,                                // Blank lines above signature
  signing-field: none,                                     // Optional content overlaid in the space above the signature block
  attachments: ("Attachment 1", "Attachment 2"),            // Optional attachments (a single attachment is not numbered)
  cc: ("[OFFICE/SYMBOL]",),                                // Courtesy copies
  distribution: ("[OFFICE]",),                             // Distribution list
  leading-pagebreak: false,                                // Force page break before backmatter
)
```

**The `authority-line` parameter.** AFH 33-337 places the authority line on the second line below the text, at the signature block's own anchor, with the signature then five lines below the line rather than below the body. Leave it unset — the usual case — when the commander signs, when the memorandum gives the opinion of a unit or office, or when it goes outside the DoD.

**Responsibilities:**
- Renders the authority line when one is set
- Renders signature block with orphan prevention, shifting it left when a long name would otherwise overrun the right margin
- Renders attachments section with smart page breaks
- Renders cc section
- Renders distribution list

#### `indorsement(...)`

Creates an indorsement for forwarding or commenting on a memorandum. Called as a function with content body.

```typst
#indorsement(
  from: "ORG/SYMBOL",                                       // Sending organization
  to: "RECIPIENT/SYMBOL",                                   // Recipient organization
  signature-block: ("[NAME, Rank, USAF]", "[Title]"),      // Signature lines
  authority-line: none,                                    // e.g. "FOR THE COMMANDER"; as on backmatter
  signature-blank-lines: 4,                                // Blank lines above signature
  signing-field: none,                                     // Optional content overlaid in the space above the signature block
  date: none,                                              // Indorsement date; blank rules the date slot (also accepts ISO string "YYYY-MM-DD")
  date-field: none,                                        // Optional fill-in widget anchored in that slot instead of the rule
  format: "standard",                                      // "standard", "informal", or "separate_page"
  action: none,                                            // none (default), "undecided", "approve", or "disapprove"
  approval-authority: false,                               // true for the last indorsement in the chain
)[
  Your indorsement content here.
]
```

**The `date` parameter.** Per AFH 33-337 Ch. 14 an indorsement is dated when the endorser signs it, which is usually unknown at compile time. Leaving `date` unset therefore rules the date slot to be completed by hand rather than stamping today's date. Pass `date-field` to anchor an interactive widget — a PDF form field, say — in that slot instead.

**Empty bodies.** An indorsement with an action line but no body text (`[]`) collapses the body's surrounding spacing, so the signature block still lands on AFH 33-337's "fifth line below the last line of text" anchor.

**The `action` parameter:**
- `none` (default): No action line displayed
- `"undecided"`: Displays the option pair with neither option marked
- `"approve"`: Underlines the affirmative option and strikes the other
- `"disapprove"`: Underlines the negative option and strikes the other

**The `approval-authority` parameter.** Which pair prints follows from the indorsement's place in the coordination chain, not from the endorser's choice. The last indorsement is the approval authority and reads Approve / Disapprove (`approval-authority: true`); every coordinating official before it reads Concur / Nonconcur (the default). Only the caller can see whether further indorsements follow, so the caller sets it.

**Responsibilities:**
- Auto-numbers indorsements (1st Ind, 2d Ind, 3d Ind, etc.)
- Renders the authority line when one is set
- Renders indorsement header with from/to
- Upgrades a `"standard"` indorsement to the fuller separate-page header when it no longer fits on the action document's page and is pushed to a new page
- Processes indorsement body content
- Renders signature block
- References original memo metadata

## Development

### Contributing

Contributions are welcome! Please explore `src/` for core functions and `template/` for the user-facing examples. Feel free to open issues or submit pull requests.

### Project Structure

```text
├── src/                     # Core implementation
│   ├── lib.typ              # Public API exports
│   ├── config.typ           # Configuration constants (single source of truth)
│   ├── frontmatter.typ      # Header section show rule
│   ├── mainmatter.typ       # Body content show rule
│   ├── backmatter.typ       # Closing section rendering
│   ├── indorsement.typ      # Indorsement rendering
│   ├── primitives.typ       # Reusable rendering functions
│   └── utils.typ            # Utility functions and helpers
├── template/                # Example templates
│   ├── usaf-template.typ    # Standard Air Force memo
│   ├── ussf-template.typ    # Space Force variant
│   ├── starkindustries.typ  # Custom organization example
│   └── assets/              # Images (seals, etc.); font files live in `fonts/`)
├── prose/                   # Design documentation
│   ├── designs/             # Active design documents
│   ├── plans/               # Implementation plans
│   └── archive/             # Archived designs and analyses
├── pdfs/                    # Compiled example outputs
├── thumbnail.png            # Typst Universe package thumbnail (outside template/)
└── README.md                # This documentation
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

External assets used in this project:

- `dow_seal.png` is [public domain](https://www.e-publishing.af.mil/Portals/1/Documents/Official%20Memorandum%20Template_10Nov2020.dotx?ver=M7cny_cp1_QDajkyg0xWBw%3D%3D)
- `starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).
- `NimbusRomNo9L` is under the [GNU GPL, version 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html); a copy is also in `fonts/NimbusRomanNo9L/GNU General Public License.txt`. Fonts are from the URW++ foundry.