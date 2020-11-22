//
//  AuthenticationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var blurEffectView: KVisualEffectView!
	@IBOutlet weak var lockImageView: UIImageView!
	@IBOutlet weak var unlockDescriptionView: UIView!
	@IBOutlet weak var unlockButton: KTintedButton!
	@IBOutlet weak var subTextLabel: KLabel!

	// MARK: - Properties
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}

	// MARK: - View
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		KurozoraDelegate.shared.handleUserAuthentication()
		unlockDescriptionView.isHidden = true
		lockImageView.isHidden = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		unlockDescriptionView.isHidden = true
		lockImageView.isHidden = false

		let subText = "Use the button above to unlock Kurozora or if you're snooping around someone else's device then press "
		#if targetEnvironment(macCatalyst)
		subTextLabel.text = subText + "⌘ + Q to quit 😤"
		#else
		subTextLabel.text = subText + "the home button to exit 😤"
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
		KurozoraDelegate.shared.handleUserAuthentication()
	}
}
