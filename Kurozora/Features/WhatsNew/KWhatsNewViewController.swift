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
	// MARK: - Properties
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}
}
