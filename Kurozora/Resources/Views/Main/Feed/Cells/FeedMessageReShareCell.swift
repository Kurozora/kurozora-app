//
//  FeedMessageReShareCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FeedMessageReShareCell: FeedMessageCell {
	// MARK: - IBOutlets
	@IBOutlet weak var opProfileImageView: ProfileImageView!
	@IBOutlet weak var opUsernameLabel: KLabel!
	@IBOutlet weak var opMessageTextView: KTextView!
	@IBOutlet weak var opDateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var opView: UIView?
	@IBOutlet weak var opVerificationImageView: UIImageView!
	@IBOutlet weak var opProBadgeButton: UIButton!

	// MARK: - Functions
	override func configureCell(using feedMessage: FeedMessage?) {
		super.configureCell(using: feedMessage)
		guard let feedMessage = feedMessage else {
			return
		}

		guard let opMessage = feedMessage.relationships.parent?.data.first else { return }
		self.opDateTimeLabel.text = opMessage.attributes.createdAt.relativeToNow
		self.opMessageTextView.setAttributedText(opMessage.attributes.contentMarkdown.markdownAttributedString())

		if let opUser = opMessage.relationships.users.data.first {
			opUser.attributes.profileImage(imageView: self.opProfileImageView)
			self.opUsernameLabel.text = opUser.attributes.username

			// Attach gestures
			self.configureOPProfilePageGesture(for: self.opProfileImageView)
			self.configureOPProfilePageGesture(for: self.opUsernameLabel)

			// Badges
			self.opVerificationImageView.isHidden = !opUser.attributes.isVerified
			self.opProBadgeButton.isHidden = !opUser.attributes.isPro || !opUser.attributes.isSubscribed
		}

		if let opView = self.opView, opView.gestureRecognizers.isNilOrEmpty {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOPMessage(_:)))
			self.opView?.addGestureRecognizer(tapGestureRecognizer)
		}
	}

	/// Adds a `UITapGestureRecognizer` which opens the profile image onto the given view.
	///
	/// - Parameter view: The view to which the tap gesture should be attached.
	fileprivate func configureOPProfilePageGesture(for view: UIView) {
		if view.gestureRecognizers.isNilOrEmpty {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(opUsernameLabelPressed(_:)))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			view.addGestureRecognizer(gestureRecognizer)
			view.isUserInteractionEnabled = true
		}
	}

	/// Segues to message details.
	@objc func showOPMessage(_ sender: AnyObject) {
		self.delegate?.feedMessageReShareCell(self, didPressOPMessage: sender)
	}

	/// Presents the profile view for the feed message poster.
	@objc fileprivate func opUsernameLabelPressed(_ sender: AnyObject) {
		self.delegate?.feedMessageReShareCell(self, didPressUserName: sender)
	}
}
