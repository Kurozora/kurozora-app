//
//  BaseFeedMessageCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import LinkPresentation
import UIKit

protocol BaseFeedMessageCellDelegate: AnyObject {
	// MARK: Feed Message Base
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton) async
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton) async
	func baseFeedMessageCellReShareMenu(_ cell: BaseFeedMessageCell) -> UIMenu?
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) async
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) async
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didUpdateContentLayout sender: AnyObject)
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMore sender: AnyObject)
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMoreOnOP sender: AnyObject)
	func baseFeedMessageCellDidTapAttribution(_ cell: BaseFeedMessageCell)

	// MARK: Feed Message ReShare
	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async
	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async
}

extension BaseFeedMessageCellDelegate {
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMore sender: AnyObject) {}
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMoreOnOP sender: AnyObject) {}
	func baseFeedMessageCellReShareMenu(_ cell: BaseFeedMessageCell) -> UIMenu? { nil }
	func baseFeedMessageCellDidTapAttribution(_ cell: BaseFeedMessageCell) {}
}

class BaseFeedMessageCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var warningTranscriptLabel: UILabel?
	@IBOutlet weak var warningVisualEffectView: KVisualEffectView?

	@IBOutlet weak var statusStackView: UIStackView!
	@IBOutlet weak var statusImageView: UIImageView!
	@IBOutlet weak var statusLabel: KSecondaryLabel!

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var profileBorderView: BorderView!
	@IBOutlet weak var displayNameLabel: KLabel!
	@IBOutlet weak var usernameLabel: KSecondaryLabel!
	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet weak var dateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var postTextViewPlaceholder: UIView!
	@IBOutlet weak var postTextViewContainer: UIView!
	@IBOutlet weak var heartButton: CellActionButton!
	@IBOutlet weak var commentButton: CellActionButton!
	@IBOutlet weak var shareButton: CellActionButton!
	@IBOutlet weak var moreButton: CellActionButton!
	@IBOutlet weak var richLinkStackView: UIStackView!

	// MARK: - Views
	private(set) var postTextView: KSelectableTextView!

	// MARK: - Properties
	weak var delegate: BaseFeedMessageCellDelegate?
	var warningIsHidden: Bool = false
	var liveReplyEnabled = false
	var liveReShareEnabled = false
	var isExpanded: Bool = false
	private var richLinkTask: Task<Void, Never>?
	private weak var richLinkPlaceholder: UIView?

	/// The maximum number of body lines shown before the cell collapses behind a `Show more` affordance.
	static let bodyLineLimit: Int = 8

	/// The action identifier dispatched when the main body's `Show more` glyph is tapped.
	static let expandMessageActionID: String = "kk-expand-message"

	/// The action identifier dispatched when the re-shared body's `Show more` glyph is tapped.
	static let expandOPMessageActionID: String = "kk-expand-op-message"

	/// Cached body text view widths keyed by concrete cell class.
	fileprivate static var cachedBodyWidths: [ObjectIdentifier: CGFloat] = [:]

	/// The cached body text view width for this cell's concrete class.
	fileprivate var cachedBodyWidth: CGFloat {
		return Self.cachedBodyWidths[ObjectIdentifier(type(of: self))] ?? 0
	}

	/// Records the body text view width observed for this cell's concrete class.
	fileprivate func recordCachedBodyWidth(_ width: CGFloat) {
		Self.cachedBodyWidths[ObjectIdentifier(type(of: self))] = width
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.configurePostTextView()

		self.profileImageView.layer.borderWidth = 0
		self.profileBorderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.warningIsHidden = false
		self.statusStackView.isHidden = true
		self.postTextViewContainer?.isHidden = false
		self.isExpanded = false

		self.richLinkTask?.cancel()
		self.richLinkTask = nil
		self.richLinkPlaceholder = nil
		self.richLinkStackView.arrangedSubviews.forEach { subview in
			if subview != self.postTextViewContainer {
				self.richLinkStackView.removeArrangedSubview(subview)
				subview.removeFromSuperview()
			}
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.profileBorderView.cornerRadius = self.profileImageView.bounds.height / 2.0

		let width = self.postTextView.bounds.width
		if width > 0, width != self.cachedBodyWidth {
			self.recordCachedBodyWidth(width)
		}
	}

	/// Sets the body text on `postTextView`, truncating when `isExpanded` is `false`.
	fileprivate func applyBodyText(_ attributed: NSAttributedString?, isExpanded: Bool) {
		guard let attributed else {
			self.postTextView.setAttributedText(nil)
			return
		}

		let final = isExpanded ? attributed : Self.truncatedBody(attributed, cachedWidth: self.cachedBodyWidth, fallbackHostBounds: self.bounds.width, actionID: Self.expandMessageActionID, font: self.postTextView.font)
		self.postTextView.setAttributedText(final)
	}

	/// Returns `attributed` truncated to `bodyLineLimit` lines with a trailing `Show more` suffix.
	///
	/// - Parameters:
	///   - attributed: The body to truncate.
	///   - cachedWidth: The previously recorded text view width, or `0` if none.
	///   - fallbackHostBounds: The host cell's current width, used when `cachedWidth` is `0`.
	///   - actionID: The suffix's `.kkAction` value, dispatched on tap.
	///   - font: The body font.
	///
	/// - Returns: The truncated string, or `attributed` unchanged when truncation isn't required.
	static func truncatedBody(_ attributed: NSAttributedString, cachedWidth: CGFloat, fallbackHostBounds: CGFloat, actionID: String, font sourceFont: UIFont?) -> NSAttributedString {
		return NSAttributedString.kkTruncatedBody(attributed, lineLimit: bodyLineLimit, cachedWidth: cachedWidth, fallbackHostBounds: fallbackHostBounds, actionID: actionID, font: sourceFont)
	}

	// MARK: - Functions
	override func sharedInit() {
		self.separatorInset = .zero
		self.contentView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}

	fileprivate func configurePostTextView() {
		let textView = KSelectableTextView()
		textView.isScrollEnabled = false
		textView.bounces = false

		self.postTextViewPlaceholder.addSubview(textView)
		textView.fillToSuperview()

		self.postTextView = textView
	}

	func configureCell(using feedMessage: FeedMessage?, isOnProfile: Bool, isExpanded: Bool = false, attributedTo: User? = nil) {
		self.isExpanded = isExpanded

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

		// Configure status image
		self.statusImageView.theme_tintColor = KThemePicker.subTextColor.rawValue

		// Configure status label
		if let resharer = attributedTo {
			let isCurrentUser = resharer.id == User.current?.id

			self.statusImageView.image = UIImage(systemName: "arrow.2.squarepath")
			self.statusLabel.text = isCurrentUser ? L10n.youReShared : L10n.reSharedBy("@\(resharer.attributes.slug)")
			self.statusStackView.isHidden = false
			self.configureAttributionTapGesture()
		} else if isOnProfile, feedMessage.attributes.isPinned {
			self.statusImageView.image = UIImage(systemName: "pin.fill")
			self.statusLabel.text = L10n.messagePinned
			self.statusStackView.isHidden = false
		} else {
			self.statusStackView.isHidden = true
		}

		// Configure poster details
		if let user = feedMessage.relationships.users.data.first {
			self.displayNameLabel.text = user.attributes.username
			self.usernameLabel.text = "@\(user.attributes.slug)"
			user.attributes.profileImage(imageView: self.profileImageView)

			// Attach gestures
			self.configureProfilePageGesture(for: self.displayNameLabel)
			self.configureProfilePageGesture(for: self.profileImageView)

			// Badges
			self.profileBadgeStackView.delegate = self
			self.profileBadgeStackView.configure(for: user)
		}

		// Configure body and rich link
		if let url = feedMessage.attributes.content.extractURLs().last, url.isWebURL {
			// Strip URL from text upfront so the text height is stable
			self.configurePostTextView(for: feedMessage, byRemovingURL: url, isExpanded: isExpanded)

			if let metadata = RichLink.shared.cachedMetadata(for: url) {
				self.displayMetadata(metadata)
			} else if url.isImageURL {
				let placeholder = self.makeRichLinkPlaceholder()
				self.richLinkStackView.addArrangedSubview(placeholder)
				self.richLinkPlaceholder = placeholder

				self.richLinkTask = Task { [weak self] in
					guard let metadata = await RichLink.shared.fetchMetadata(for: url) else { return }
					guard !Task.isCancelled else { return }
					guard let self else { return }
					self.richLinkPlaceholder?.removeFromSuperview()
					self.richLinkPlaceholder = nil
					self.displayMetadata(metadata)
					self.delegate?.baseFeedMessageCell(self, didUpdateContentLayout: self)
				}
			} else {
				let linkView = KRichLinkView(url: url)
				self.richLinkStackView.addArrangedSubview(linkView)

				self.richLinkTask = Task {
					guard let metadata = await RichLink.shared.fetchMetadata(for: url) else { return }
					guard !Task.isCancelled else { return }
					linkView.update(with: metadata)
				}
			}
		} else {
			self.applyBodyText(feedMessage.attributes.contentMarkdown.markdownAttributedString(), isExpanded: isExpanded)
		}
		self.postTextView.delegate = self
		self.postTextView.kkActionHandler = { [weak self] action in
			guard let self else { return }

			if action == Self.expandMessageActionID {
				self.delegate?.baseFeedMessageCell(self, didTapShowMore: self)
			}
		}

		// Configure date time
		self.dateTimeLabel.text = feedMessage.attributes.createdAt.relativeToNow

		// Configure metrics
		var heartsCount: Int? = feedMessage.attributes.metrics.heartCount
		heartsCount = heartsCount == 0 ? nil : heartsCount
		self.heartButton.setTitle(heartsCount?.kkFormatted(precision: 0), for: .normal)

		var replyCount: Int? = feedMessage.attributes.metrics.replyCount
		replyCount = replyCount == 0 ? nil : replyCount
		self.commentButton.setTitle(replyCount?.kkFormatted(precision: 0), for: .normal)

		var reShareCount: Int? = feedMessage.attributes.metrics.reShareCount
		reShareCount = reShareCount == 0 ? nil : reShareCount
		self.shareButton.setTitle(reShareCount?.kkFormatted(precision: 0), for: .normal)

		// Configure more button
		self.moreButton.showsMenuAsPrimaryAction = true

		// Configure re-share button
		self.configureReShareButton(for: feedMessage)
		self.configureReShareMenu()

		// Configure warning messages
		self.configureWarnings(for: feedMessage)
	}

	fileprivate func configurePostTextView(for feedMessage: FeedMessage, byRemovingURL url: URL, isExpanded: Bool) {
		let contentMarkdown = self.removeURLFromEndOfText(url: url, text: feedMessage.attributes.contentMarkdown)
		self.applyBodyText(contentMarkdown.markdownAttributedString(), isExpanded: isExpanded)
		self.postTextViewContainer?.isHidden = contentMarkdown.isEmpty
	}

	/// Creates a placeholder view that reserves space for an incoming rich link preview.
	private func makeRichLinkPlaceholder() -> UIView {
		let placeholder = UIView()
		placeholder.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		placeholder.layerCornerRadius = 10.0
		placeholder.heightAnchor.constraint(equalToConstant: 120).isActive = true
		return placeholder
	}

	fileprivate func displayMetadata(_ metadata: LPLinkMetadata) {
		if let gifURL = metadata.url, gifURL.isImageURL {
			let gifView = GIFView(url: gifURL, in: self.richLinkStackView)
			gifView.delegate = self
			self.richLinkStackView.addArrangedSubview(gifView)
		} else {
			let linkView = KRichLinkView(metadata: metadata)
			self.richLinkStackView.addArrangedSubview(linkView)
		}
	}

	fileprivate func removeURLFromEndOfText(url: URL, text: String) -> String {
		let urlString = url.absoluteString

		// Remove the URL from the end of the full text
		if text.hasSuffix(urlString) {
			return String(text.dropLast(urlString.count)).trimmingCharacters(in: .whitespacesAndNewlines)
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

	/// Configures the attribution row tap gesture.
	fileprivate func configureAttributionTapGesture() {
		self.statusStackView.isUserInteractionEnabled = true

		if self.statusStackView.gestureRecognizers?.isEmpty ?? true {
			let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.attributionTapped(_:)))
			recognizer.numberOfTouchesRequired = 1
			recognizer.numberOfTapsRequired = 1
			self.statusStackView.addGestureRecognizer(recognizer)
		}
	}

	@objc private func attributionTapped(_ sender: UITapGestureRecognizer) {
		self.delegate?.baseFeedMessageCellDidTapAttribution(self)
	}

	/// Configures the re-share menu.
	fileprivate func configureReShareMenu() {
		self.shareButton.showsMenuAsPrimaryAction = true
		self.shareButton.menu = UIMenu(title: "", children: [
			UIDeferredMenuElement.uncached { [weak self] completion in
				guard let self = self, let menu = self.delegate?.baseFeedMessageCellReShareMenu(self) else {
					completion([])
					return
				}
				completion(menu.children)
			}
		])
	}

	/// Configures the warning messages.
	fileprivate func configureWarnings(for feedMessage: FeedMessage) {
		let isNSFW = feedMessage.attributes.isNSFW
		let isSpoiler = feedMessage.attributes.isSpoiler

		self.warningVisualEffectView?.layerCornerRadius = 10.0

		// Configure warning visual effect view
		if isNSFW || isSpoiler {
			self.warningVisualEffectView?.isHidden = false
		} else {
			self.warningTranscriptLabel?.text = ""
			self.warningVisualEffectView?.isHidden = true
			return
		}

		// Configure warning transcript
		if isNSFW, isSpoiler {
			self.warningTranscriptLabel?.text = L10n.messageWarningNsfwSpoilers
		} else if isNSFW {
			self.warningTranscriptLabel?.text = L10n.messageWarningNsfw
		} else if isSpoiler {
			self.warningTranscriptLabel?.text = L10n.messageWarningSpoilers
		}

		// Add gesture recognizer to hide visual effect
		if let warningVisualEffectView = self.warningVisualEffectView, warningVisualEffectView.gestureRecognizers?.isEmpty ?? true {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideWarning(_:)))
			self.warningVisualEffectView?.addGestureRecognizer(tapGestureRecognizer)
		}
	}

	/// Adds a `UITapGestureRecognizer` which opens the profile image onto the given view.
	///
	/// - Parameter view: The view to which the tap gesture should be attached.
	fileprivate func configureProfilePageGesture(for view: UIView) {
		if view.gestureRecognizers?.isEmpty ?? true {
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
			self.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
			self.heartButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
			self.heartButton.theme_tintColor = KThemePicker.tintColor.rawValue
		} else {
			self.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
			self.heartButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.heartButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	fileprivate func getUserIdentity(username: String) async -> UserIdentity? {
		do {
			let userIdentityResponse = try await KService.searchUsers(username).response()
			return userIdentityResponse.data.first
		} catch {
			print("-----", error.localizedDescription)
			return nil
		}
	}

	// MARK: - IBActions
	@objc func usernameLabelPressed(_ sender: AnyObject) {
		Task {
			await self.delegate?.baseFeedMessageCell(self, didPressUserName: sender)
		}
	}

	@IBAction func heartButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.baseFeedMessageCell(self, didPressHeartButton: sender)
			sender.animateBounce()
		}
	}

	@IBAction func commentButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.baseFeedMessageCell(self, didPressReplyButton: sender)
			sender.animateBounce()
		}
	}

	@IBAction func reShareButtonPressed(_ sender: UIButton) {
		sender.animateBounce()
	}
}

// MARK: - UITextViewDelegate
extension BaseFeedMessageCell: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if url.absoluteString.starts(with: "https://kurozora.app/profile") {
			Task { [weak self] in
				guard let self = self else { return }
				let username = url.lastPathComponent
				guard let userIdentity = await self.getUserIdentity(username: username) else { return }
				let deeplink = url.absoluteString
					.replacingOccurrences(of: "https://kurozora.app/", with: "kurozora://")
					.replacingOccurrences(of: username, with: "\(userIdentity.id)")

				UIApplication.shared.kOpen(nil, deepLink: URL(string: deeplink))
			}

			return false
		}

		return true
	}
}

// MARK: - ProfileBadgeStackViewDelegate
extension BaseFeedMessageCell: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) async {
		await self.delegate?.baseFeedMessageCell(self, didPressProfileBadge: button, for: profileBadge)
	}
}

// MARK: - GIFViewDelegate
extension BaseFeedMessageCell: GIFViewDelegate {
	func gifViewDidLoadGIF(_ gifView: GIFView) {
		self.richLinkStackView.setNeedsLayout()
		self.richLinkStackView.layoutIfNeeded()

		self.delegate?.baseFeedMessageCell(self, didUpdateContentLayout: gifView)
	}
}
