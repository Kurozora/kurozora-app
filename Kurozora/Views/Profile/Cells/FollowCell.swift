//
//  FollowCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FollowCell: KTableViewCell {
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var followButton: KTintedButton!

	var user: User! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		// Configure username
		self.usernameLabel.text = user.attributes.username

		// Configure profile image
		self.profileImageView.image = user.attributes.profileImage

		// Configure follow button
		self.updateFollowButton()
	}

	/// Updated the `followButton` with the follow status of the user.
	fileprivate func updateFollowButton() {
		let followStatus = self.user.attributes.followStatus
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

	// MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		KService.updateFollowStatus(forUserID: user.id) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let followUpdate):
				self.user.attributes.update(using: followUpdate)
				self.updateFollowButton()
			case .failure: break
			}
		}
	}
}
