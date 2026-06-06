# Kurozora Localization Guide

The reference for translating and authoring localized strings in the Kurozora iOS app. Read this before adding strings to the `.xcstrings` catalogs or submitting translations.

## 1. Philosophy

- Translate meaning, not words. Natural, native phrasing beats a literal rendering.
- Keep wording concise and mobile-native, especially button labels.
- Avoid machine-translation artifacts. If a phrase reads like engine output, rewrite it.
- Kurozora is an anime community app, not banking software. The voice is friendly, except where the surface needs precision (legal, billing, security).
- Prefer coverage over perfection. Every supported locale ships now, and untranslated keys fall back to English per key. Native review improves locales over time and never blocks a release.

## 2. Golden rules

1. Never translate brand names, proper nouns, or API content (titles, names, user text).
2. Never translate placeholders (`%@`, `%lld`, `%1$@`), variables, URLs, usernames, hashtags, or markdown.
3. The same English word does not always take the same translation. Disambiguate by context with a dedicated key (see Section 8).
4. One concept takes one translation. Keep the glossary in Section 13 consistent across the app.
5. Keep established anime and manga fandom terms. Translate generic genre words (Section 6).
6. Use a casual tone by default. Use a formal tone only on legal, billing, and security surfaces (Section 5).
7. Numbers, dates, plurals, and lists are formatted by API, not written out as strings (Section 4).

## 3. Never translated

- Brand and product names: `Kurozora`, `Kurozora+`, `Pro`, `Kuro-chan`. Identical in every locale.
- API content: anime, manga, game, character, studio, and franchise titles, plus synopses and person names. These come from KurozoraKit, so they are not part of the translation surface.
- Titles and franchises: preserve them as officially localized in the target market. If no official localization exists, keep the original title. See Section 7 and the language notes.
- User-generated content: handles (`@slug`), display names, reviews, feed messages.
- Technical tokens: URLs, IDs, version strings, file extensions, hashtags, markdown.

## 4. Formatted by API, not written as a string

Do not hardcode these as phrasings. They resolve against the locale at runtime.

| Concern                                              | Mechanism                                           |
|------------------------------------------------------|-----------------------------------------------------|
| Numbers and compact counts (`1.2K`, `1,2 k`, `1.2万`) | `Int.kkFormatted`                                   |
| Dates and relative time                              | `Date.formatted`, `RelativeDateTimeFormatter`       |
| Lists ("A, B & C")                                   | `ListFormatter`                                     |
| Plurals (one, other, few, many)                      | CLDR plural variations in `.xcstrings` (Section 10) |

## 5. Tone and register

General rule, mixed by surface:

- Casual everywhere users socialize, discover, track, post, comment, react, browse, and customize profiles.
- Formal and polite for legal, privacy, account deletion, subscriptions, billing, authentication, security, permissions, and irreversible actions.

Per-language specifics refine the general rule.

| Language                                       | Register                                                                              |
|------------------------------------------------|---------------------------------------------------------------------------------------|
| German                                         | `du` everywhere except legal and account-critical content                             |
| French                                         | `tu` everywhere except legal and account-critical content                             |
| Spanish                                        | informal `tú` throughout                                                              |
| Portuguese                                     | informal. `você` in Brazil. Use a `tu`/`você` mix only where native usage requires it |
| Japanese                                       | polite standard `です・ます` for UI, not keigo-heavy business language                     |
| Korean                                         | polite UI style (`해요체` or `하십시오체` by context), not casual `banmal`                    |
| Chinese                                        | standard modern UI language, neither excessively formal nor colloquial                |
| Russian, Turkish, Indonesian, Thai, Vietnamese | natural consumer-app language, not corporate wording outside legal screens            |

## 6. Anime and manga terminology

Keep these untranslated. They are the terms fans search for. Do not invent localized replacements.

