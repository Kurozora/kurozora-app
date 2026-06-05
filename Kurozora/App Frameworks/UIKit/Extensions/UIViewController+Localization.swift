//
//  UIViewController+Localization.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension UIViewController {
	/// Re-applies localized strings to the loaded view and its navigation title view.
	@objc func reloadLocalization() {
		guard self.isViewLoaded else { return }

		self.view.reapplyLocalizationBindingsTree()
		self.navigationItem.titleView?.reapplyLocalizationBindingsTree()
	}

	/// Recursively re-localizes this view controller and everything it contains or presents.
	func reloadLocalizationTree() {
		self.reloadLocalization()
		self.children.forEach { $0.reloadLocalizationTree() }
		self.presentedViewController?.reloadLocalizationTree()
	}
}
