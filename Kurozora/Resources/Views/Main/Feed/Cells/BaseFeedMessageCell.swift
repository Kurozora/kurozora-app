//
//  BaseFeedMessageCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import LinkPresentation

class GIFView: UIView {
	// MARK: - Properties
	let gifURL: URL

	// MARK: - Views
	let gifImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.layerCornerRadius = 8
		return imageView
	}()

	// MARK: - Initializers
	init(url: URL) {
		self.gifURL = url
		super.init(frame: .zero)
		self.configureLayout()
		self.configureGIF()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) is not supported. Use init(url: URL) instead.")
	}

	// MARK: - Functions
	fileprivate func configureGIF() {
		self.gifImageView.kf.setImage(with: self.gifURL)
	}

	fileprivate func configureLayout() {
		self.addSubview(self.gifImageView)

		NSLayoutConstraint.activate([
			self.gifImageView.topAnchor.constraint(equalTo: self.topAnchor),
			self.gifImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.gifImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.gifImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		// Update aspect ratio constraint based on image size
		if let imageSize = self.gifImageView.image?.size {
			let aspectRatio = imageSize.width / imageSize.height
			let aspectRatioConstraint = self.gifImageView.widthAnchor.constraint(equalTo: self.gifImageView.heightAnchor, multiplier: aspectRatio)
			aspectRatioConstraint.priority = .required - 1
			aspectRatioConstraint.isActive = true
		}
	}
}

class BaseFeedMessageCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var warningTranscriptLabel: UILabel?
	@IBOutlet weak var warningVisualEffectView: KVisualEffectView?

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet weak var dateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var postTextView: KTextView!
	@IBOutlet weak var heartButton: CellActionButton!
	@IBOutlet weak var commentButton: CellActionButton!
	@IBOutlet weak var shareButton: CellActionButton!
	@IBOutlet weak var moreButton: CellActionButton!
	@IBOutlet weak var richLinkStackView: UIStackView?

	// MARK: - Properties
	weak var delegate: BaseFeedMessageCellDelegate?
	var warningIsHidden: Bool = false
	var liveReplyEnabled = false
	var liveReShareEnabled = false

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.warningIsHidden = false
		self.richLinkStackView?.arrangedSubviews.forEach { subview in
			self.richLinkStackView?.removeArrangedSubview(subview)
			subview.removeFromSuperview()
		}
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
			self.profileBadgeStackView.delegate = self
			self.profileBadgeStackView.configure(for: user)
		}

		// Configure body
		if let url = feedMessage.attributes.content.extractURLs().last {
			if let metadata = RichLink.cachedMetadata(for: url) {
				self.displayMetadata(metadata)
				self.configurePostTextView(for: feedMessage, byRemovingURL: url)
			} else {
				Task(priority: .background) {
					if let metadata = await RichLink.fetchMetadata(for: url) {
						DispatchQueue.main.async {
							self.displayMetadata(metadata)
							self.configurePostTextView(for: feedMessage, byRemovingURL: url)
						}
					}
				}
			}
		} else {
			self.postTextView.setAttributedText(feedMessage.attributes.contentMarkdown.markdownAttributedString())
		}
		self.postTextView.delegate = self

		// Configure date time
		self.dateTimeLabel.text = feedMessage.attributes.createdAt.relativeToNow

		// Configure metrics
		var heartsCount: Int? = feedMessage.attributes.metrics.heartCount
		heartsCount = heartsCount == 0 ? nil : heartsCount
		self.heartButton.setTitle(heartsCount?.kkFormatted, for: .normal)

		var replyCount: Int? = feedMessage.attributes.metrics.replyCount
		replyCount = replyCount == 0 ? nil : replyCount
		self.commentButton.setTitle(replyCount?.kkFormatted, for: .normal)

		var reShareCount: Int? = feedMessage.attributes.metrics.reShareCount
		reShareCount = reShareCount == 0 ? nil : reShareCount
		self.shareButton.setTitle(reShareCount?.kkFormatted, for: .normal)

		// Configure more button
		self.moreButton.showsMenuAsPrimaryAction = true

		// Configure re-share button
		self.configureReShareButton(for: feedMessage)

		// Configure warning messages
		self.configureWarnings(for: feedMessage)
	}

	fileprivate func configurePostTextView(for feedMessage: FeedMessage, byRemovingURL url: URL) {
		let contentMarkdown = self.removeURLFromEndOfText(url: url, text: feedMessage.attributes.contentMarkdown)
		self.postTextView.setAttributedText(contentMarkdown.markdownAttributedString())
	}

	fileprivate func displayMetadata(_ metadata: LPLinkMetadata) {
		if let gifURL = metadata.url, gifURL.pathExtension.lowercased() == "gif" {
			let gifView = GIFView(url: gifURL)
			self.richLinkStackView?.addArrangedSubview(gifView)
		} else {
			let metadataView = KLinkView(metadata: metadata)
			self.richLinkStackView?.addArrangedSubview(metadataView)
		}
	}

	fileprivate func removeURLFromEndOfText(url: URL, text: String) -> String {
		let urlString = url.absoluteString

		// Remove the URL from the end of the full text
		if text.hasSuffix(urlString) {
			return String(text.dropLast(urlString.count))
		}

		return text
	}

	/// Configures the re-share button.
	fileprivate func configureReShareButton(for feedMessage: FeedMessage) {
		if feedMessage.attributes.isReShared {
			self.shareButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
			self.shareButton.theme_tintColor = KThemePicker.tintColor.rawValue
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
			self.heartButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
			self.heartButton.theme_tintColor = KThemePicker.tintColor.rawValue
		} else {
			self.heartButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.heartButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
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

// MARK: - ProfileBadgeStackViewDelegate
extension BaseFeedMessageCell: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) {
		self.delegate?.baseFeedMessageCell(self, didPressProfileBadge: button, for: profileBadge)
	}
}
