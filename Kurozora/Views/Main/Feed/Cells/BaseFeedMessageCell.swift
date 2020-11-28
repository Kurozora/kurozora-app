//
//  BaseFeedMessageCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol BaseFeedMessageCellDelegate: class {
	func heartMessage(_ cell: BaseFeedMessageCell)
	func replyToMessage(_ cell: BaseFeedMessageCell)
	func reShareMessage(_ cell: BaseFeedMessageCell)
	func visitOriginalPosterProfile(_ cell: BaseFeedMessageCell)
}

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

	// MARK: - Properties
	weak var delegate: BaseFeedMessageCellDelegate?
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

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.warningIsHidden = false
	}

	// MARK: - Functions
	/// The shared settings used to initialize the tab bar item content view.
	fileprivate func sharedInit() {
		self.separatorInset = UIEdgeInsets(horizontal: 15, vertical: 0)
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
	}

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
	fileprivate func configureProfilePageGesture(for view: UIView) {
		if view.gestureRecognizers.isNilOrEmpty {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(usernameLabelPressed(_:)))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			view.addGestureRecognizer(gestureRecognizer)
			view.isUserInteractionEnabled = true
		}
	}

	/// Hides warnings.
	@objc fileprivate func hideWarning(_ gestureRecognizer: UITapGestureRecognizer) {
		self.warningIsHidden = true
		self.warningVisualEffectView?.isHidden = true
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

	// MARK: - IBActions
	@objc func usernameLabelPressed(_ sender: AnyObject) {
		self.delegate?.visitOriginalPosterProfile(self)
	}

	@IBAction func heartButtonPressed(_ sender: UIButton) {
		self.delegate?.heartMessage(self)
		sender.animateBounce()
	}

	@IBAction func commentButtonPressed(_ sender: UIButton) {
		self.delegate?.replyToMessage(self)
		sender.animateBounce()
	}

	@IBAction func reShareButtonPressed(_ sender: UIButton) {
		self.delegate?.reShareMessage(self)
		sender.animateBounce()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		fatalError("More button action not implemented.")
	}
}
