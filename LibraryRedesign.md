# Library Redesign

Plan for rebuilding the library experience first-party: remove Tabman/Pageboy, introduce three view modes (paged, indexed list, Metal grid), and raise the whole surface to a desktop-grade, Apple-like standard on iPhone, iPad, and Mac Catalyst.

**Status: planned. Blocked behind the current large feature. Nothing in this document is started.**

---

## 1. Vision

The library is the heart of the app and should feel like a flagship system app: instant, fluid at any collection size, fully operable by touch, keyboard, and pointer, and beautiful while doing it. Every interaction a power user expects on desktop must work, and every casual interaction on iPhone must stay effortless.

Guiding principles:

- **Own the stack.** No third-party UI dependencies in the library. Every state is inspectable and recoverable; no hidden state machines (see §2).
- **Prepare for the extreme.** Architecture is sized for six-figure entry counts and sustained 120 Hz, even though typical libraries are far smaller. Performance ceilings are never the reason a feature feels degraded.
- **One data layer, dumb views.** All modes render the same store snapshot; switching modes never refetches.
- **Every input is first-class.** Touch, pencil, keyboard, trackpad, mouse, Voice Control, VoiceOver, Full Keyboard Access.

## 2. Why now

- Tabman/Pageboy has a terminal design flaw, confirmed by instrumentation (2026-07-21): UIKit's `UIPageViewController` occasionally drops the animated `setViewControllers` completion when the main thread hitches on the final animation frame. Pageboy resets its `isScrollingAnimated`/`isUpdatingViewControllers` locks only inside that completion, and the stuck lock disables the pager's user interaction. One dropped callback permanently bricks the library pager, and no public Pageboy API can recover it. Full diagnosis lives in the session notes; the class of bug disappears when position is derived from `contentOffset` instead of a completion-driven state machine.
- Tabman is the last major third-party UI dependency shaping a core screen. Removing it also frees Search, ReCap, Schedule, and Seasonal (bar-only consumers) and deletes `KTabbedViewController`, `Tabman+Kurozora`, and `KFillBarIndicator`.
- The local library store (`LocalLibraryEntry` + `LibrarySyncEngine`) now makes all-status views possible offline, which the current per-status pager never exploits.

## 3. Architecture

```
LibraryContainerViewController          — owns mode, chrome, transitions
├── LibraryStore                        — single source of truth (see §8)
├── KPillBar                            — first-party status/segment bar
├── Mode: LibraryPagedViewController    — KPagedViewController + status pages
├── Mode: LibraryIndexedListViewController — one list, section index scrubber
└── Mode: LibraryGridViewController     — Metal-backed zoomable grid
```

### 3.1 KPillBar (replaces `TMBar.KBar`)

First-party pill bar: buttons, sliding indicator, edge fades, SwiftTheme, intrinsic sizing. Driven by a single `CGFloat` page position, which is the same contract the four bar-only screens already use through `updateBar(to:animated:direction:)`. Consumers: Library, FeedMessageActivity, Search, ReCap, Schedule, Seasonal, plus the Catalyst TouchBar picker.

### 3.2 KPagedViewController (replaces `KTabbedViewController`/Tabman/Pageboy)

Container view controller over a paging `UIScrollView` with strict child containment:

- Manual `beginAppearanceTransition`/`endAppearanceTransition` forwarding; appearance pairs must balance under rapid switching, interrupted swipes, and rotation.
- Lazy page instantiation with neighbor preloading; pages release far offscreen content on memory pressure.
- Position is always derived from `contentOffset`. Programmatic switches are `setContentOffset(_:animated:)`. There is no completion-gated lock anywhere.
- RTL, rotation and size-class changes preserve the anchored page.
- Continuous position callout feeds KPillBar and the TouchBar picker.

### 3.3 Modes

All three modes present the same `LibraryStore` snapshot and share selection, edit mode, and context menu infrastructure.

## 4. View modes

### 4.1 Paged by status (parity mode)

Today's layout: one page per `LibraryStatus`, hosted in the new pager. Existing `LibraryListCollectionViewController` pages plug in with only the `tabmanParent` hooks replaced. Kind switching keeps the segmented control; the page reset that today runs synchronously inside `viewWillAppear` moves off the transition window.

### 4.2 Indexed single list

Every entry of the active library kind in one scrolling view, grouped into sections with a side index scrubber:

