//
//  KWhatsNewViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import WhatsNew
import SwiftTheme

class KWhatsNewViewController: WhatsNewViewController {
	private var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .default }
		let statusBarStyle = UIStatusBarStyle.fromString(statusBarStyleString)

		return statusBarStyle
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}
}
