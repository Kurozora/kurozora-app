//
//  KWhatsNewModel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import WhatsNew

class KWhatsNewModel {
	/// Features of the current version of the app. Don't forget to change
	static var current: [WhatsNewItem] {
		return v1
	}

	/// Features of version one of the app.
	static var v1: [WhatsNewItem] = [
		.image(title: "Like a Candy", subtitle: "Your app with the colors you like.", image: R.image.theme_icon()!),
		.image(title: "High Five", subtitle: "Your privacy is our #1 priority!", image: R.image.privacy_icon()!),
		.image(title: "Attention Grabber", subtitle: "New follower? New message? Look here!", image: R.image.notifications_icon()!)
	]
}