- Grouping: by status (default), in the same canonical order as the paged mode, or alphabetical, year, season, format, rating (§7.4). The index strip adapts to the grouping (status glyphs, A–Z, years).
- The status pill bar is hidden in this mode; the index strip is its replacement, listing the statuses as jump targets.
- The library-kind segmented control stays visible. Switching kinds preserves each kind's scroll position for the session.
- Scrubber is a custom overlay (the native section index is table-view-only and the app is compositional/diffable throughout): vertical touch strip, pan to scrub, selection haptics per tick, magnification bubble while scrubbing.
- Sticky section headers with entry counts; sections collapsible.
- Cell styles reuse the existing detailed/compact/list styles.

### 4.3 Metal grid (the flagship mode)

A fully Metal-rendered poster grid with continuous pinch zoom. Deliberately over-engineered relative to today's library sizes; the point is that it never degrades.

Ships behind a settings toggle (soft launch) rather than replacing the other modes outright, so it can be validated on real devices and libraries before becoming a default. The toggle gates availability of the mode, not the whole library.

**Rendering core**

- `CAMetalLayer`-hosted view. A paired invisible `UIScrollView` owns gesture physics (pan inertia, rubber-band, indicator) while a `CADisplayLink` (preferred frame-rate range up to 120 Hz) reads `contentOffset` per frame and renders visible instances. Render only on dirty state (offset delta, texture arrival, running animation) to protect battery.
- Instanced rendering: one shared quad, per-instance transform/UV/tint/selection state. Small thumbnails packed into texture atlases to minimize binds; large zoom tiers use individual textures. Target: full visible set in single-digit draw calls.
- Layout is a pure function `(zoomScale, boundsWidth, direction) → (columns, itemFrames)`, RTL-aware, so scroll geometry, hit testing, and accessibility all derive from one source.

**Thumbnail pipeline**

- LOD tiers (roughly 64/128/256/512 px) matched to zoom level, decoded off-main via ImageIO downsampling from Kingfisher's disk cache, uploaded to `MTLTexture` asynchronously.
- LRU texture cache with an explicit byte budget scaled to device memory; eviction never blocks the render loop.
- Placeholder gradient/dominant-color quads until textures arrive, then crossfade; crossfade between LOD tiers during zoom.
- Prefetch ahead of scroll velocity vector, cancel on direction change.

**Zoom interaction**

- Continuous pinch anchored at the gesture centroid; trackpad pinch and ⌘ +/− drive the same scale. On gesture end, spring-snap to the nearest column count.
- Semantic zoom at the extremes (stretch goal, design in from the start): zoom levels form a time hierarchy — items → seasons within a year → years. Zooming out past the minimum item density collapses into season clusters, then year clusters; zooming in past maximum density transitions into card-like items with inline metadata. No rating-based groupings.

**UIKit interop**

- Hit testing via the layout function's frame index: tap to open, long-press for context menus with `UITargetedPreview` snapshots, edit-mode selection overlays (rings/checkmarks) rendered as instance state.
- Accessibility: the grid is a `UIAccessibilityContainer` publishing virtual elements for visible items (frame, label, value, custom actions), with rotor support. Keyboard focus implemented via custom `UIFocusItem`/`UIFocusItemContainer` conformances so arrow keys and Full Keyboard Access work identically to a collection view.
- Debug HUD behind a launch flag: FPS, draw calls, texture memory, cache hit rate.

## 5. Mode transitions

- `LibraryContainerViewController` performs interruptible transitions between modes.
- Baseline: crossfade with subtle scale, honoring Reduce Motion (plain fade).
- Target: matched geometry. Visible items animate from their frame in mode A to their frame in mode B (the shared layout/frame indexes of all three modes make the intersection cheap to compute). Items entering/leaving fade through.
- Mode, zoom level, scroll anchor, and filters persist per library kind and restore on relaunch (§7.6).

## 6. Chrome

- Status switching: KPillBar in paged mode only. List mode replaces it with the status index strip (§4.2); grid mode covers it with grouping/filter chrome.
- Kind switching (shows/literatures/games) stays in the toolbar segmented control in every mode; switching preserves per-kind scroll positions.
- Batch-edit chrome (select all, move, delete, overflow) must work identically in all three modes; the existing edit-mode controller generalizes over a `LibrarySelection` model owned by the container.
- Nav bar count subtitles, sort menu, layout menu carry over.

## 7. Desktop-grade feature set

### 7.1 Keyboard

