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

	@IBOutlet weak var verificationImageView: UIImageView!
	@IBOutlet weak var proBadgeButton: UIButton!

	// MARK: - Properties
	weak var delegate: BaseFeedMessageCellDelegate?
	var warningIsHidden: Bool = false
	var liveReplyEnabled = false
	var liveReShareEnabled = false

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.warningIsHidden = false
	}

	// MARK: - Functions
	func configureCell(using feedMessage: FeedMessage?) {
		guard !self.warningIsHidden else {
			self.hideSkeleton()
			return
		}
		guard let feedMessage = feedMessage else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure heart status for feed message.
		self.updateHeartStatus(for: feedMessage)

		// Configure poster details
		if let user = feedMessage.relationships.users.data.first {
			self.usernameLabel.text = user.attributes.username
			user.attributes.profileImage(imageView: self.profileImageView)

			// Attach gestures
			self.configureProfilePageGesture(for: self.usernameLabel)
			self.configureProfilePageGesture(for: self.profileImageView)

			// Badges
			self.verificationImageView.isHidden = !user.attributes.isVerified
			let proTitle = user.attributes.isSubscribed ? Trans.proPlus : Trans.pro
			self.proBadgeButton.setTitle(proTitle.uppercased(), for: .normal)
			self.proBadgeButton.isHidden = !user.attributes.isPro || !user.attributes.isSubscribed
		}

		// Configure body
		self.postTextView.setAttributedText(feedMessage.attributes.contentMarkdown.markdownAttributedString())
		self.postTextView.delegate = self

		// Configure date time
		self.dateTimeLabel.text = feedMessage.attributes.createdAt.relativeToNow

		// Configure metrics
		let heartsCount = feedMessage.attributes.metrics.heartCount
		self.heartButton.setTitle(heartsCount.kkFormatted, for: .normal)

		let replyCount = feedMessage.attributes.metrics.replyCount
		self.commentButton.setTitle(replyCount.kkFormatted, for: .normal)

		let reShareCount = feedMessage.attributes.metrics.reShareCount
		self.shareButton.setTitle(reShareCount.kkFormatted, for: .normal)

		// Configure more button
		self.moreButton.showsMenuAsPrimaryAction = true

		// Configure re-share button
		self.configureReShareButton(for: feedMessage)

		// Configure warning messages
		self.configureWarnings(for: feedMessage)
	}

	/// Configures the re-share button.
	fileprivate func configureReShareButton(for feedMessage: FeedMessage) {
		if feedMessage.attributes.isReShared {
			shareButton.setTitleColor(.kGreen, for: .normal)
			shareButton.tintColor = .kGreen
		} else {
			self.shareButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.shareButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	/// Configures the warning messages.
	fileprivate func configureWarnings(for feedMessage: FeedMessage) {
		let isNSFW = feedMessage.attributes.isNSFW
		let isSpoiler = feedMessage.attributes.isSpoiler

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

	/// Adds a `UITapGestureRecognizer` which opens the profile image onto the given view.
	///
	/// - Parameter view: The view to which the tap gesture should be attached.
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
	fileprivate func updateHeartStatus(for feedMessage: FeedMessage) {
		if feedMessage.attributes.isHearted ?? false {
			self.heartButton.tintColor = .kLightRed
			self.heartButton.setTitleColor(.kLightRed, for: .normal)
		} else {
			self.heartButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.heartButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		}
	}

	fileprivate func getUserIdentity(username: String) async -> UserIdentity? {
		do {
			let userIdentityResponse = try await KService.searchUsers(for: username).value
			return userIdentityResponse.data.first
		} catch {
			print("-----", error.localizedDescription)
			return nil
		}
	}

	// MARK: - IBActions
	@objc func usernameLabelPressed(_ sender: AnyObject) {
		self.delegate?.baseFeedMessageCell(self, didPressUserName: sender)
	}

	@IBAction func heartButtonPressed(_ sender: UIButton) {
		self.delegate?.baseFeedMessageCell(self, didPressHeartButton: sender)
		sender.animateBounce()
	}

	@IBAction func commentButtonPressed(_ sender: UIButton) {
		self.delegate?.baseFeedMessageCell(self, didPressReplyButton: sender)
		sender.animateBounce()
	}

	@IBAction func reShareButtonPressed(_ sender: UIButton) {
		self.delegate?.baseFeedMessageCell(self, didPressReShareButton: sender)
		sender.animateBounce()
	}
}

// MARK: - UITextViewDelegate
extension BaseFeedMessageCell: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString.starts(with: "https://kurozora.app/profile") {
			Task { [weak self] in
				guard let self = self else { return }
				let username = URL.lastPathComponent
				guard let userIdentity = await self.getUserIdentity(username: username) else { return }
				let deeplink = URL.absoluteString
					.replacingOccurrences(of: "https://kurozora.app/", with: "kurozora://")
					.replacingOccurrences(of: username, with: "\(userIdentity.id)")
					.url

				UIApplication.shared.kOpen(nil, deepLink: deeplink)
			}

			return false
		}

		return true
	}
}
