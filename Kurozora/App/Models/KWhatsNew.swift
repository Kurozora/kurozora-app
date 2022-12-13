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
		return v11
	}

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