`seiyuu`, `OVA`, `ONA`, `OAD`, `shounen`, `shoujo`, `seinen`, `josei`, `isekai`, `tokusatsu`, `doujinshi`, `light novel`, `visual novel`, `otaku`, `tsundere`, `yandere`, `kuudere`, `hentai`, `ecchi`

Exceptions:

- If a locale has an overwhelmingly dominant fandom translation, use it.
- A term may be translated as a UI label but kept as a content type. For example, `Voice Actor` may be translated in UI, while `Seiyuu` stays valid where it denotes a content type.

## 7. Titles and proper nouns

- Preserve anime, manga, game, character, studio, and franchise titles as officially localized in the target market.
- If no official localization exists, preserve the original title.
- Japanese: use official Japanese franchise names whenever available.
- Arabic: use Arabic-transliterated titles when that is how fans commonly search.

## 8. Context and disambiguation (developer-facing)

The core mechanism rule. The Common catalog (`Localizable.xcstrings`) uses the English source string as the key, so two identical English strings collapse into a single translation. That is wrong whenever the grammatical role or context differs.

Real collisions in Kurozora:

| English  | Distinct meanings                                                       |
|----------|-------------------------------------------------------------------------|
| `Follow` | verb or button, versus `Following` state, versus `Followers` count noun |
| `Watch`  | verb, versus `Watching` library status, versus Apple `Watch` device     |
| `Read`   | manga action, versus mark a notification read                           |
| `Play`   | game, versus trailer                                                    |

When a word's translation can vary by context, give it an explicit semantic key. Never use source-as-key.

```swift
// Context-dependent. Semantic key, defaultValue, table, comment.
String(
    localized: "watchingStatus",
    defaultValue: "Watching",
    table: "Content",
    comment: "Library status for a show the user is currently watching."
)

// Unambiguous, single meaning. Source-as-key is fine.
String(
    localized: "Cancel",
    comment: "The string for the word 'cancel'."
)
```

This is the counterweight to consolidation. Merge duplicate entries only when the meaning is identical in every target language, not when the English happens to match. The `comment:` field is the only context the translator sees, so make it carry the disambiguation.

## 9. Placeholders and technical tokens

Never translate, and never rename. Reordering is allowed.

- Format specifiers: `%@`, `%lld`, `%d`, `%f`, `%1$@`, `%2$@`
- Variable names, URLs, usernames, hashtags, markdown

Rules:

- Use positional specifiers (`%1$@`, `%2$@`) so translators can reorder arguments for the target grammar.
- Write one full sentence per entry. Never concatenate fragments, because that breaks word order and gender agreement.
- Comments describe what the string is. They never describe how a format specifier works.

## 10. Pluralization

- Use CLDR plural variations in `.xcstrings`. Never write a `count == 1 ? singular : plural` ternary, which is wrong for languages with `few` and `many` such as ru, ar, and pl.
- Two forms exist. Use the simple `%lld` form when the raw integer appears in the string, like `Delete %lld Items`. Use the substitution form `%#@count@` when the displayed number is formatted text such as a compact `1.2K`, or when no slot in the string references the number. Xcode rejects a plural variation where no slot references the number, so confirmation strings use substitution.
- Provide every plural category the language requires. Do not assume one and other.

## 11. Capitalization and punctuation

- Do not bake English Title Case into translations. German capitalizes nouns, French and Spanish use sentence case, and CJK has no case. Each translation carries its own casing.
- Locale-aware case transforms (`.uppercased(with: .current)`, `.capitalized(with:)`) are only for derived display forms. Never use them to force English casing onto a translated phrase.
- Bake punctuation into the translatable string. That covers French `« »`, spacing before `! ? : ;`, CJK fullwidth punctuation, and `「」`. Do not wrap interpolated values in hardcoded `"`.

## 12. Length and layout

- Assume a length swing of plus or minus 35 percent. German, Finnish, and Russian expand. CJK contracts.
- Prefer concise mobile-native wording. Avoid expansion above 30 percent unless the language requires it.
- Keep button labels as short as possible.
- The UI must flex. Avoid fixed-width truncation of labels, and use stack views that reclaim space.

