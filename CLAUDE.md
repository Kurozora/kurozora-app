# CLAUDE.md — kurozora-app

## Build

- **Xcode project**: `Kurozora.xcodeproj` (no workspace needed)
- **Schemes**: Kurozora, Kurozora Pre-Release, Kurozora Staging, KurozoraWidgetExtension
- **Targets**: Kurozora (main app), KuroChan (stickers), KurozoraWidgetExtension (widget), KurozoraWatchApp (watchOS)
- **Deployment**: iOS 15.6+ / macOS 12.4+ (Mac Catalyst)
- **Swift**: 5.0

## Dependencies

All managed via SPM — no CocoaPods/Carthage despite legacy references.

- **KurozoraKit** — Core API framework. Shared across projects; never modify it to fix app-side bugs.
- **Kingfisher** — Image loading/caching
- **SwiftyJSON** — JSON parsing
- **KeychainAccess** — Keychain wrapper
- **SwiftTheme** — Runtime theming
- **Tabman** — Paging tab bar
- **Cosmos** — Star ratings
- **IQKeyboardManager** — Keyboard handling
- **Reachability** — Network status
- **Solar** — Sunrise/sunset calculations
- **SPConfetti** — Confetti animations
- **XCDYouTubeKit** — YouTube playback
- **Pulse** — Network logging
- **WhatsNew** — What's new screens
- **LicensePlist** — License generation
- **FLEX** — Debug tool (debug builds only)

## Code Quality

- **SwiftLint**: SPM build tool plugin (`SwiftLintBuildToolPlugin`). Config: `.swiftlint.yml`
- **SwiftFormat**: Config: `.swiftformat`
- **Periphery**: Dead code detection. Config: `.periphery.yml`

## Architecture

Hybrid **MVC + selective VIPER** (WorkflowController handles cross-cutting flows like sign-in).

### Base Classes
- `KViewController` — Base view controller
- `KCollectionViewController` — Base collection VC with DiffableDataSource support
- `KTableViewController` — Base table VC

### Key Services
- `KurozoraDelegate` — App-wide service coordinator (`Kurozora/App/Services/KurozoraDelegate.swift`)
- `NavigationManager` — URL scheme routing + programmatic navigation (`Kurozora/App/Services/Navigation/NavigationManager.swift`)
- `WorkflowController` — Multi-step flows (sign-in, onboarding) (`Kurozora/App/Services/Workflow/WorkflowController.swift`)
- `AccountManager` — Account/session management (`Kurozora/App/Services/AccountManager.swift`)
- `Store` — In-app purchase handling (`Kurozora/App/Models/Store.swift`)

### Data Layer
- **Keychain** (via KeychainAccess) — Account credentials and tokens
- **UserDefaults** — User settings and preferences
- **API-driven** — All content fetched via KurozoraKit; no CoreData or Realm

### Navigation
- URL scheme routing via `NavigationManager`
- Programmatic push/present
- Legacy storyboard segues (being phased out)

## Conventions

- **Cell configuration**: Cells expose `configure(using:)` methods. Cells must not store model objects — use delegate + indexPath lookup.
- **Cell appearance**: Variations managed internally via configure methods, not externally.
- **Notifications**: Use scoped notifications for narrow UI updates; don't reuse broad ones.
- **Collections**: `UICollectionViewDiffableDataSource` with compositional layouts (see `Layouts.swift`)
- **Skeleton loading**: `SkeletonDisplayable` protocol for placeholder states
- **Theming**: SwiftTheme with runtime theme switching
- **Localization**: All user-facing strings go through the `L10n` namespace (`Kurozora/App/Helpers/L10n/`). Follow [`Localization.md`](Localization.md) before adding or translating strings. It covers tone, register, anime terminology, context disambiguation, placeholders, plurals, and length.
- **Release notes**: In-app (`KWhatsNew.swift`) and App Store "What's New" are separate surfaces with different rules (highlights vs comprehensive, 4000-char cap, every ASC locale must be filled to submit). Follow [`WhatsNew.md`](WhatsNew.md) before writing either.

## Code Style

These rules are non-negotiable. Apply them to every file you create or edit.

- **DocC**: Apple-style documentation comments only (`/// Verb-first one-line summary.`, then a blank line and `- Parameter`/`- Returns:` blocks). No narrative implementation rationale inside method bodies.
- **No redundant comments**: Don't restate what the code says ("Configure labels", "Update the notifications", "Setup refresh control"). Keep a comment only when it explains the *why* a future reader couldn't infer.
- **Code organization**: Properties (`var`/`let`) at the top of the type, methods at the bottom. Within methods, group logical steps with blank lines.
- **No single-line `if` blocks**: Always use braces and put the body on its own line, even for one-statement bodies.
- **New types in their own files**: New cells, view models, classes, structs, enums, etc. go in their own files. Don't append unrelated types to an existing file.
- **File-internal grouping**: `// MARK: -` sections in this order — `IBOutlets`, `Views`, `Properties`, `Initializers`, `View`, `Functions`. Use one section per concern; never duplicate a `// MARK:` heading.
