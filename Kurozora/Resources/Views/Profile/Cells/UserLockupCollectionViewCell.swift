//
//  UserLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol UserLockupCollectionViewCellDelegate: AnyObject {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton)
}

class UserLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var followStatusLabel: KSecondaryLabel!
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var followButton: KTintedButton!

	// MARK: - Properties
	weak var delegate: UserLockupCollectionViewCellDelegate?

	// MARK: - Functions
	func configure(using user: User?) {
		guard let user = user else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure username
		self.primaryLabel.text = user.attributes.username

		// Configure follow status
		self.updateFollowStatusLabel(for: user)

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure follow button
		self.updateFollowButton(using: user.attributes.followStatus)
	}

	/// Updated the `followButton` with the follow status of the user.
	func updateFollowButton(using followStatus: FollowStatus) {
		switch followStatus {
		case .followed:
			self.followButton.setTitle(L10n.followingButton, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.followButton.setTitle(L10n.followButton, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle(L10n.followButton, for: .normal)
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	/// Updates the (`secondaryLabel`) follow status label.
	fileprivate func updateFollowStatusLabel(for user: User) {
		if let userID = User.current?.id {
			let followerCount = user.attributes.followerCount
			var secondaryLabelText = user.id == userID ? "You, followed by you!" : "Be the first to follow!"

			switch followerCount {
			case 0: break
			case 1:
				if user.id == userID {
					secondaryLabelText = "Followed by you... and one fan!"
				} else {
					secondaryLabelText = user.attributes.followStatus == .followed ? "Followed by you." :  "Followed by one user."
				}
			case 2...999:
				if user.id == userID {
					secondaryLabelText = "Followed by you and \(followerCount) fans."
				} else {
					secondaryLabelText = user.attributes.followStatus == .followed ? "Followed by you and \(followerCount) users." :  "Followed by \(followerCount) users."
				}
			default:
				if user.id == userID {
					secondaryLabelText = "Followed by \(followerCount.kkFormatted(precision: 0)) fans."
				} else {
					secondaryLabelText = user.attributes.followStatus == .followed ? "Followed by you and \((followerCount - 1).kkFormatted(precision: 0)) users." : "Followed by \(followerCount.kkFormatted(precision: 0)) users."
				}
			}

			self.secondaryLabel.text = secondaryLabelText
		} else {
			self.secondaryLabel.text = ""
		}
	}

	/// Configures the cell for display in a mention autocomplete panel.
	func configureForMention(using user: User?) {
		guard let user = user else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = user.attributes.username
		self.secondaryLabel.text = "@\(user.attributes.slug)"
		user.attributes.profileImage(imageView: self.profileImageView)

		self.followButton.isHidden = true
		self.followButton.isUserInteractionEnabled = false

		switch user.attributes.followStatus {
		case .followed:
			self.followStatusLabel.isHidden = false
			let textColor = KThemePicker.subTextColor.colorValue
			let attachment = NSTextAttachment()
			attachment.image = UIImage(systemName: "person.fill")?.withTintColor(textColor, renderingMode: .alwaysOriginal)
			let attributedString = NSMutableAttributedString(attachment: attachment)
			attributedString.append(NSAttributedString(string: " Following", attributes: [
				.foregroundColor: textColor,
				.font: UIFont.preferredFont(forTextStyle: .caption1)
			]))
			self.followStatusLabel.attributedText = attributedString
		case .notFollowed, .disabled:
			self.followStatusLabel.isHidden = true
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.followStatusLabel.isHidden = true
		self.followButton.isHidden = false
		self.followButton.isUserInteractionEnabled = true
	}

	// MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		self.delegate?.userLockupCollectionViewCell(self, didPressFollow: sender)
	}
}
