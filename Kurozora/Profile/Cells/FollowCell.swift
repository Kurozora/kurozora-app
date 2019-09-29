//
//  FollowCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

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

		usernameLabel.text = userProfile.username
		if let profileImage = userProfile.profileImage, !profileImage.isEmpty {
			let profileImage = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImage!)
			profileImageView.kf.indicatorType = .activity
			profileImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_profile_image"), options: [.transition(.fade(0.2))])
		} else {
			profileImageView.image = #imageLiteral(resourceName: "default_profile_image")
		}

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
