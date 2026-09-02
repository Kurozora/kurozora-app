@Web Updates @iOS Updates The days are long, the sun is high, and Kurozora is soaking up the season. The **Summer Solstice** update is the biggest one in months, bringing a fresh start in your language plus a wave of new features, redesigns, and fixes across the app and website. Here's everything that's new:

# Website
## :new: Additions

- **Add from a Link**: Recommend a title with `add_to_library` appended so they get prompted to add it straight to their library. I recommend [Re:Zero](https://kurozora.app/anime/rezero-kara-hajimeru-isekai-seikatsu-4th-season?add_to_library=planning)
- **Notifications Page**: Catch up on everything in one place with the new [notifications page](https://kurozora.app/notifications)
- **Reputation Leaderboards**: See how the community stacks up on the new [reputation leaderboards](https://kurozora.app/leaderboards/reputation), with reputation now shown on profiles
- **Reporting**: Flag users or content that breaks the rules so moderation can step in
- **Parental Guide**: Now open for community reactions, submissions, and reports
- **Stickers Page**: Browse and grab Kuro-chan stickers on the new [stickers page](https://kurozora.app/stickers)
- **Community Guidelines**: Know what's expected with the new [Community Guidelines](https://kurozora.app/kb/guidelines)
- **Easter Egg**: A little something hidden away in [humans.txt](https://kurozora.app/humans.txt) :p

----
## :sparkles: Improvements

- **Navigation Redesign**:
    - A floating, iPadOS-style sidebar with a new Catalog section and collapsible groups
    - A responsive dropdown redesigned to match the sidebar
    - Smooth scroll-edge effects as content passes the bar
    - Breadcrumbs for easier navigation
- **Detail Page Redesign**:
    - Bigger profile pictures and color-filled headers for characters, people, studios, and platforms
    - Studio headers now use a banner image when one is available
    - Cleaner section spacing throughout
- **More Polish**:
    - A simpler Re:CAP with smoother blurring
    - A tidied-up settings layout
    - A smaller music play button to match the app
- **Real-Time**:
    - Notifications sync read and unread instantly across your devices
    - Live online status on profiles
- **Performance**: Moved to Laravel Octane, Reverb, and Redis for faster, snappier pages
- **Search**: Filters now support include, exclude, and multi-select, and search remembers your selected type
- **Season Badges**: Jump to a specific year right from a season badge

----
## :bug: Fixes

- Profiles with non-Latin names now get readable links
- Sign in with Apple works even without an email address
- YouTube embeds load again
- Hidden library items stay private from everyone but you
- Past episodes no longer show titles that aren't in your Watching library
- Library and search now respect your TV rating setting
- The A-Z filter works for translated character names
- Usernames can no longer be set to an email address
- The default favicon no longer disappears when you haven't picked an app icon
- Studio and season pages load their full details reliably
- Blocked-user lookups work correctly
- More accurate number formatting

---

[Full Changelog of 1180 changes](https://github.com/Kurozora/kurozora-web/compare/1.13.0...1.14.0)




# App
## :new: Additions

- **Speak Your Language**: Kurozora now speaks 18 languages, and you can switch on the fly without restarting
- **Two-Factor Authentication**: Add an extra layer of security with an authenticator app and recovery codes
- **Parental Guide**: Content guidance for anime, manga, and games, shaped by community voting and editing
- **Seasonal Browsing**: Explore anime by season and year, and tap a season badge to dive right in
- **Up Next Widget**: Mark your next episode as watched without ever opening the app
- **Live Notifications**: Notifications arrive in real time, and you can clear them in bulk with the new batch mode
- **Live Status**: See who's online right from their profile
- **Mentions**: Get notified when someone `@mentions` you, with autocomplete when you mention others
- **Drafts**: Save a feed post for later and pick up right where you left off
- **Account Switcher**: Switch accounts right from the message composer
- **Quote & Re-Share**: Re-share a post with your own take on top
- **Markdown in the Feed**: Style your posts with Markdown
- **Expandable Posts**: Tap to expand long feed messages inline
- **Review Pages**: Open any review on its own page, then select or copy the text
- **Media Viewer**: Tap an image to pinch, zoom, and pan full screen
- **Delete Ratings**: Changed your mind? Remove a rating in a tap
- **Manage Blocked Users**: Review and unblock everyone you've blocked from one place
- **Reputation**: A new list highlights the community's standout members
- **Smarter Search**: Filter results with tokens
- **Profile Pictures**: Build one from emoji, kaomoji, a monogram, or your favorite character, with smart cropping to frame it
- **Library, Leveled Up**:
  - Search inside your own library, from inside your own library
  - A new table layout with batch editing, per-item visibility, and custom columns for big screens
- **Manage Your Subscription**: Handle your subscription, restore purchases, and request refunds in-app
- **Reminder Subscriptions**: Subscribe in more calendar apps, including Fantastical and Proton Calendar
- **WhatsApp Stickers**: Install Kuro-chan stickers for WhatsApp from settings
- **Cache Settings**: See exactly what Kurozora is storing, and clear it when you like
- **iOS 26 Touches**: A sidebar profile view and media controls in the tab bar

----
## :sparkles: Improvements

- **Rebuilt in Code**: The app was rebuilt without storyboards, so screens load faster and more reliably
- **Performance**:
    - Startup and session restore now happen in parallel for a quicker launch
    - Smarter pagination and batch loading across the feed, reviews, and search
    - Cached heights and prefetched images keep the feed scrolling smoothly
    - Faster music loading with Apple Music prefetching
- **Design**:
    - A redesigned achievements page
    - A new centered profile banner with smooth transitions when you change your picture
    - A fresh set of splash animations, previewable in Motion settings
    - Cleaner episode lockups that drop redundant season text
    - A scrollable stats row on smaller profile screens
- **Widgets**: More Date widget customization, including font weight and width
- **Settings**: Section headers and helpful descriptions throughout
- **Dates & Times**: Dates and numbers now follow your locale
- **Themes**: A redesigned download flow with clear progress
- **Rich Links**: Sharper previews that load better
- **Accessibility**: Better color contrast for readability

----
## :bug: Fixes

- Fixed a crash when signing out
- Fixed a crash when switching library type
- Fixed crashes when resizing the window on Mac and iPad
- Fixed a crash during sign-in
- Fixed a crash in the notifications list
- Fixed a crash when formatting negative numbers
- Fixed Up Next crashing and mis-scrolling when marking episodes as watched
- Profile images no longer fall back to placeholders when switching accounts
- The feed editor now grows correctly as you type
- GIFs display at the right size in the feed
- Library columns, gestures, per-type layout, and square game posters behave correctly on Mac and iPad
- No more flash of the wrong items when switching library type
- Your library settings no longer change when viewing someone else's library
- Nav and tab bars look right on iOS 18 and iOS 26
- Buttons and titles are legible again on iOS 26's glass design
- Large titles hide correctly on iOS 26
- The sidebar no longer overlays the Home screen on first launch on iPad
- Chimes no longer dim your other audio, and the default chime label is no longer empty on fresh installs
- Full songs play correctly with an Apple Music subscription, and the play button shows the right state
- Face ID, Touch ID, and Optic ID prompts now appear reliably after the app is locked
- The unlock screen no longer flashes by on a cold launch
- Notification badges show the right unread count
- Character and person cards no longer stretch too tall
- The color picker presents correctly on iPad

---

[Full Changelog of 364 changes](https://github.com/Kurozora/kurozora-app/compare/1.13.0...1.14.0)
