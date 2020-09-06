//
//  FeedMessageReShareCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class FeedMessageReShareCell: FeedMessageCell {
	// MARK: - IBOutlets
	@IBOutlet weak var opProfileImageView: ProfileImageView!
	@IBOutlet weak var opUsernameLabel: KLabel!
	@IBOutlet weak var opMessageTextView: KTextView!
	@IBOutlet weak var opDateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var opView: UIView?

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let opMessage = self.feedMessage.relationships.messages?.data.first else { return }
		self.opDateTimeLabel.text = opMessage.attributes.createdAt.timeAgo
		self.opMessageTextView.text = opMessage.attributes.body

		if let opUser = opMessage.relationships.users.data.first {
			self.opProfileImageView.image = opUser.attributes.profileImage
			self.opUsernameLabel.text = opUser.attributes.username

			// Attach gestures
			self.configureProfilePageGesture(for: self.opProfileImageView)
			self.configureProfilePageGesture(for: self.opUsernameLabel)
		}

		if let opView = self.opView, opView.gestureRecognizers.isNilOrEmpty {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOPMessage(_:)))
			self.opView?.addGestureRecognizer(tapGestureRecognizer)
		}
	}
}
