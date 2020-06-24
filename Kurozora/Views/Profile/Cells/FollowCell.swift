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
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var followButton: KTintedButton!
	@IBOutlet weak var separatorView: SeparatorView!

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
		profileImageView.image = userProfile.profileImage

		// Configure follow button
		followButton.setTitle(userProfile.following ?? false ? "✓ Following" : "+ Follow", for: .normal)
		followButton.isHidden = userProfile.id == User.current?.id
	}

	// MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		guard let userID = userProfile?.id else { return }
		let followStatus: FollowStatus = userProfile?.following ?? false ? .unfollow : .follow

		KService.updateFollowStatus(userID, withFollowStatus: followStatus) { result in
			switch result {
			case .success:
				if followStatus == .unfollow {
					sender.setTitle("＋ Follow", for: .normal)
					self.userProfile?.following = false
				} else {
					sender.setTitle("✓ Following", for: .normal)
					self.userProfile?.following = true
				}
			case .failure: break
			}
		}
	}
}
