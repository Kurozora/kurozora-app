//
//  AuthenticationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class AuthenticationViewController: UIViewController {
	@IBOutlet weak var lockImageView: UIImageView! {
		didSet {
			lockImageView.theme_tintColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var unlockDescriptionView: UIView!
	@IBOutlet weak var unlockButton: UIButton! {
		didSet {
			unlockButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			unlockButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var subTextLabel: UILabel! {
		didSet {
			subTextLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	private var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .default }
		let statusBarStyle = UIStatusBarStyle.fromString(statusBarStyleString)

		return statusBarStyle
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}

	override func viewDidAppear(_ animated: Bool) {
		Kurozora().handleUserAuthentication()
		unlockDescriptionView.isHidden = true
		lockImageView.isHidden = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		unlockDescriptionView.isHidden = true
		lockImageView.isHidden = false
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "authentication", bundle: nil)
		return storyboard.instantiateInitialViewController()
	}

	/// Hides and unhides the description text shown when authenticating
	func toggleHide() {
		unlockDescriptionView.isHidden = !unlockDescriptionView.isHidden
		lockImageView.isHidden = !lockImageView.isHidden
	}

	// MARK: - IBActions
	@IBAction func unlockButtonPressed(_ sender: UIButton) {
		toggleHide()
		Kurozora().handleUserAuthentication()
	}
}