- ⌘1–⌘7 status switch, ⌃⇥ mode cycle, ⌘F filter, ⌘A select all, ⌘ +/− zoom, arrows to move focus, ⇧-arrows to extend selection, Space to peek (§7.5), Return to open, Delete to remove (confirmed).
- Catalyst menu bar: View (mode, zoom, group by, sort), Edit (select all/deselect), Library (move to status, favorite, remind) with full key equivalents.
- iPad: hold-⌘ shortcut HUD lists everything above.

### 7.2 Pointer and trackpad

- Hover lift/shadow on items, hover-revealed quick actions (§7.5).
- Rubber-band (marquee) multi-selection with autoscroll; ⇧/⌘ click semantics matching AppKit conventions.
- Right-click context menus everywhere a long-press works.
- Scroll-wheel + ⌘ zooms the grid.

### 7.3 Drag and drop

- Drag entries onto another status pill to move them; spring-loaded pills switch pages mid-drag in paged mode.
- Multi-item drag stacks with badge count; works with keyboard/rubber-band selections.
- Drag out (iPad multitasking/Catalyst): poster image + deep link `NSItemProvider`.
- Drop in: media deep links from elsewhere in the app add to the hovered status (stretch).

### 7.4 Search, filter, organization

- ⌘F/pull-down filter bar scoped to the library, filtering the live store snapshot, no network.
- `UISearchTextField` tokens: status, format, season, year, rating, progress state (unwatched/behind/finished).
- Saved filters ("smart views") persisted per kind, appearing in the grouping menu.
- Group-by for list and grid: status, alphabetical, year, season, format, rating, recently updated.
- Sort parity with today plus per-group counts.

### 7.5 Quick actions and peek

- Space-bar / long-hover peek card: poster, key metadata, progress, and quick actions without leaving the library.
- Inline +1 episode/chapter action on hover (pointer) and as a swipe action (list mode).
- Swipe actions in list mode: move status, favorite, reminder, delete.
- Context menus stay model-owned (`Model+UIKit`) and identical across modes.

### 7.6 Continuity and system integration

- Per-mode, per-kind state persistence: mode, zoom, scroll anchor, grouping, filters, selection cleared.
- Full state restoration and `NSUserActivity` handoff of the current library view.
- Multiwindow: library opens in a new scene on iPad/Catalyst.
- Spotlight: library entries indexed via Core Spotlight with deep links; updates ride the sync engine.
- Quick actions from widgets/shortcuts deep-link into a specific status/mode.

### 7.7 Feel

- Haptics: index scrub ticks, zoom snap, mode switch, drag hover on pills.
- Skeleton states per mode; empty states per status with a call to action.
- All strings through `L10n`; RTL verified in all three modes including the Metal layout function.
- VoiceOver: rotor by status, custom actions (move, +1, favorite), meaningful values (progress). Dynamic Type in list/paged modes. Reduce Motion alternates for every transition. Voice Control labels on custom controls.

## 8. Data layer: LibraryStore

The store is a facade with one job: emit immutable snapshots that every mode renders dumbly. Diffing stays inside the store. Snapshot application never runs synchronously inside a paging transition (root trigger of the Pageboy wedge). What varies is where the entries come from.

### 8.1 The snapshot contract

- All modes consume `LibraryEntrySnapshot` values: the entries for the active kind, plus the resolved grouping/sort/filter. A snapshot is a value type; modes never touch the underlying store.
- The renderable unit is a lightweight **projection** — the fields a cell needs and nothing more: trackable ID, media kind (show/literature/game), library status, personal rating, progress (episodes/chapters watched + total), poster thumbnail reference, title for indexing. Full media objects (synopsis, relationships, full artwork) are never required to render a cell; they are fetched on tap through the existing detail path.
- The field set is deliberately capped. It must cover exactly three needs and nothing more: render a cell, compute comparison deltas (§8.4), and drive the **Add to my library** action available when viewing another user's library (media kind + trackable ID feed the existing add-to-library flow). Anything beyond that belongs to the full media object, fetched on tap.
- Because the renderable unit is a projection, the store is source-agnostic: any provider that can yield projections feeds all three modes identically. No mode is second-class for any source.

### 8.2 Own library — local store

- Backed by `LocalLibraryEntry`/`LibrarySyncEngine`: offline-first, all statuses at once, live observation via the existing Core Data observer. No refetch on mode or kind switch.
- This is already resident in memory during a session, so comparison against the current user is free (§8.4).

### 8.3 Other users' libraries — the library index (the proper solution)

