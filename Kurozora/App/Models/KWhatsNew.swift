//
//  KWhatsNew.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import WhatsNew

class KWhatsNew {
	/// Features of the current version of the app. Don't forget to change
	static var current: [WhatsNewItem] {
		return v1_15_0
	}

    /// Features of version 1.15.0 of the app.
    static var v1_15_0: [WhatsNewItem] = [
        .image(title: "All Hallows’ Eve", subtitle: "Something wicked returns. Celebrate Halloween with the『John』and『Kur 'O Zora』app icons, and dress Kurozora up in the new『Draluc』theme.", image: .Icons.gift),
		.image(title: "A Splash of Style", subtitle: "New premium splash animations for Pro and Kurozora+ members, each with its chime perfectly timed.", image: .Icons.circleDottedCircle),
        .image(title: "Kurozora on Your Wrist", subtitle: "Kurozora arrives on Apple Watch. Check Up Next, mark episodes watched, browse your library, and search, all from your wrist.", image: .Icons.applewatchSideRight),
		.image(title: "Offline Library", subtitle: "No signal, no problem. Your library now lives on your device, so you can browse, search, and edit it offline, and everything syncs once you’re back.", image: .Icons.libraryIcloudAndArrowDown),
        .image(title: "The Countdown Is On", subtitle: "A countdown to the next episode or chapter now sits right above the synopsis.", image: .Icons.calendarBadgeClock),
        .image(title: "You Watch, Kurozora Tracks", subtitle: "Mark an episode or season as watched and the show is added to your library as Watching on its own. Once you’ve finished the season, it’s automatically marked as Completed.", image: .Icons.librarySparkles),
        .image(title: "Moving In Made Easy", subtitle: "Import .gz and .zip library exports, or simply drop one onto the app, and follow the progress as it uploads and imports.", image: .Icons.libraryArrowDownDocument),
        .image(title: "Reminders for Everyone", subtitle: "Reminders are now free for everyone, and new episode notifications let you open the episode or mark it watched in a tap.", image: .Icons.bell),
        .image(title: "Your Week", subtitle: "Catch up on the episodes and releases from everything on your list with a new weekly digest.", image: .Icons.libraryChartBarXaxisAscendingBadgeClock),
        .image(title: "Up Next Widget", subtitle: "Placeholders fill the empty slots, and text is easier to read in light mode.", image: .Icons.widget),
        .image(title: "Trailers", subtitle: "Lights, camera, anime! Browse anime and game trailers with Picture in Picture, AirPlay, downloads, and subtitles.", image: .Icons.ticketFill),
        .image(title: "Discover More", subtitle: "Find what everyone’s watching in Top Charts, walk through every release year in the Museum, and see which manga and games got an anime.", image: .Icons.buildingColumnsFill),
        .image(title: "Kotodama", subtitle: "A daily word game built from anime, manga, and game names. Five letters, six tries, one word a day.", image: .Icons.kotodama),
        .image(title: "Know Your Episodes", subtitle: "Filter episodes by manga canon, anime canon, mixed, or filler, and see which languages a title is available in.", image: .Icons.tvSlashFill),
        .image(title: "Person Relationships", subtitle: "Person pages now show how people are connected to one another.", image: .Icons.personLineDottedPersonFill),
        .image(title: "Better Reviews", subtitle: "Tag spoilers, recommend a title, vote reviews helpful, and spot Editor’s Choice picks. Profiles can now sort and filter their reviews too.", image: .Icons.listStar),
        .image(title: "Rate Your Way", subtitle: "Pick a quick reaction, classic stars, or detailed scores for every category. Your rating, your style.", image: .Icons.star),
        .image(title: "Private Notes", subtitle: "Jot down your thoughts on any title in a note only you can see.", image: .Icons.noteTextBadgeLock),
        .image(title: "Sing Along", subtitle: "Follow your favorite songs line by line with time-synced lyrics, pop them into a floating window, and control the queue right from the tab bar.", image: .Icons.musicMicrophoneAndSparkles),
        .image(title: "Tune Your Playback", subtitle: "Fine-tune playback with crossfade, skip duration, and lyrics options, and get a notification with a skip button whenever the song changes.", image: .Icons.musicCrossfade),
        .image(title: "Lost in Translation No More", subtitle: "Kurozora now speaks 38 languages, and posts, bios, and reviews can be translated right on your device.", image: .Icons.characterBubble2),
        .image(title: "Re:CAP Reimagined", subtitle: "A fresh new look for your year in review, now shareable as images.", image: .Icons.recap),
        .image(title: "Media Viewer Upgrades", subtitle: "Copy text from images with Live Text, share or save them wherever you like, and enjoy a smoother opening transition.", image: .Icons.photoStack),
        .image(title: "Smarter Search Filters", subtitle: "A rebuilt filter page with pills, clocks, and chips makes narrowing down results quicker than ever.", image: .Icons.magnifyingglassSparkle),
        .image(title: "Navigate Freely", subtitle: "Swipe to go forward again after going back, and tap the status bar a second time to jump back to where you were.", image: .Icons.handPointUp),
        .image(title: "Open in Kurozora", subtitle: "Links to people, characters, studios, songs, charts, and more now open right in the app.", image: .Icons.linkSparkle),
        .image(title: "Faster Launch", subtitle: "The splash animation and chime now play while Kurozora loads, so the app is ready the moment the splash ends.", image: .Icons.bunny),
        .image(title: "Bug Fixes", subtitle: "The ghosts in the machine have been exorcised. Crashes, stale screens, and creepy glitches have vanished into the night for a smoother spooky season.", image: .Icons.ladybug)
    ]

