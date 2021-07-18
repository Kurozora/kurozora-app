//
//  SearchUserResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SearchUserResultsCell: SearchBaseResultsCell {
	// MARK: - Properties
	var user: User! {
		didSet {
			configureCell()
		}
	}
	var searchImageViewSize: CGSize = .zero

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		primaryLabel.text = user.attributes.username

		// Configure follow status
		updateFollowStatusLabel()

		// Configure profile image
		searchImageView.borderColor = UIColor.white.withAlphaComponent(0.20)
		searchImageView.setImage(with: self.user.attributes.profileImageURL ?? "", placeholder: self.user.attributes.placeholderImage)

		// Configure follow button
		updateFollowButton()
	}

	/// Updated the `actionButton` with the follow status of the user.
	fileprivate func updateFollowButton() {
		let followStatus = self.user.attributes.followStatus
		switch followStatus {
		case .followed:
			self.actionButton.setTitle("✓ Following", for: .normal)
			self.actionButton.isHidden = false
			self.actionButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.actionButton.setTitle("＋ Follow", for: .normal)
			self.actionButton.isHidden = false
			self.actionButton.isUserInteractionEnabled = true
		case .disabled:
			self.actionButton.setTitle("＋ Follow", for: .normal)
			self.actionButton.isHidden = true
			self.actionButton.isUserInteractionEnabled = false
		}
	}

	/// Updates the (`secondaryLabel`) follow status label.
	fileprivate func updateFollowStatusLabel() {
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
					secondaryLabelText = user.attributes.followStatus == .followed ? "Followed by you and (\(followerCount) users." :  "Followed by \(followerCount) users."
				}
			default:
				if user.id == userID {
					secondaryLabelText = "Followed by \(followerCount.kkFormatted) fans."
				} else {
					secondaryLabelText = user.attributes.followStatus == .followed ? "Followed by you and (\((followerCount - 1).kkFormatted)) users." : "Followed by \(followerCount.kkFormatted) users."
				}
			}

			secondaryLabel.text = secondaryLabelText
		}
	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		super.actionButtonPressed(sender)

		WorkflowController.shared.isSignedIn {
			KService.updateFollowStatus(forUserID: self.user.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let followUpdate):
					self.user.attributes.update(using: followUpdate)
					self.updateFollowButton()
					self.updateFollowStatusLabel()
				case .failure:
					break
				}
			}
		}
	}
}
