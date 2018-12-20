//
//  SettingsSplitViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SettingsSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.preferredDisplayMode = .allVisible
		self.delegate = self
    }

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
//		guard let secondaryAsNavController = secondaryViewController as? KurozoraNavigationController else { return false }
//		guard let topAsDetailController = secondaryAsNavController.topViewController as? SettingsViewController else { return false }
//
//		if topAsDetailController.detailItem == nil {
//			return true
//		}
//		return false
//	}
		return false
	}

}