    /// Features of version 1.14.0 of the app.
    static var v1_14_0: [WhatsNewItem] = [
        .image(title: "Summer Solstice", subtitle: "Soak up the longest day of the year with the returning『Hanabi』,『Pink Lemonade』and『Shio Suika』summer app icons.", image: .Icons.gift),
        .image(title: "Speak Your Language", subtitle: "Kurozora now speaks your language! Available in 18 languages with live switching that updates the entire app instantly. English fills in wherever a translation is still on its way.", image: .Icons.characterBubble2),
        .image(title: "Parental Guide", subtitle: "Know before you watch, read, or play. The all-new Parental Guide breaks down mature content for shows, games, and literature, with community voting and editing to keep every entry accurate.", image: .Icons.handRaised),
        .image(title: "Two-Factor Authentication", subtitle: "Lock it down. Add an extra layer of security to your account with two-factor authentication, supporting authenticator apps and recovery codes.", image: .Icons.lock),
        .image(title: "Seasonal Browsing", subtitle: "Travel through the seasons! Browse anime by season and year to revisit what aired and discover what’s coming next.", image: .Icons.calendar),
        .image(title: "Up Next, Everywhere", subtitle: "Never lose your place. The new Up Next widget keeps your next episode one tap from your Home Screen, and you can mark episodes as watched without even opening the app.", image: .Icons.widget),
        .image(title: "Drafts, Mentions & Markdown", subtitle: "Composing just got serious. Save drafts for later, @mention users with autocomplete, style your posts with Markdown, and switch accounts right from the composer.", image: .Icons.message),
        .image(title: "Notifications, Live", subtitle: "Stay in the loop as it happens. Notifications now arrive in real time, with a new batch edit mode to mark or clear them all at once.", image: .Icons.appBadge),
        .image(title: "Review Detail", subtitle: "Give reviews the spotlight they deserve. Tap any review to open a dedicated detail page, then select or copy the text to share your favorite takes.", image: .Icons.listStar),
        .image(title: "Media Viewer", subtitle: "Get up close. A new full-screen media viewer lets you pinch, zoom, and pan through images across the app.", image: .Icons.eyeCircle),
        .image(title: "Library, Leveled Up", subtitle: "Track like a pro. Enjoy a new table layout, batch editing, per-item visibility, customizable columns, and search built right into your library.", image: .Icons.librarySparkles),
        .image(title: "Profile Picture Studio", subtitle: "Make it yours. Choose from emoji, kaomoji, or monograms, generate art with Image Playground, and let smart cropping frame your face just right.", image: .Icons.personCropCircleGear),
        .image(title: "Subscriptions, Simplified", subtitle: "Stay in control. Manage your subscription, restore past purchases, and even request a refund without ever leaving the app.", image: .Icons.gearArrow2Circlepath),
        .image(title: "Bug Fixes", subtitle: "Swept the last of the spring bugs out into the summer sun. Crashes, layout quirks, and stubborn glitches have been squashed for a smoother, brighter season ahead.", image: .Icons.ladybug)
    ]
}
