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
	// MARK: - IBOutlets
	@IBOutlet weak var lockImageView: UIImageView!
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

	// MARK: - Properties
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}

	// MARK: - View
	override func viewDidAppear(_ animated: Bool) {
		Kurozora.shared.handleUserAuthentication()
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
		Kurozora.shared.handleUserAuthentication()
	}
}
