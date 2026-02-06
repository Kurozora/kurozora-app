//
//  AuthenticationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationViewController: KViewController {
	// MARK: - Views
	private var blurEffectView: KVisualEffectView!
	private var lockImageView: UIImageView!
	private var unlockDescriptionView: UIView!
	private var unlockButton: KTintedButton!
	private var subtextLabel: KLabel!

	// MARK: - View
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		KurozoraDelegate.shared.handleUserAuthentication()
		self.unlockDescriptionView.isHidden = true
		self.lockImageView.isHidden = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureView()

		self.unlockDescriptionView.isHidden = true
		self.lockImageView.isHidden = false

		let subText = "Use the button above to unlock Kurozora or if you're snooping around someone else's device then "
		#if targetEnvironment(macCatalyst)
			self.subtextLabel.text = subText + "press ⌘ + Q to quit 😤"
		#else
			self.subtextLabel.text = subText + "exit the app 😤"
		#endif
	}

	// MARK: - Functions
	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureBlurEffectView()
		self.configureLockImageView()
		self.configureUnlockDescriptionView()
		self.configureUnlockButton()
		self.configureSubtextLabel()
	}

	private func configureBlurEffectView() {
		self.blurEffectView = KVisualEffectView()
		self.blurEffectView.translatesAutoresizingMaskIntoConstraints = false
		self.blurEffectView.effect = UIBlurEffect(style: .dark)
	}

	private func configureLockImageView() {
		self.lockImageView = UIImageView()
		self.lockImageView.translatesAutoresizingMaskIntoConstraints = false
		self.lockImageView.image = UIImage(systemName: "lock.fill")
	}

	private func configureUnlockDescriptionView() {
		self.unlockDescriptionView = UIView()
		self.unlockDescriptionView.translatesAutoresizingMaskIntoConstraints = false
	}

	private func configureUnlockButton() {
		self.unlockButton = KTintedButton()
		self.unlockButton.translatesAutoresizingMaskIntoConstraints = false
		self.unlockButton.highlightBackgroundColorEnabled = true
		self.unlockButton.setTitle("Unlock Kurozora", for: .normal)
		self.unlockButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.unlockButtonPressed()
		}, for: .touchUpInside)
	}

	private func configureSubtextLabel() {
		self.subtextLabel = KLabel()
		self.subtextLabel.translatesAutoresizingMaskIntoConstraints = false
		self.subtextLabel.font = .preferredFont(forTextStyle: .callout)
		self.subtextLabel.numberOfLines = 0
		self.subtextLabel.textAlignment = .center
	}

	private func configureViewHierarchy() {
		self.unlockDescriptionView.addSubview(self.unlockButton)
		self.unlockDescriptionView.addSubview(self.subtextLabel)

		self.view.addSubview(self.blurEffectView)
		self.view.addSubview(self.lockImageView)
		self.view.addSubview(self.unlockDescriptionView)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.blurEffectView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.blurEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.blurEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.blurEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

			self.lockImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.lockImageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.lockImageView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.layoutMarginsGuide.trailingAnchor),
			self.lockImageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 100),
			self.lockImageView.widthAnchor.constraint(equalToConstant: 100),
			self.lockImageView.heightAnchor.constraint(equalToConstant: 100),

			self.unlockDescriptionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.unlockDescriptionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
			self.unlockDescriptionView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.unlockDescriptionView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
			self.unlockDescriptionView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: self.lockImageView.bottomAnchor, multiplier: 1),

			self.unlockButton.topAnchor.constraint(equalTo: self.unlockDescriptionView.topAnchor),
			self.unlockButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.unlockDescriptionView.leadingAnchor),
			self.unlockButton.trailingAnchor.constraint(lessThanOrEqualTo: self.unlockDescriptionView.trailingAnchor),
			self.unlockButton.centerXAnchor.constraint(equalTo: self.unlockDescriptionView.centerXAnchor),

			self.subtextLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.unlockButton.bottomAnchor, multiplier: 1),
			self.subtextLabel.bottomAnchor.constraint(equalTo: self.unlockDescriptionView.bottomAnchor),
			self.subtextLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.unlockDescriptionView.leadingAnchor),
			self.subtextLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.unlockDescriptionView.trailingAnchor),
			self.subtextLabel.centerXAnchor.constraint(equalTo: self.unlockDescriptionView.centerXAnchor),
		])
	}

	/// Hides and unhides the description text shown when authenticating.
	func toggleHide() {
		self.unlockDescriptionView.isHidden = !self.unlockDescriptionView.isHidden
		self.lockImageView.isHidden = !self.lockImageView.isHidden
	}

	/// The actions performed when the user presses the unlock button.
	private func unlockButtonPressed() {
		self.toggleHide()
		KurozoraDelegate.shared.handleUserAuthentication()
	}
}
