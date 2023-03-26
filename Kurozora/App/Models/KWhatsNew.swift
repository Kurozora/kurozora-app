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
		return v133
	}

	/// Features of version 1.3.3 of the app.
	static var v133: [WhatsNewItem] = [
		.image(title: "Hippity Hop", subtitle: "Get ready to hop into spring with the Eggatha app icon! It’s back and ready to spread Easter cheer together with our new Pastel Paradise theme. And don’t miss out on the Easter special anime and manga recommendations!", image: R.image.icons.gift()!),
		.image(title: "Track your manga journey", subtitle: "Explore a vast universe of manga, light novels and other literature titles! Keep track of your reading progress and history while never missing a single chapter!", image: R.image.icons.manga()!),
		.image(title: "Game On!", subtitle: "Stay Ahead of the Game! Game tracking on Kurozora is now a breeze. Explore a wide variety of anime-related games, keep track of your favorites, and never miss a beat on the latest anime-inspired titles. Expand your universe beyond TV and books!", image: R.image.icons.game()!),
		.image(title: "UAL", subtitle: "With PRO and Kurozora+ you can now use the new Unified Anime Linking feature. It supports up to 12 services!", image: R.image.icons.mention()!),
		.image(title: "Jump-start", subtitle: "Now you can easily import your anime and manga list from other services directly into Kurozora, streamlining your tracking experience with just a few *taps*!", image: R.image.icons.brands.myAnimeList()!)
	]

	/// Features of version 1.3 of the app.
	static var v13: [WhatsNewItem] = [
		.image(title: "White Day Delight", subtitle: "Celebrate White Day with our heartfelt app icon, delectable White Chocolate theme, and our new Romantic Reminders anime and manga recommendations!", image: R.image.icons.gift()!),
		.image(title: "Track your manga journey", subtitle: "Explore a vast universe of manga, light novels and other literature titles! Keep track of your reading progress and history while never missing a single chapter!", image: R.image.icons.manga()!),
		.image(title: "Game On!", subtitle: "Stay Ahead of the Game! Game tracking on Kurozora is now a breeze. Explore a wide variety of anime-related games, keep track of your favorites, and never miss a beat on the latest anime-inspired titles. Expand your universe beyond TV and books!", image: R.image.icons.game()!),
		.image(title: "UAL", subtitle: "With PRO and Kurozora+ you can now use the new Unified Anime Linking feature. It supports up to 12 services!", image: R.image.icons.mention()!),
		.image(title: "Jump-start", subtitle: "Now you can easily import your anime and manga list from other services directly into Kurozora, streamlining your tracking experience with just a few *taps*!", image: R.image.icons.brands.myAnimeList()!)
	]

	/// Features of version 1.2 of the app.
	static var v12: [WhatsNewItem] = [
		.image(title: "Happy Valentine’s", subtitle: "Fall in love with our Valentine’s Day update: Love Bug app icon and theme. Don’t forget to check out the Love to Bits anime recommendation.", image: R.image.icons.gift()!),
		.image(title: "UAL", subtitle: "With PRO and Kurozora+ you can now use the new Unified Anime Linking feature. It supports up to 12 services!", image: R.image.icons.mention()!),
		.image(title: "Track your manga journey", subtitle: "Anime isn’t enough for you? Or are you more of a reader? No matter what your reason is, Kurozora has you covered. You can now keep track of your manga reading progress and history, rate and never forget where you left off. Try it now!", image: R.image.icons.manga()!),
		.image(title: "Jump-start", subtitle: "Now you can easily import your anime and manga list from other services directly into Kurozora, streamlining your tracking experience with just a few *taps*!", image: R.image.icons.brands.myAnimeList()!)
	]

	/// Features of version 1.1 of the app.
	static var v11: [WhatsNewItem] = [
		.image(title: "Merry Christmas", subtitle: "Are you in the spirit for Christmas? Check the setting for the new Meri-Chri app icon and Cozy Cabin theme.", image: R.image.icons.gift()!),
		.image(title: "Mentions", subtitle: "You can now mention users in the feed, so they never miss your messages.", image: R.image.icons.mention()!),
		.image(title: "Reminders", subtitle: "Kurozora+ users can now opt-in to personalized iCal subscriptions to be notified the next time their favorite anime is about to air! This can be done in the in-app setting.", image: R.image.icons.reminder()!),
		.image(title: "Placeholders", subtitle: "Out with the old and in with the new. The new placeholders are a treat to look at!", image: R.image.icons.placeholder()!),
		.image(title: "Account Badges", subtitle: "Are you a Kurozora+ member? You can wear your PRO+ badge with pride. But, if that's not enough for you, you can also get a verificiation badge! No monthly subscriptions required 😉", image: R.image.icons.badge()!),
		.image(title: "Song Details", subtitle: "You can now tap on a song to view its details, such as what shows it played on. You can also open songs directly in Apple Music through the share menu at the top.", image: R.image.icons.music()!)
	]

	/// Features of version 1.0 of the app.
	static var v10: [WhatsNewItem] = [
		.image(title: "Discovery", subtitle: "Built for discovery. Your anime journey starts with Kurozora!", image: R.image.icons.browser()!),
		.image(title: "Quick Start", subtitle: "Do you already have a list? Import it in the settings and enjoy!", image: R.image.icons.brands.myAnimeList()!),
		.image(title: "Like a Candy", subtitle: "Your app in the colors you like.", image: R.image.icons.theme()!),
		.image(title: "High Five", subtitle: "Your privacy is our #1, #2 and #3 priority!", image: R.image.icons.privacy()!),
		.image(title: "Attention Grabber", subtitle: "New follower? New message? New show? Look here!", image: R.image.icons.notifications()!),
		.image(title: "Accounts Switcher", subtitle: "To keep some things separate. We've got you covered 🙈", image: R.image.icons.accountSwitch()!)
	]
}
