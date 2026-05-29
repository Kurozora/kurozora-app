//
//  UserLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A delegate that responds to interactions inside a ``UserLockupCollectionViewCell``.
protocol UserLockupCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate that the user tapped the follow button.
	///
	/// - Parameters:
	///    - cell: The cell whose follow button was tapped.
	///    - button: The button that was tapped.
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton)

	/// Tells the delegate that the user tapped the block-toggle button on a row in the blocked-users list.
	///
	/// - Parameters:
	///    - cell: The cell whose block-toggle button was tapped.
	///    - button: The button that was tapped.
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressBlockToggle button: UIButton)
}

extension UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressBlockToggle button: UIButton) {}
}

class UserLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var rankLabel: KLabel!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var followStatusLabel: KSecondaryLabel!
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var borderView: BorderView!
	@IBOutlet weak var followButton: KTintedButton!

	// MARK: - Properties
	weak var delegate: UserLockupCollectionViewCellDelegate?

	/// When `true`, the trailing button toggles block state instead of follow state.
	private var isInBlockedMode: Bool = false

	// MARK: - View Lifecycle
	override func awakeFromNib() {
		super.awakeFromNib()

		self.profileImageView.layer.borderWidth = 0
		self.borderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.borderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.setRankVisible(false, rank: nil)

		self.followStatusLabel.isHidden = true
		self.followButton.isHidden = false
		self.followButton.isUserInteractionEnabled = true
		self.isInBlockedMode = false
	}

	// MARK: - Configuration
	/// Configures the cell for a follow/followers list row.
	///
	/// - Parameter user: The user object used to configure the cell.
	func configure(using user: User?) {
		guard let user = user else {
			self.showSkeleton()
			return
		}

		self.hideSkeleton()
		self.setRankVisible(false, rank: nil)

		self.primaryLabel.text = user.attributes.username
		self.updateFollowStatusLabel(for: user)

		user.attributes.profileImage(imageView: self.profileImageView)

		self.updateFollowButton(using: user.attributes.followStatus)
	}

	/// Configures the cell for a mention-autocomplete row.
	///
	/// - Parameter user: The user object used to configure the cell.
	func configureForMention(using user: User?) {
		guard let user = user else {
			self.showSkeleton()
			return
		}

		self.hideSkeleton()
		self.setRankVisible(false, rank: nil)

		self.primaryLabel.text = user.attributes.username
		self.secondaryLabel.text = "@\(user.attributes.slug)"

		user.attributes.profileImage(imageView: self.profileImageView)

		UIView.performWithoutAnimation {
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}

		switch user.attributes.followStatus {
		case .followed:
			self.followStatusLabel.isHidden = false

			let textColor = KThemePicker.subTextColor.colorValue
			let attachment = NSTextAttachment()
			attachment.image = UIImage(systemName: "person.fill")?.withTintColor(textColor, renderingMode: .alwaysOriginal)

			let attributedString = NSMutableAttributedString(attachment: attachment)
			attributedString.append(NSAttributedString(string: " \(L10n.userMentionFollowingBadge)", attributes: [
				.foregroundColor: textColor,
				.font: UIFont.preferredFont(forTextStyle: .caption1)
			]))

			self.followStatusLabel.attributedText = attributedString
		case .notFollowed, .disabled:
			self.followStatusLabel.isHidden = true
		}
	}

	/// Configures the cell for a reputation-leaderboard row.
	///
	/// - Parameters:
	///    - user: The user to display.
	///    - rank: The user's 1-based rank in the leaderboard.
	func configureForLeaderboard(using user: User?, rank: Int) {
		guard let user = user else {
			self.showSkeleton()
			return
		}

		self.hideSkeleton()
		self.setRankVisible(true, rank: rank)

		self.primaryLabel.text = user.attributes.username
		self.secondaryLabel.text = user.attributes.reputationCount.kkFormatted(precision: 0)

		user.attributes.profileImage(imageView: self.profileImageView)

		self.followStatusLabel.isHidden = true

		UIView.performWithoutAnimation {
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	/// Configures the cell for a row in the blocked-users list.
	///
	/// - Parameter user: The user object used to configure the cell.
	func configureForBlocked(using user: User?) {
		guard let user = user else {
			self.showSkeleton()
			return
		}

		self.hideSkeleton()
		self.setRankVisible(false, rank: nil)
		self.isInBlockedMode = true

		self.primaryLabel.text = user.attributes.username
		self.secondaryLabel.text = "@\(user.attributes.slug)"

		user.attributes.profileImage(imageView: self.profileImageView)

		self.followStatusLabel.isHidden = true
		self.updateBlockButton(isBlocked: user.attributes.blockStatus == .blocked)
	}

	/// Updates the trailing button to reflect the current block state when the cell is in blocked-list mode.
	///
	/// - Parameter isBlocked: `true` if the user is currently blocked.
	func updateBlockButton(isBlocked: Bool) {
		self.followButton.setTitle(isBlocked ? L10n.blocked : L10n.block, for: .normal)
		self.followButton.isHidden = false
		self.followButton.isUserInteractionEnabled = true
	}

	/// Updates the follow button's title and visibility for the given follow status.
	///
	/// - Parameter followStatus: The user's current follow status.
	func updateFollowButton(using followStatus: FollowStatus) {
		switch followStatus {
		case .followed:
			self.followButton.setTitle(L10n.followingButton, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.followButton.setTitle(L10n.followButton, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle(L10n.followButton, for: .normal)
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	// MARK: - Private
	/// Shows or hides the rank label.
	///
	/// - Parameters:
	///    - visible: `true` to show the rank label, `false` to hide it.
	///    - rank: The rank value to display when `visible` is `true`. Ignored otherwise.
	private func setRankVisible(_ visible: Bool, rank: Int?) {
		if visible, let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}
	}

	/// Composes a sentence describing the follower count and writes it to ``secondaryLabel``.
	///
	/// - Parameter user: The user whose follower count is being summarized.
	private func updateFollowStatusLabel(for user: User) {
		guard let userID = User.current?.id else {
			self.secondaryLabel.text = ""
			return
		}

		let isCurrentUser = user.id == userID
		let followerCount = user.attributes.followerCount
		let isFollowing = user.attributes.followStatus == .followed
		var secondaryLabelText = isCurrentUser ? L10n.userFollowersSelfNone : L10n.userFollowersBeFirst

		switch followerCount {
		case 0:
			break
		case 1:
			if isCurrentUser {
				secondaryLabelText = L10n.userFollowersSelfOne
			} else {
				secondaryLabelText = isFollowing ? L10n.userFollowedByYouOnly : L10n.userFollowedByOneUser
			}
		case 2 ... 999:
			if isCurrentUser {
				secondaryLabelText = L10n.userFollowersSelfSmall("\(followerCount)")
			} else {
				secondaryLabelText = isFollowing
					? L10n.userFollowedByYouAndOthers("\(followerCount)")
					: L10n.userFollowedByOthers("\(followerCount)")
			}
		default:
			if isCurrentUser {
				secondaryLabelText = L10n.userFollowersSelfLarge(followerCount.kkFormatted(precision: 0))
			} else {
				secondaryLabelText = isFollowing
					? L10n.userFollowedByYouAndOthers((followerCount - 1).kkFormatted(precision: 0))
					: L10n.userFollowedByOthers(followerCount.kkFormatted(precision: 0))
			}
		}

		self.secondaryLabel.text = secondaryLabelText
	}

	// MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		if self.isInBlockedMode {
			self.delegate?.userLockupCollectionViewCell(self, didPressBlockToggle: sender)
		} else {
			self.delegate?.userLockupCollectionViewCell(self, didPressFollow: sender)
		}
	}
}
