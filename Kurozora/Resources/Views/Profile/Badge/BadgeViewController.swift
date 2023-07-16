//
//  BadgeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class BadgeViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var symbolImageView: UIImageView!
	@IBOutlet weak var primaryButton: KTintedButton!

	// MARK: - Properties
	var profileBadge: ProfileBadge?

	override var modalPresentationStyle: UIModalPresentationStyle {
		get {
			#if targetEnvironment(macCatalyst)
			return .popover
			#else
			return .pageSheet
			#endif
		}
		set {
			super.modalPresentationStyle = newValue
		}
	}

	override var preferredContentSize: CGSize {
		get {
			return self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		}
		set {
			super.preferredContentSize = newValue
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		if let profileBadge = self.profileBadge {
			self.configureView(using: profileBadge)
		}
	}

	// MARK: - Functions
	private func configureView(using profileBadge: ProfileBadge) {
		self.profileBadge = profileBadge

		self.primaryLabel.text = profileBadge.title
		self.secondaryLabel.text = profileBadge.description
		self.symbolImageView.image = profileBadge.image
		self.primaryButton.setTitle(profileBadge.buttonTitle, for: .normal)
		self.primaryButton.isHidden = profileBadge.buttonTitle?.isEmpty ?? true
	}

	private func goToGitHub() {
		UIApplication.shared.kOpen(.githubURL)
	}

	private func goToDiscord() {
		UIApplication.shared.kOpen(.discordPageURL)
	}

	private func goToTipJar() {
		self.dismiss(animated: true) {
			WorkflowController.shared.presentTipJarView()
		}
	}

	private func goToSubscription() {
		self.dismiss(animated: true) {
			WorkflowController.shared.presentSubscribeView()
		}
	}

	// MARK: - IBActions
	@IBAction func primaryButtonPressed(_ sender: UIButton) {
		switch self.profileBadge {
		case .developer:
			self.goToGitHub()
		case .earlySupporter: break
		case .staff:
			self.goToDiscord()
		case .pro:
			self.goToTipJar()
		case .subscriber:
			self.goToSubscription()
		case .verified:
			self.goToDiscord()
		default: break
		}
	}
}
