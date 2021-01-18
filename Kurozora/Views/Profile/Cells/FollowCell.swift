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
	// MARK: - IBOutlets
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var followButton: KTintedButton!

	// MARK: - Properties
	weak var delegate: FollowCellDelegate?
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
	func updateFollowButton() {
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
		self.delegate?.followCell(self, didPressButton: sender)
	}
}
