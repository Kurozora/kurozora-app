//
//  ProfileBadgeStackView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ProfileBadgeStackViewDelegate: AnyObject {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge)
}

@MainActor
class ProfileBadgeStackView: UIStackView {
	// MARK: - Properties
	/// The array of user's profile badges.
	private var profileBadges: [ProfileBadge] = []
	weak var delegate: ProfileBadgeStackViewDelegate?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize profile badges stack view.
	func sharedInit() {
		self.spacing = 4.0
	}

	/// Configures the stack view with the `User` object.
	///
	/// - Parameter user: The `User` object used to configure the stack view.
	func configure(for user: User) {
		self.profileBadges = self.getProfileBadges(for: user)

		for view in self.arrangedSubviews {
			view.removeFromSuperview()
		}

		self.profileBadges.enumerated().forEach { index, profileBadge in
			let button = UIButton()
			button.tag = index
			button.setImage(profileBadge.image, for: .normal)
			button.addTarget(self, action: #selector(self.handleProfileBadgePressed(_:)), for: .touchUpInside)
			button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1.0/1.0).isActive = true

			self.addArrangedSubview(button)
		}

		let spacer = UIView()
		self.addArrangedSubview(spacer)
	}

	/// Returns the profile badges for the given user.
	///
	/// - Parameter user: The `User` object used to generate the profile badges.
	///
	/// - Returns: The profile badges for the given user.
	private func getProfileBadges(for user: User) -> [ProfileBadge] {
		var profileBadges: [ProfileBadge] = []

		if user.attributes.joinedAt.isInCurrentWeek {
			profileBadges.append(.newUser(username: user.attributes.username, isCurrentUser: User.current == user))
		}

		if user.attributes.isVerified {
			profileBadges.append(.verified(username: user.attributes.username))
		}
		if user.attributes.isStaff {
			profileBadges.append(.staff(username: user.attributes.username))
		}
		if user.attributes.isDeveloper {
			profileBadges.append(.developer(username: user.attributes.username))
		}
		if user.attributes.isEarlySupporter {
			profileBadges.append(.earlySupporter(username: user.attributes.username))
		}
		if user.attributes.isPro && !user.attributes.isSubscribed {
			profileBadges.append(.pro(username: user.attributes.username))
		}
		if user.attributes.isSubscribed, let subscribedAt = user.attributes.subscribedAt {
			profileBadges.append(.subscriber(username: user.attributes.username, subscribedAt: subscribedAt))
		}

		return profileBadges
	}

	@objc private func handleProfileBadgePressed(_ sender: UIButton) {
		guard let profileBadge = self.profileBadges[safe: sender.tag] else { return }
		self.delegate?.profileBadgeStackView(self, didPress: sender, for: profileBadge)
	}
}
