//
//  BaseFeedMessageCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BaseFeedMessageCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			usernameLabel.addGestureRecognizer(gestureRecognizer)
			usernameLabel.isUserInteractionEnabled = true
		}
	}
	@IBOutlet weak var dateTimeLabel: UILabel! {
		didSet {
			dateTimeLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var postTextView: UITextView! {
		didSet {
			postTextView.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			postTextView.text = "Feed post..."
		}
	}
	@IBOutlet weak var heartButton: UIButton! {
		didSet {
			heartButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			heartButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var commentButton: UIButton! {
		didSet {
			commentButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			commentButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var shareButton: UIButton! {
		didSet {
			shareButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			shareButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var moreButton: UIButton! {
		didSet {
			moreButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	var feedMessage: FeedMessage! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		// Configure heart status for feed message.
		self.updateHeartStatus()

		// Add gesture to cell
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
		addGestureRecognizer(longPressGesture)
		isUserInteractionEnabled = true
	}

	/// Shows the relevant options for the selected message.
	@objc func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
		showActionList()
	}

	/// Presents the profile view for the feed message poster.
	fileprivate func visitPosterProfilePage() {
		if let user = feedMessage.relationships.users.data.first {
			if let profileViewController = R.storyboard.profile.profileTableViewController() {
				profileViewController.userID = user.id
				profileViewController.dismissButtonIsEnabled = true

				let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)

				self.parentViewController?.present(kurozoraNavigationController)
			}
		}
	}

	/// Update the heart status of the message.
	fileprivate func updateHeartStatus() {
		if self.feedMessage.attributes.isHearted {
			self.heartButton.tintColor = .kLightRed
		} else {
			self.heartButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	/// Heart or un-heart the message.
	fileprivate func heartMessage() {
		WorkflowController.shared.isSignedIn {
			KService.heartMessage(self.feedMessage.id) { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success(let feedMessageHeart):
					self.feedMessage.attributes.update(heartStatus: feedMessageHeart.isHearted)
					self.updateHeartStatus()

					let heartsCount = self.feedMessage.attributes.metrics.heartCount
					self.heartButton.setTitle("\((heartsCount >= 1000) ? heartsCount.kFormatted : heartsCount.string)", for: .normal)
				case .failure: break
				}
			}
		}
	}

	/// Re-share the message on the feed.
	fileprivate func reShareMessage() {
		WorkflowController.shared.isSignedIn {

		}
	}

	/// Sends a report of the selected message to the mods.
	func reportMessage() {
		WorkflowController.shared.isSignedIn {
		}
	}

	/// Presents a share sheet to share the selected message.
	func shareMessage() {
		var shareText = "\"\(feedMessage.attributes.body)\""
		if let user = feedMessage.relationships.users.data.first {
			shareText += "-\(user.attributes.username)"
		}

		let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}
		self.parentViewController?.present(activityViewController, animated: true, completion: nil)
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Heart, re-share and reply actions
		// Username action
		if let user = feedMessage.relationships.users.data.first {
			let username = user.attributes.username
			let userAction = UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			})
			userAction.setValue(R.image.symbols.person_crop_circle_fill()!, forKey: "image")
			userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			alertController.addAction(userAction)
		}

		// Share feed message action
		let reShareAction = UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			self.shareMessage()
		})
		reShareAction.setValue(R.image.symbols.square_and_arrow_up_fill()!, forKey: "image")
		reShareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		alertController.addAction(reShareAction)

		// Report feed message action
		let reportAction = UIAlertAction.init(title: "Report", style: .destructive, handler: { (_) in
			self.reportMessage()
		})
		reportAction.setValue(R.image.symbols.exclamationmark_circle_fill()!, forKey: "image")
		reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		alertController.addAction(reportAction)

		alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = alertController.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}

		if (parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			parentViewController?.present(alertController, animated: true, completion: nil)
		}
	}

	// MARK: - IBActions
	@objc func usernameLabelPressed(sender: AnyObject) {
		self.visitPosterProfilePage()
	}

	@IBAction func heartButtonPressed(_ sender: UIButton) {
		self.heartMessage()
		sender.animateBounce()
	}

	@IBAction func reShareButtonPressed(_ sender: UIButton) {
		self.reShareMessage()
		sender.animateBounce()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		showActionList()
	}
}
