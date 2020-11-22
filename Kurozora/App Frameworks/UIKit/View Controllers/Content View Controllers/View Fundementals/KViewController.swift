//
//  KViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A supercharged object that manages a view hierarchy for your UIKit app.

	This implemenation of [UIViewController](apple-reference-documentation://hs37A1uTs6) implements the following behavior:
	- The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.

	Create a custom subclass of `KViewController` for each view that you manage.

	- Tag: KViewController
*/
class KViewController: UIViewController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}
}
