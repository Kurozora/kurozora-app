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
	var userProfile: UserProfile? = nil {
		didSet {
			if userProfile != nil {
				configureCell()
			}
		}
	}
	var searchImageViewSize: CGSize = .zero

	override func layoutSubviews() {
		super.layoutSubviews()

		if searchImageView.size != searchImageViewSize {
			searchImageViewSize = searchImageView.size
			searchImageView.cornerRadius = searchImageView.height / 2
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
		if let profileImageURL = userProfile.profileImageURL {
			if let usernameInitials = userProfile.username?.initials {
				let placeholderImage = usernameInitials.toImage(withFrameSize: searchImageView.frame, placeholder: R.image.placeholders.userProfile()!)
				searchImageView.setImage(with: profileImageURL, placeholder: placeholderImage)
			}
		}

		// Configure follow button
		if userProfile.id == User.current?.id {
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

		if let followerCount = userProfile.followerCount, let userID = User.current?.id {
			var secondaryLabelText = userProfile.id == userID ? "You, followed by you!" : "Be the first to follow!"

			switch followerCount {
			case 0: break
			case 1:
				if userProfile.id == userID {
					secondaryLabelText = "Followed by you... and one fan!"
				} else {
					secondaryLabelText = userProfile.following ?? false ? "Followed by you." :  "Followed by one user."
				}
			case 2...999:
				if userProfile.id == userID {
					secondaryLabelText = "Followed by you and \(followerCount) fans."
				} else {
					secondaryLabelText = userProfile.following ?? false ? "Followed by you and (\(followerCount) users." :  "Followed by \(followerCount) users."
				}
			default:
				if userProfile.id == userID {
					secondaryLabelText = "Followed by \(followerCount.kFormatted) fans."
				} else {
					secondaryLabelText = userProfile.following ?? false ? "Followed by you and (\((followerCount - 1).kFormatted)) users." : "Followed by \(followerCount.kFormatted) users."
				}
			}

			secondaryLabel?.text = secondaryLabelText
		}
	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		super.actionButtonPressed(sender)

		WorkflowController.shared.isSignedIn {
			let followStatus: FollowStatus = self.userProfile?.following ?? false ? .unfollow : .follow

			if let userID = self.userProfile?.id {
				KService.updateFollowStatus(userID, withFollowStatus: followStatus) { result in
					switch result {
					case .success:
						if followStatus == .unfollow {
							sender.setTitle("＋ Follow", for: .normal)
							self.userProfile?.following = false
							self.userProfile?.followerCount = (self.userProfile?.followerCount ?? 1) - 1
						} else {
							sender.setTitle("✓ Following", for: .normal)
							self.userProfile?.following = true
							self.userProfile?.followerCount = (self.userProfile?.followerCount ?? 0) + 1
						}

						self.updateFollowStatusLabel()
					case .failure:
						break
					}
				}
			}
		}
	}
}
