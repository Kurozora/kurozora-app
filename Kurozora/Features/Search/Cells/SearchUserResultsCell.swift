//
//  SearchUserResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class SearchUserResultsCell: SearchBaseResultsCell {
	// MARK: - Properties
	var userProfile: UserProfile? = nil {
		didSet {
			if userProfile != nil {
				configureCell()
			}
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let userProfile = userProfile else { return }

		primaryLabel.text = userProfile.username

		// Configure follow status
		updateFollowStatusLabel()

		// Configure profile image
		if let profileImage = userProfile.profileImage, !profileImage.isEmpty {
			let profileImageUrl = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImageUrl!)
			searchImageView.kf.indicatorType = .activity
			searchImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_profile_image"), options: [.transition(.fade(0.2))])
		} else {
			searchImageView.image = #imageLiteral(resourceName: "default_profile_image")
		}

		// Configure follow button
		if userProfile.id == User.currentID {
			actionButton?.isHidden = true
		} else {
			if userProfile.following ?? false {
				actionButton?.setTitle("✓ Following", for: .normal)
			} else {
				actionButton?.setTitle("＋ Follow", for: .normal)
			}

			actionButton?.isHidden = false
		}
	}

	/// Updates the (`secondaryLabel`) follow status label.
	fileprivate func updateFollowStatusLabel() {
		guard let userProfile = userProfile else { return }

		if let followerCount = userProfile.followerCount {
			var secondaryLabelText = userProfile.id == User.currentID ? "You, followed by you!" : "Be the first to follow!"

			switch followerCount {
			case 0: break
			case 1:
				if userProfile.id == User.currentID {
					secondaryLabelText = "Followed by you... and one fan!"
				} else {
					secondaryLabelText = userProfile.following ?? false ? "Followed by you." :  "Followed by one user."
				}
			case 2...999:
				if userProfile.id == User.currentID {
					secondaryLabelText = "Followed by you and \(followerCount) fans."
				} else {
					secondaryLabelText = userProfile.following ?? false ? "Followed by you and (\(followerCount) users." :  "Followed by \(followerCount) users."
				}
			default:
				if userProfile.id == User.currentID {
					secondaryLabelText = "Followed by \(followerCount.kFormatted) fans."
				} else {
					secondaryLabelText = userProfile.following ?? false ? "Followed by you and (\((followerCount - 1).kFormatted)) users." : "Followed by \(followerCount.kFormatted) users."
				}
			}

			secondaryLabel.text = secondaryLabelText
		}

	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		super.actionButtonPressed(sender)

		WorkflowController.shared.isSignedIn {
			let shouldFollow = self.userProfile?.following ?? false ? 0 : 1

			KService.shared.follow(shouldFollow, user: self.userProfile?.id) { (success) in
				if success {
					if shouldFollow == 0 {
						sender.setTitle("＋ Follow", for: .normal)
						self.userProfile?.following = false
						self.userProfile?.followerCount = (self.userProfile?.followerCount ?? 1) - 1
					} else {
						sender.setTitle("✓ Following", for: .normal)
						self.userProfile?.following = true
						self.userProfile?.followerCount = (self.userProfile?.followerCount ?? 0) + 1
					}

					self.updateFollowStatusLabel()
				}
			}
		}
	}
}