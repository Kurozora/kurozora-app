//
//  FollowCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

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
		if let profileImage = userProfile.profileImage, !profileImage.isEmpty {
			profileImageView.setImage(with: profileImage, placeholder: #imageLiteral(resourceName: "default_profile_image"))
		}

		// Configure follow button
		followButton.setTitle(userProfile.following ?? false ? "✓ Following" : "+ Follow", for: .normal)
		followButton.isHidden = userProfile.id == User.currentID
	}

	// MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		let follow = userProfile?.following ?? false ? 0 : 1

		KService.shared.follow(follow, user: userProfile?.id) { (success) in
			if success {
				if follow == 0 {
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
