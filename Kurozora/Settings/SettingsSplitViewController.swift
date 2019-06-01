//
//  SettingsSplitViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class SettingsSplitViewController: UISplitViewController {
	var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .default }
		let statusBarStyle = UIStatusBarStyle.fromString(statusBarStyleString)

		return statusBarStyle
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		self.preferredDisplayMode = .allVisible
		self.delegate = self
    }
}

// MARK: - UISplitViewControllerDelegate
extension SettingsSplitViewController: UISplitViewControllerDelegate {
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return true
	}
}