## 13. Consistency and glossary

One concept takes one translation across the whole app. Keep a per-locale glossary for these core nouns so they never drift between screens.

`Anime`, `Manga`, `Game`, `Character`, `Episode`, `Season`, `Studio`, `Voice Actor`, `Staff`, `Watchlist`, `Timeline`, `Review`, `Library`, `Reminder`

Terminology that should follow local community usage rather than a literal translation:

- `Watchlist`: use the dominant community term for each locale.
- `Timeline`: keep the social-media terminology familiar to local users.
- `Anime Tracker`: localize naturally. Do not force a literal translation if the community uses English.

## 14. Language-specific notes

- Japanese: use official franchise names where available. Prefer native terminology over English borrowings where that is standard in anime apps.
- Chinese: maintain separate Simplified and Traditional localizations. Never auto-convert one into the other.
- Arabic: use Arabic-transliterated anime titles where fans commonly search that way. Avoid overly formal MSA where a simpler modern style works. Ensure RTL layout is correct.
- Thai: favor terminology used by Thai anime communities over dictionary translations. When uncertain, keep established fandom terms rather than over-localizing.
- Korean: use a polite UI style (Section 5), never `banmal`.

## 15. Authoring in code (developer-facing)

- Catalogs: `Localizable.xcstrings` (Common, source-as-key) plus the domain catalogs `Account`, `Content`, `Settings`, `Moderation`, and `Alerts` (semantic key, `defaultValue:`, `table:`). All access goes through the centralized `L10n` namespace in `Kurozora/App/Helpers/L10n/`.
- Comments: every entry has a `comment:` describing what the string is and its context. No format-specifier or plural mechanics.
- Resolution and live switch: entries that update on an in-app language change route through `L10n.resolve { String(localized:…, bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale) }`. The engine re-applies them in place with no relaunch. Call sites stay vanilla, like `label.text = L10n.x`.
- Encoding: `STRINGS_FILE_OUTPUT_ENCODING = binary` is used for the smallest footprint.
- Reverting a bad translation: set that key's locale value to the English source, or clear it, so per-key fallback applies. Never delete the whole locale.

## 16. Ship and review policy

- Ship all supported locales immediately.
- Missing strings fall back to English per key. Never block a locale because it is not complete.
- Prioritize coverage and iteration. Native review improves locales over time but is not required for an initial release.
- If a translation is clearly broken, revert only that key to English (Section 15).

## 17. Review checklist

Before submitting or signing off on a locale:

- [ ] Reads naturally to a native speaker, with no MT artifacts and no word-for-word translation.
- [ ] Tone matches the surface (casual versus formal per Section 5) and the per-language register.
- [ ] Fandom terms kept, generic genres translated (Section 6).
- [ ] Brand names, titles, handles, and technical tokens left verbatim (Sections 3 and 9).
- [ ] Placeholders present, correctly ordered, none renamed or translated (Section 9).
- [ ] Plural categories complete for the language (Section 10).
- [ ] Casing and punctuation follow target-language convention, not English (Section 11).
- [ ] Glossary nouns consistent with the rest of the app (Section 13).
- [ ] Fits the UI without truncation at the expected length swing (Section 12).
- [ ] Context-dependent words use the right disambiguated key (Section 8).

## 18. Examples

```text
"Follow"      de: "Folgen"        (button, casual)
"Following"   de: "Folgt"         (state, a DIFFERENT key from "Follow")
              reusing one "Follow" key for both is wrong

"Action"      ja: "アクション"      (generic genre, translate)
"seiyuu"      ja: "声優", others: "seiyuu"   (fandom term, keep unless a dominant local form exists)

"%1$@ liked your review"   reorder allowed: "%1$@ さんがレビューにいいねしました"
                           fragment concatenation like "Liked your review by " + name is wrong

"Delete account?"   formal register (account-critical surface)
"Nice pick!"        casual register (social surface)
```
