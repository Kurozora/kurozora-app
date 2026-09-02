# What's New — In-App vs App Store

Kurozora has **two separate "What's New" surfaces**. They are authored and stored
independently; updating one does **not** update the other. Every release needs both.

| Surface              | Where                                              | Audience                   | Style                           |
|----------------------|----------------------------------------------------|----------------------------|---------------------------------|
| In-app What's New    | `KWhatsNew.swift` (the `WhatsNew` popup on update) | Existing users who updated | Curated **highlights**, playful |
| App Store What's New | App Store Connect, per version/platform/locale     | Anyone on the product page | **Comprehensive** changelog     |

---

## In-app What's New

- **File:** `Kurozora/App/Models/KWhatsNew.swift`
- Each release is a `static var vX_Y_Z: [WhatsNewItem]` array. The `current` getter
  returns the array for the shipping version — **point it at the new array each release**.
- Entries are `.image(title:subtitle:image:)`. Images come from the `.Icons.*` namespace
  (asset catalog: `Kurozora/Supporting Files/Assets.xcassets/Icons/`). Reuse a symbol that
  already appears in the file to guarantee it compiles.
- **Voice & format:**
  - Short punchy title, then a one or two sentence benefit-focused subtitle.
  - App icon and theme proper nouns go in corner brackets: `『Name』`.
  - The **lead** entry is the seasonal app icon / theme reveal, using `.Icons.gift`.
  - The **closer** is always a "Bug Fixes" entry, using `.Icons.ladybug`.
- This is a **curated list of ~10–14 highlights**, not an exhaustive changelog.

---

## App Store What's New (release notes)

- Stored in **App Store Connect**, and split three ways:
  - **Per platform** — iOS and macOS are *separate* version records with separate notes.
  - **Per locale** — one `whatsNew` field per localization on the version.
- Managed with the `asc` CLI (profile `kurozora-admin`, app ID `1476153872`).
- **Hard limit: 4000 characters per locale.** Always `wc -m` before pushing.
- This list is **comprehensive, not highlights-only.** Build it from the commit log since
  the last release tag (`git log <lastTag>..HEAD`), then group into three sections
  separated by a `----` line:
  - `New Features:` / `Improvements:` / `Fixes:`, each with `- ` bullets.
  - Consolidate near-duplicate commits into one bullet; fold the storyboard/refactor churn
    into a single "rebuilt in code" Improvements line.
- Intro: a theme-flavored paragraph ending in "Here's what's new:". Closer: a warm sign-off
  ending in "Happy tracking!".

### CRITICAL: every locale must be filled before you can submit

- App Store display-time fallback to the primary language (`en-US`) only applies to locales
  that have **no localization record at all**.
- A new version draft **carries forward localization records** from the previous version.
  Submission validation then requires a **non-empty `whatsNew` for every one of those
  records** — empty fields block "Submit for Review" even though they would fall back at
  display time.
- **Practice:** write `en-US`, then copy the *same English text* into every other locale on
  the draft.

### Commands

```bash
# Version IDs (iOS and macOS are separate records)
asc versions list --app 1476153872 \
  | jq -r '.data[] | [.attributes.platform, .attributes.versionString, .attributes.appStoreState, .id] | @tsv'

# Locales present on a version draft
asc localizations list --version <VERSION_ID> | jq -r '.data[].attributes.locale'

# Set What's New for one locale (newline-safe)
asc localizations update --version <VERSION_ID> --locale en-US --whats-new "$(cat notes.txt)"

# Reuse English across all locales: loop the same text over every non-en-US locale on the draft
```

---

## Voice rules (both surfaces)

- **No em-dashes (—) or en-dashes (–).** Plain hyphens in compound words (`two-factor`,
  `real-time`) are fine.
- **Never "we", "our", or "us".** Kurozora is a one-person project; that phrasing implies a
  team. Address the user directly with "you", or describe the app impersonally
  ("This update brings…", "Kurozora now…").
- See also [`Localization.md`](Localization.md).
