//
//  BadgeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class BadgeViewController: KViewController {
	// MARK: - Views
	private var containerView: UIView!
	private var verticalStackView: UIStackView!
	private var horizontalStackView: UIStackView!
	private var verticalSubStackView: UIStackView!
	private var verticalSubStackViewContainer: UIView!
	private var primaryLabel: KLabel!
	private var secondaryLabel: KSecondaryLabel!
	private var symbolImageViewContainer: UIView!
	private var symbolImageView: UIImageView!
	private var primaryButton: KTintedButton!

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

		self.configureView()

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
	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureContainerView()
		self.configureVerticalStackView()
		self.configureHorizontalStackView()
		self.configureVerticalSubStackView()
		self.configureVerticalSubStackViewContainer()
		self.configurePrimaryLabel()
		self.configureSecondaryLabel()
		self.configureSymbolImageViewContainer()
		self.configureSymbolImageView()
		self.configurePrimaryButton()
	}

	private func configureContainerView() {
		self.containerView = UIView()
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
		self.containerView.backgroundColor = nil
	}

	private func configureVerticalStackView() {
		self.verticalStackView = UIStackView()
		self.verticalStackView.translatesAutoresizingMaskIntoConstraints = false
		self.verticalStackView.axis = .vertical
		self.verticalStackView.spacing = 16.0
	}

	private func configureHorizontalStackView() {
		self.horizontalStackView = UIStackView()
		self.horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
		self.horizontalStackView.axis = .horizontal
		self.horizontalStackView.alignment = .top
		self.horizontalStackView.spacing = 8.0
	}

	private func configureVerticalSubStackView() {
		self.verticalSubStackView = UIStackView()
		self.verticalSubStackView.translatesAutoresizingMaskIntoConstraints = false
		self.verticalSubStackView.axis = .vertical
	}

	private func configureVerticalSubStackViewContainer() {
		self.verticalSubStackViewContainer = UIView()
		self.verticalSubStackViewContainer.translatesAutoresizingMaskIntoConstraints = false
		self.verticalSubStackViewContainer.backgroundColor = nil
	}

	private func configurePrimaryLabel() {
		self.primaryLabel = KLabel()
		self.primaryLabel.translatesAutoresizingMaskIntoConstraints = false
		self.primaryLabel.font = .preferredFont(forTextStyle: .headline)
	}

	private func configureSecondaryLabel() {
		self.secondaryLabel = KSecondaryLabel()
		self.secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
		self.secondaryLabel.font = .preferredFont(forTextStyle: .body)
	}

	private func configureSymbolImageViewContainer() {
		self.symbolImageViewContainer = UIView()
		self.symbolImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
		self.symbolImageViewContainer.backgroundColor = nil
	}

	private func configureSymbolImageView() {
		self.symbolImageView = UIImageView()
		self.symbolImageView.translatesAutoresizingMaskIntoConstraints = false
		self.symbolImageView.contentMode = .scaleAspectFit
	}

	private func configurePrimaryButton() {
		self.primaryButton = KTintedButton()
		self.primaryButton.translatesAutoresizingMaskIntoConstraints = false
		self.primaryButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.primaryButtonPressed()
		}, for: .touchUpInside)
	}

	private func configureViewHierarchy() {
		self.verticalSubStackViewContainer.addSubview(self.primaryLabel)
		self.verticalSubStackViewContainer.addSubview(self.secondaryLabel)

		self.verticalSubStackView.addArrangedSubview(self.verticalSubStackViewContainer)

		self.symbolImageViewContainer.addSubview(self.symbolImageView)

		self.horizontalStackView.addArrangedSubview(self.symbolImageViewContainer)
		self.horizontalStackView.addArrangedSubview(self.verticalSubStackView)

		self.verticalStackView.addArrangedSubview(self.horizontalStackView)
		self.verticalStackView.addArrangedSubview(self.primaryButton)

		self.containerView.addSubview(self.verticalStackView)

		self.view.addSubview(self.containerView)
	}

	private func configureViewConstraints() {
		let widthConstant: CGFloat = if UIDevice.isPhone {
			self.view.frame.size.width
		} else if UIDevice.isPad {
			// iPad seems to subtract 60 points from the specified width.
			// By adding 60 points before we calculate the width,
			// the total width ends up being 300 points just like on
			// Macs.
			360.0
		} else {
			300.0
		}

		NSLayoutConstraint.activate([
			self.view.widthAnchor.constraint(equalToConstant: widthConstant),

			self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
			self.containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),

			self.primaryLabel.topAnchor.constraint(equalTo: self.verticalSubStackViewContainer.topAnchor),
			self.primaryLabel.leadingAnchor.constraint(equalTo: self.verticalSubStackViewContainer.leadingAnchor),
			self.primaryLabel.trailingAnchor.constraint(equalTo: self.verticalSubStackViewContainer.trailingAnchor),

			self.secondaryLabel.topAnchor.constraint(equalTo: self.primaryLabel.bottomAnchor, constant: 4.0),
			self.secondaryLabel.bottomAnchor.constraint(equalTo: self.verticalSubStackViewContainer.bottomAnchor),
			self.secondaryLabel.leadingAnchor.constraint(equalTo: self.verticalSubStackViewContainer.leadingAnchor),
			self.secondaryLabel.trailingAnchor.constraint(equalTo: self.verticalSubStackViewContainer.trailingAnchor),

			self.symbolImageView.widthAnchor.constraint(equalToConstant: 56),
			self.symbolImageView.heightAnchor.constraint(equalToConstant: 56),
			self.symbolImageView.topAnchor.constraint(equalTo: self.symbolImageViewContainer.topAnchor),
			self.symbolImageView.leadingAnchor.constraint(equalTo: self.symbolImageViewContainer.leadingAnchor),
			self.symbolImageView.trailingAnchor.constraint(equalTo: self.symbolImageViewContainer.trailingAnchor),
			self.symbolImageView.bottomAnchor.constraint(equalTo: self.symbolImageViewContainer.bottomAnchor),

			self.verticalStackView.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 1.0),
			self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.verticalStackView.bottomAnchor, multiplier: 1.0),
			self.verticalStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 1.0),
			self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.verticalStackView.trailingAnchor, multiplier: 1.0),

			self.primaryButton.heightAnchor.constraint(equalToConstant: 40),
		])
	}

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
	private func primaryButtonPressed() {
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
