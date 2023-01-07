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
			self.followButton.setTitle("✓ Following", for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.followButton.setTitle("＋ Follow", for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle("＋ Follow", for: .normal)
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
					secondaryLabelText = "Followed by \(followerCount.kkFormatted) fans."
				} else {
					secondaryLabelText = user.attributes.followStatus == .followed ? "Followed by you and \((followerCount - 1).kkFormatted) users." : "Followed by \(followerCount.kkFormatted) users."
				}
			}

			self.secondaryLabel.text = secondaryLabelText
		} else {
			self.secondaryLabel.text = ""
		}
	}

	// MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		self.delegate?.userLockupCollectionViewCell(self, didPressFollow: sender)
	}
}
