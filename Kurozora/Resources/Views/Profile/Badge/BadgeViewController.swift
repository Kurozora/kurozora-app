//
//  BadgeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class BadgeViewController: KViewController, StoryboardInstantiable {
	static var storyboardName: String = "Badge"

	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var symbolImageView: UIImageView!
	@IBOutlet weak var primaryButton: KTintedButton!
	@IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!

	// MARK: - Properties
	var profileBadge: ProfileBadge?

	override var modalPresentationStyle: UIModalPresentationStyle {
		get {
			return UIDevice.isPhone ? .pageSheet : .popover
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

		if UIDevice.isPhone {
			self.viewWidthConstraint.constant = self.view.frame.size.width
		} else if UIDevice.isPad {
			// iPad seems to subtract 60 points from the specified width.
			// By adding 60 points before we calculate the width,
			// the total width ends up being 300 points just like on
			// Macs.
			self.viewWidthConstraint.constant = 360.0
		} else {
			self.viewWidthConstraint.constant = 300.0
		}

		if let profileBadge = self.profileBadge {
			self.configureView(using: profileBadge)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if UIDevice.isPhone {
			if #available(iOS 16.0, *) {
				self.sheetPresentationController?.detents = [
					.custom { [weak self] _ in
						guard let self = self else { return nil }
						return self.preferredContentSize.height - self.view.safeAreaInsets.bottom
					}
				]
			} else {
				self.sheetPresentationController?.detents = [.medium()]
			}

			self.sheetPresentationController?.prefersGrabberVisible = true
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
		UIApplication.shared.kOpen(.gitHubPageURL)
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

	private func goToMentionUser(username: String) {
		self.dismiss(animated: true) {
			print("----- Mentioning", username)
		}
	}

	// MARK: - IBActions
	@IBAction func primaryButtonPressed(_ sender: UIButton) {
		switch self.profileBadge {
		case .newUser(let username, _):
			self.goToMentionUser(username: username)
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
