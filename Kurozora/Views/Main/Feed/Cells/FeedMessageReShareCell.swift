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
		guard let opMessage = self.feedMessage.relationships.parent?.data.first else { return }
		self.opDateTimeLabel.text = opMessage.attributes.createdAt.relativeToNow
		self.opMessageTextView.text = opMessage.attributes.body

		if let opUser = opMessage.relationships.users.data.first {
			self.opProfileImageView.setImage(with: opUser.attributes.profile?.url ?? "", placeholder: opUser.attributes.placeholderImage)
			self.opUsernameLabel.text = opUser.attributes.username

			// Attach gestures
			self.configureOPProfilePageGesture(for: self.opProfileImageView)
			self.configureOPProfilePageGesture(for: self.opUsernameLabel)
		}

		if let opView = self.opView, opView.gestureRecognizers.isNilOrEmpty {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOPMessage(_:)))
			self.opView?.addGestureRecognizer(tapGestureRecognizer)
		}
	}

	/**
		Adds a `UITapGestureRecognizer` which opens the profile image onto the given view.

		- Parameter view: The view to which the tap gesture should be attached.
	*/
	fileprivate func configureOPProfilePageGesture(for view: UIView) {
		if view.gestureRecognizers.isNilOrEmpty {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(visitOPProfilePage(_:)))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			view.addGestureRecognizer(gestureRecognizer)
			view.isUserInteractionEnabled = true
		}
	}

	/// Segues to message details.
	@objc func showOPMessage(_ gestureRecognizer: UITapGestureRecognizer) {
		guard let opMessage = self.feedMessage.relationships.parent?.data.first else { return }
		self.parentViewController?.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: opMessage.id)
	}

	/// Presents the profile view for the feed message poster.
	@objc fileprivate func visitOPProfilePage(_ gestureRecognizer: UITapGestureRecognizer) {
		guard let opMessage = self.feedMessage.relationships.parent?.data.first else { return }
		if let opUser = opMessage.relationships.users.data.first {
			let profileTableViewController = ProfileTableViewController.`init`(with: opUser.id)
			profileTableViewController.dismissButtonIsEnabled = true

			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileTableViewController)
			self.parentViewController?.present(kurozoraNavigationController, animated: true)
		}
	}
}