The problem with viewing or comparing another user's library is that neither task actually needs *their library*; it needs *an index of it*. Downloading full media objects for someone else's collection is wasteful for viewing and unnecessary for comparison, and paginating is a poor experience for both. The resolution is to serve the projection directly.

- **A compact, complete index endpoint.** The backend exposes every entry of a target user's library as the lightweight projection above (no embedded media resources), for the requested kind. A projection is on the order of ~100 bytes; even a very large library is a small, single logical fetch. It is delivered complete — cursor-batched internally if needed, but assembled fully before display — so the client holds the whole index and all three modes work with no pagination and no degradation. Other users are **not** paged-only.
- **Ephemeral in-memory provider.** The fetched index lives in a session-scoped in-memory store, never written to Core Data. Someone else's library must not pollute the local store the sync engine owns or survive beyond the visit.
- **Conditional revalidation, memory-only cache.** The index carries a version token on an `ETag` header (consistent with the me-state sync decision — side-channel values ride headers, never the resource body). Re-opening the same user's library within a session is a conditional GET: unchanged means a `304` and the in-memory index is reused. No disk cache — the index is session-scoped memory only, discarded when the visit ends.
- **Poster art costs nothing extra.** Thumbnails resolve through the same Kingfisher/CDN references any poster grid already uses; the index only carries the reference, not the image.
- **Add to my library while viewing.** Every mode keeps the "Add" affordance when viewing another user's library, so a viewer can add any of the owner's entries to their own. The action needs only the projection (media kind + trackable ID) and routes through the existing add-to-library flow; the added entry then flows into the viewer's own local store via the sync engine as usual.
- **Cross-repo prerequisite.** This needs a new lightweight library-index resource on kurozora-web and a matching `*Request` type in KurozoraKit (the app never raw-URLSessions an endpoint). This is a real dependency to schedule, not an app-only change.

**Visibility and filtering are entirely server-side.** The index the client receives is already the exact set the viewer is permitted to see; the app never receives — and so can never leak — an entry it should not show. Current policy (2026-07-26):

1. **Libraries are public by default.** The viewer's preferred TV rating gates the result: they see only entries at or below their own rating preference. *(implemented)*
2. **Owner-hidden titles.** Specific entries the owner has hidden are omitted from every viewer's index. *(implemented)*

Planned extensions to this tiered model (backend, not part of the app-side plan; the client needs no change since it only renders what it is given):

3. Owner toggle to hide all `is_nsfw = true` entries regardless of the title's TV rating. *(not implemented)*
4. Owner sets the entire library to private. *(not implemented)*

Block relationships are enforced server-side by the existing blocking system (a blocked or blocking user cannot read the index), consistent with how the rest of the app gates cross-user access.

