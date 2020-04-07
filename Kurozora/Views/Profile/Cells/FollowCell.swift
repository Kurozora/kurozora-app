//
//  FollowCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FollowCell: UITableViewCell {
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var profileImageViewContainer: UIView! {
		didSet {
			profileImageViewContainer.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var followButton: UIButton! {
		didSet {
			followButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			followButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	var userProfile: UserProfile? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let userProfile = userProfile else { return }

		// Configure username
		usernameLabel.text = userProfile.username

		// Configure profile image
		if let profileImage = userProfile.profileImage {
			if let usernameInitials = userProfile.username?.initials {
				let placeholderImage = usernameInitials.toImage(withFrameSize: profileImageView.frame, placeholder: R.image.placeholders.profile_image()!)
				profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}

		// Configure follow button
		followButton.setTitle(userProfile.following ?? false ? "✓ Following" : "+ Follow", for: .normal)
		followButton.isHidden = userProfile.id == User().current?.id
	}

	// MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		guard let userID = userProfile?.id else { return }
		let followStatus: FollowStatus = userProfile?.following ?? false ? .unfollow : .follow

		KService.updateFollowStatus(userID, withFollowStatus: followStatus) { (success) in
			if success {
				if followStatus == .unfollow {
					sender.setTitle("＋ Follow", for: .normal)
					self.userProfile?.following = false
				} else {
					sender.setTitle("✓ Following", for: .normal)
					self.userProfile?.following = true
				}
			}
		}
	}
}
