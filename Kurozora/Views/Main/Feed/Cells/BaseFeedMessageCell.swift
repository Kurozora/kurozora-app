//
//  BaseFeedMessageCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView

class BaseFeedMessageCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var warningTranscriptLabel: UILabel?
	@IBOutlet weak var warningVisualEffectView: KVisualEffectView?

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var dateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var postTextView: KTextView!
	@IBOutlet weak var heartButton: CellActionButton!
	@IBOutlet weak var commentButton: CellActionButton!
	@IBOutlet weak var shareButton: CellActionButton!
	@IBOutlet weak var moreButton: CellActionButton!
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	var warningIsHidden: Bool = false
	var liveReplyEnabled = false
	var liveReShareEnabled = false
	var feedMessage: FeedMessage! {
		didSet {
			if !self.warningIsHidden {
				configureCell()
			}
		}
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.warningIsHidden = false
	}

	// MARK: - Functions
	override func configureCell() {
		// Configure heart status for feed message.
		self.updateHeartStatus()

		// Configure poster details
		if let user = self.feedMessage.relationships.users.data.first {
			self.usernameLabel.text = user.attributes.username
			self.profileImageView.image = user.attributes.profileImage

			// Attach gestures
			self.configureProfilePageGesture(for: self.usernameLabel)
			self.configureProfilePageGesture(for: self.profileImageView)
		}

		// Configure body
		postTextView.text = self.feedMessage.attributes.body

		// Configure date time
		dateTimeLabel.text = self.feedMessage.attributes.createdAt.timeAgo

		// Configure metrics
		let heartsCount = self.feedMessage.attributes.metrics.heartCount
		heartButton.setTitle(heartsCount.kkFormatted, for: .normal)

		let replyCount = self.feedMessage.attributes.metrics.replyCount
		commentButton.setTitle(replyCount.kkFormatted, for: .normal)

		let reShareCount = self.feedMessage.attributes.metrics.reShareCount
		shareButton.setTitle(reShareCount.kkFormatted, for: .normal)

		/// Configure re-share button
		self.configureReShareButton()

		// Configure warning messages
		self.configureWarnings()

		// Add gesture to cell
		if self.gestureRecognizers.isNilOrEmpty {
			let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCellOptions(_:)))
			addGestureRecognizer(longPressGesture)
			isUserInteractionEnabled = true
		}
	}

	/// Configures the re-share button.
	fileprivate func configureReShareButton() {
		if self.feedMessage.attributes.isReShared {
			shareButton.setTitleColor(.kGreen, for: .normal)
			shareButton.tintColor = .kGreen
		} else {
			self.shareButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.shareButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	/// Configures the warning messages.
	fileprivate func configureWarnings() {
		let isNSFW = self.feedMessage.attributes.isNSFW
		let isSpoiler = self.feedMessage.attributes.isSpoiler

		// Configure warning visual effect view
		if isNSFW || isSpoiler {
			self.warningVisualEffectView?.isHidden = false
		} else {
			self.warningTranscriptLabel?.text = ""
			self.warningVisualEffectView?.isHidden = true
			return
		}

		// Configure warning transcript
		if isNSFW && isSpoiler {
			self.warningTranscriptLabel?.text = "This message is NSFW and contains spoilers - tap to view"
		} else if isNSFW {
			self.warningTranscriptLabel?.text = "This message is NSFW - tap to view"
		} else if isSpoiler {
			self.warningTranscriptLabel?.text = "The message contains spoilers - tap to view"
		}

		// Add gesture recognizer to hide visual effect
		if let warningVisualEffectView = self.warningVisualEffectView, warningVisualEffectView.gestureRecognizers.isNilOrEmpty {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideWarning(_:)))
			self.warningVisualEffectView?.addGestureRecognizer(tapGestureRecognizer)
		}
	}

	/**
		Adds a `UITapGestureRecognizer` which opens the profile image onto the given view.

		- Parameter view: The view to which the tap gesture should be attached.
	*/
	func configureProfilePageGesture(for view: UIView) {
		if view.gestureRecognizers.isNilOrEmpty {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			view.addGestureRecognizer(gestureRecognizer)
			view.isUserInteractionEnabled = true
		}
	}

	/// Shows the relevant options for the selected message.
	@objc fileprivate func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
		showActionList()
	}

	/// Segues to message details.
	@objc func showOPMessage(_ gestureRecognizer: UITapGestureRecognizer) {
		guard let opMessage = self.feedMessage.relationships.messages?.data.first else { return }
		self.parentViewController?.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: opMessage.id)
	}

	/// Hides warnings.
	@objc fileprivate func hideWarning(_ gestureRecognizer: UITapGestureRecognizer) {
		self.warningIsHidden = true
		self.warningVisualEffectView?.isHidden = true
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
			self.heartButton.setTitleColor(.kLightRed, for: .normal)
		} else {
			self.heartButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.heartButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
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
					self.heartButton.setTitle(heartsCount.kkFormatted, for: .normal)
				case .failure: break
				}
			}
		}
	}

	fileprivate func replyMessage() {
		WorkflowController.shared.isSignedIn {
			if let kfmReplyTextEditorViewController = R.storyboard.textEditor.kfmReplyTextEditorViewController() {
				kfmReplyTextEditorViewController.delegate = self.parentViewController as? KFeedMessageTextEditorViewDelegate
				kfmReplyTextEditorViewController.segueToOPFeedDetails = !self.liveReplyEnabled
				kfmReplyTextEditorViewController.opFeedMessage = self.feedMessage

				let kurozoraNavigationController = KNavigationController.init(rootViewController: kfmReplyTextEditorViewController)
				kurozoraNavigationController.navigationBar.prefersLargeTitles = false
				self.parentViewController?.present(kurozoraNavigationController)
			}
		}
	}

	/// Re-share the message on the feed.
	fileprivate func reShareMessage() {
		WorkflowController.shared.isSignedIn {
			if !self.feedMessage.attributes.isReShared {
				if let kfmReShareTextEditorViewController = R.storyboard.textEditor.kfmReShareTextEditorViewController() {
					kfmReShareTextEditorViewController.delegate = self.parentViewController as? KFeedMessageTextEditorViewDelegate
					kfmReShareTextEditorViewController.segueToOPFeedDetails = !self.liveReShareEnabled
					kfmReShareTextEditorViewController.opFeedMessage = self.feedMessage

					let kurozoraNavigationController = KNavigationController.init(rootViewController: kfmReShareTextEditorViewController)
					kurozoraNavigationController.navigationBar.prefersLargeTitles = false
					self.parentViewController?.present(kurozoraNavigationController)
				}
			} else {
				SCLAlertView().showNotice("Can't re-share", subTitle: "You are not allowed to re-share a message more than once.")
			}
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

	@IBAction func commentButtonPressed(_ sender: UIButton) {
		self.replyMessage()
		sender.animateBounce()
	}

	@IBAction func segueToMessageDetails(_ sender: UIButton) {
		sender.animateBounce()
		self.parentViewController?.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: self.feedMessage.id)
	}

	@IBAction func reShareButtonPressed(_ sender: UIButton) {
		self.reShareMessage()
		sender.animateBounce()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		showActionList()
	}
}
