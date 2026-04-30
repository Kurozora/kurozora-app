//
//  ProfileBlockedOptInTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A delegate that responds to interactions inside a ``ProfileBlockedOptInTableViewCell``.
protocol ProfileBlockedOptInTableViewCellDelegate: AnyObject {
	/// Tells the delegate that the user tapped the "View posts" opt-in button.
	///
	/// - Parameter cell: The cell whose button was tapped.
	func profileBlockedOptInTableViewCellDidPressViewPosts(_ cell: ProfileBlockedOptInTableViewCell)
}

final class ProfileBlockedOptInTableViewCell: KTableViewCell {
	// MARK: - Views
	private let headlineLabel: KLabel = {
		let label = KLabel()
		label.font = UIFont.preferredFont(forTextStyle: .title2).bold
		label.numberOfLines = 0
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private let subtitleLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.numberOfLines = 0
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private let viewPostsButton: KTintedButton = {
		let button = KTintedButton()
		button.setTitle(L10n.viewPosts, for: .normal)
		button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
		return button
	}()

	private let stackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .leading
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	// MARK: - Properties
	weak var delegate: ProfileBlockedOptInTableViewCellDelegate?

	override var isSkeletonEnabled: Bool { false }

	// MARK: - Initializers
	override func sharedInit() {
		super.sharedInit()

		self.selectionStyle = .none
		self.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.contentView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		self.contentView.addSubview(self.stackView)
		self.stackView.addArrangedSubview(self.headlineLabel)
		self.stackView.addArrangedSubview(self.subtitleLabel)
		self.stackView.setCustomSpacing(20, after: self.subtitleLabel)
		self.stackView.addArrangedSubview(self.viewPostsButton)

		NSLayoutConstraint.activate([
			self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 24),
			self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -24)
		])

		self.viewPostsButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileBlockedOptInTableViewCellDidPressViewPosts(self)
		}, for: .primaryActionTriggered)
	}

	// MARK: - Configuration
	/// Configures the cell with the given username.
	///
	/// - Parameter username: The display username of the blocked user.
	func configure(with username: String) {
		let mention = "@\(username)"
		self.headlineLabel.text = L10n.usernameIsBlocked(mention)
		self.subtitleLabel.text = L10n.viewBlockedPostsPrompt(mention)
	}
}