Rejected alternatives: paginating the full library resource (bad UX, the reason we're here); downloading the full library into a temporary Core Data store (heavy, pollutes the store, wasteful when only projections are shown); a per-source mode split where others get paged-only (makes modes inconsistent and defers the real design instead of doing it).

### 8.4 Comparison (future consumer, enabled now)

Library comparison is a planned feature; the index abstraction is precisely its substrate, which is why the data layer is designed for it now even though the comparison UI is out of scope for this redesign.

- Comparison is set algebra over projections keyed by trackable ID: both own (in both libraries), only-mine, only-theirs, plus per-entry deltas (rating difference, progress difference, status difference). None of it needs full media objects.
- My side comes from the resident local store with zero refetch; their side is one index fetch (§8.3). Symmetric, cheap, and offline-capable for my half.
- Tapping any comparison result hydrates the full media detail on demand through the existing path. "Only-theirs" results keep the **Add to my library** affordance (§8.3), since those are exactly the titles a viewer is most likely to want.
- **Dedicated, adaptive screen.** Comparison ships as its own screen, laid out for the space it has:
  - **Compact width (phone):** a single scroll with a segmented switch between the buckets (both / only-mine / only-theirs), or a stacked sectioned list — never two cramped side-by-side columns.
  - **Regular width (iPad, Mac):** a true side-by-side two-library layout with the delta/overlap column between them, taking advantage of the width.
  - **Live window resizing (iPad Split View / Stage Manager, Mac):** the layout re-flows across the compact/regular boundary on the fly via size-class and bounds changes, with no reload of the already-resident data — the same responsive discipline as the library modes themselves.
- This plan only commits to making the store and index able to feed comparison; the comparison screen itself is scheduled with the comparison feature.

## 9. Performance budgets

- 120 Hz sustained scroll and pinch in the grid on ProMotion devices; zero dropped frames at 60 Hz on the oldest supported hardware.
- Cold library open to first content < 250 ms from local store.
- Mode switch < 400 ms including matched-geometry animation.
- Texture memory ≤ budget scaled per device; no memory-warning terminations at 100k entries (synthetic fixture).
- Scroll hitch rate measured with `MXMetricKit`/os_signpost before and after each phase; budgets enforced, not aspirational.

## 10. Phases

Each phase is shippable. Estimates are focused solo working days.

| Phase | Scope | Size |
|---|---|---|
| P0 | `LibraryStore` + projection/snapshot contract (§8.1); own-library provider over the local store; pages consume snapshots; move kind-mismatch reset off the transition window | 4–5 d |
| P1 | `KPillBar` + `KPagedViewController`; migrate Library, FeedMessageActivity, Search, ReCap, Schedule, Seasonal, TouchBar; delete Tabman/Pageboy | 6–9 d |
| P2 | Indexed single list + scrubber, status grouping, sticky headers, per-kind scroll retention | 4–6 d |
| P3 | Metal grid engine: renderer, texture pipeline, pinch zoom, hit testing; settings toggle | 10–15 d |
| P4 | Grid interop hardening: accessibility container, keyboard focus, edit mode, context menus, RTL | 4–6 d |
| P5 | Mode container, transitions (crossfade → matched geometry), per-mode persistence | 4–6 d |
| P6 | Desktop layer: keyboard map, menu bar, pointer/hover, rubber-band selection, drag and drop | 6–9 d |
| P7 | Search/filter/tokens, saved views, group-by everywhere | 5–7 d |
| P8 | Continuity: restoration, handoff, Spotlight, multiwindow; semantic zoom stretch | 5–8 d |
| PX | **Library-index provider** (§8.3): kurozora-web index resource + KurozoraKit `*Request` + app in-memory provider + ETag revalidation. Cross-repo; unblocks other-user libraries in every mode and the comparison substrate. Schedulable any time after P0 (modes are source-agnostic); best landed alongside P2 so viewing another user's library has a strong default mode. Gated on the visibility policy in §12. | 4–6 d app + backend |

Total: roughly 9–14 focused weeks app-side, plus the PX backend dependency. P0–P1 alone kill the wedge bug and both dependencies and are worth shipping early regardless of the rest.

## 11. Testing

- Unit: `LibraryStore` snapshots (grouping/sort/filter matrices), layout function (zoom → frames, RTL).
- Appearance-forwarding tests for `KPagedViewController` (balanced will/did pairs under interruption) — this is exactly where the old stack failed.
- Synthetic 100k-entry fixture for grid perf runs; signpost-based hitch measurement in CI-adjacent local runs.
- Snapshot tests for cell styles across modes; accessibility audit (VoiceOver walkthrough, Full Keyboard Access pass) per phase.

## 12. Open questions

All prior open questions are resolved (2026-07-26):

- **Modes for other users** — complete library-index projection, so all three modes work for them, not paged-only (§8.3).
- **Default list grouping** — by status in canonical paged order (§4.2).
- **Pill bars** — status pill bar hidden in list mode, replaced by a status-jump index strip; library-kind segmented control stays visible in all modes and preserves per-kind scroll position (§4.2, §6).
- **Semantic zoom** — time hierarchy (items → seasons → years), no rating eras (§4.3).
- **Grid rollout** — behind a settings toggle (§4.3).
- **Library-index visibility** — public by default, filtered server-side by the viewer's TV rating plus owner-hidden titles; two further tiers (owner NSFW toggle, owner private library) are planned backend work; blocking enforced by the existing system (§8.3).
- **Index cache** — memory-only, session-scoped, no disk cache (§8.3).
- **Comparison surface** — dedicated adaptive screen: single-scroll/segmented on compact width, side-by-side on regular width, re-flowing live on window resize (§8.4).
- **Projection field set** — capped at cell rendering + comparison deltas + the Add action (media kind, trackable ID, status, rating, progress, poster ref, title); anything more is the full media object fetched on tap (§8.1).

No open questions remain for the app-side plan. The only external dependency is the kurozora-web library-index resource + KurozoraKit request (phase PX), including the two unimplemented visibility tiers when those are prioritized.

## 13. Out of scope (parked ideas)

- Import/export of libraries (CSV or third-party service migration).
- Shared/public library links rendered by the website.
- "Continue watching" smart rail inside the library (belongs to Home/Digest).
- Pencil hover previews beyond the standard pointer treatment.
