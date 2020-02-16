//
//  AuthenticationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class AuthenticationViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var blurEffectView: UIVisualEffectView! {
		didSet {
			blurEffectView.theme_effect = ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue)
		}
	}
	@IBOutlet weak var lockImageView: UIImageView! {
		didSet {
			lockImageView.theme_tintColor = KThemePicker.textColor.rawValue
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
			subTextLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	// MARK: - Properties
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}

	// MARK: - View
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		Kurozora.shared.handleUserAuthentication()
		unlockDescriptionView.isHidden = true
		lockImageView.isHidden = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		unlockDescriptionView.isHidden = true
		lockImageView.isHidden = false

		let subText = "Use the button above to unlock Kurozora or if you're snooping around someone else's device then press "
		#if targetEnvironment(macCatalyst)
		subTextLabel.text = subText + "⌘ + Q to quit."
		#else
		subTextLabel.text = subText + "the home button to exit."
		#endif
	}

	// MARK: - Functions
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
