//
//  FeedMessageReShareCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import LinkPresentation

class FeedMessageReShareCell: FeedMessageCell {
	// MARK: - IBOutlets
	@IBOutlet weak var opProfileImageView: ProfileImageView!
	@IBOutlet weak var opUsernameLabel: KLabel!
	@IBOutlet weak var opPostTextView: KSelectableTextView!
	@IBOutlet weak var opPostTextViewContainer: UIView!
	@IBOutlet weak var opDateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var opView: UIView?
	@IBOutlet weak var opProfileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet weak var opRichLinkStackView: UIStackView!

	// MARK: - Properties
	private var opRichLinkTask: Task<Void, Never>?
	private weak var opRichLinkPlaceholder: UIView?

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.opPostTextViewContainer?.isHidden = false

		self.opRichLinkTask?.cancel()
		self.opRichLinkTask = nil
		self.opRichLinkPlaceholder = nil
		self.opRichLinkStackView.arrangedSubviews.forEach { subview in
			if subview != self.opPostTextViewContainer {
				self.opRichLinkStackView.removeArrangedSubview(subview)
				subview.removeFromSuperview()
			}
		}
	}

	// MARK: - Functions
	override func configureCell(using feedMessage: FeedMessage?, isOnProfile: Bool) {
		super.configureCell(using: feedMessage, isOnProfile: isOnProfile)
		guard let feedMessage = feedMessage else {
			return
		}

		guard let opMessage = feedMessage.relationships.parent?.data.first else { return }
		self.opDateTimeLabel.text = opMessage.attributes.createdAt.relativeToNow

		if let user = feedMessage.relationships.users.data.first, let opUser = opMessage.relationships.users.data.first {
			opUser.attributes.profileImage(imageView: self.opProfileImageView)

			// Configure status label
			if isOnProfile, feedMessage.attributes.isPinned {
			} else {
				self.statusImageView.image = UIImage(systemName: "arrow.2.squarepath")
				self.statusLabel.text = if user.attributes.username == User.current?.attributes.username {
					"You reposted this"
				} else {
					"\(user.attributes.username) reposted this"
				}
				self.statusStackView.isHidden = false
			}

			// Configure username
			self.opUsernameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).bold
			self.opUsernameLabel.text = opUser.attributes.username

			// Attach gestures
			self.configureOPProfilePageGesture(for: self.opProfileImageView)
			self.configureOPProfilePageGesture(for: self.opUsernameLabel)

			// Badges
			self.opProfileBadgeStackView.delegate = self
			self.opProfileBadgeStackView.configure(for: opUser)
		}

		if let opView = self.opView, opView.gestureRecognizers?.isEmpty ?? true {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOPMessage(_:)))
			self.opView?.addGestureRecognizer(tapGestureRecognizer)
		}

		// Configure body
		self.opPostTextView.text = ""

		// Cancel any in-flight OP fetch and clean up stale rich content
		self.opRichLinkTask?.cancel()
		self.opRichLinkTask = nil
		self.opRichLinkPlaceholder = nil
		self.opRichLinkStackView.arrangedSubviews.forEach { subview in
			if subview != self.opPostTextViewContainer {
				self.opRichLinkStackView.removeArrangedSubview(subview)
				subview.removeFromSuperview()
			}
		}

		if let url = opMessage.attributes.content.extractURLs().last, url.isWebURL {
			if let metadata = RichLink.shared.cachedMetadata(for: url) {
				self.displayMetadata(metadata)
				self.configurePostTextView(for: opMessage, byRemovingURL: url)
			} else {
				// Reserve space with a placeholder while fetching
				let placeholder = self.makeOPRichLinkPlaceholder()
				self.opRichLinkStackView.addArrangedSubview(placeholder)
				self.opRichLinkPlaceholder = placeholder

				self.opRichLinkTask = Task { [weak self] in
					guard let metadata = await RichLink.shared.fetchMetadata(for: url) else { return }
					guard !Task.isCancelled else { return }
					guard let self else { return }
					self.opRichLinkPlaceholder?.removeFromSuperview()
					self.opRichLinkPlaceholder = nil
					self.displayMetadata(metadata)
					self.configurePostTextView(for: opMessage, byRemovingURL: url)
					self.delegate?.baseFeedMessageCell(self, didUpdateContentLayout: self)
				}
			}
		} else {
			self.opPostTextView.setAttributedText(opMessage.attributes.contentMarkdown.markdownAttributedString())
		}
	}

	/// Creates a placeholder view that reserves space for an incoming OP rich link preview.
	private func makeOPRichLinkPlaceholder() -> UIView {
		let placeholder = UIView()
		placeholder.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		placeholder.layerCornerRadius = 10.0
		placeholder.heightAnchor.constraint(equalToConstant: 120).isActive = true
		return placeholder
	}

	fileprivate func configurePostTextView(for feedMessage: FeedMessage, byRemovingURL url: URL) {
		let contentMarkdown = self.removeURLFromEndOfText(url: url, text: feedMessage.attributes.contentMarkdown)
		self.opPostTextView.setAttributedText(contentMarkdown.markdownAttributedString())
		self.opPostTextViewContainer?.isHidden = contentMarkdown.isEmpty
	}

	fileprivate func displayMetadata(_ metadata: LPLinkMetadata) {
		if let gifURL = metadata.url, gifURL.isImageURL {
			let gifView = GIFView(url: gifURL, in: self.opRichLinkStackView)
			self.opRichLinkStackView.addArrangedSubview(gifView)
		} else {
			let linkView = KLinkView(metadata: metadata)
			self.opRichLinkStackView.addArrangedSubview(linkView)
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

	/// Adds a `UITapGestureRecognizer` which opens the profile image onto the given view.
	///
	/// - Parameter view: The view to which the tap gesture should be attached.
	fileprivate func configureOPProfilePageGesture(for view: UIView) {
		if view.gestureRecognizers?.isEmpty ?? true {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(opUsernameLabelPressed(_:)))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			view.addGestureRecognizer(gestureRecognizer)
			view.isUserInteractionEnabled = true
		}
	}

	/// Segues to message details.
	@objc func showOPMessage(_ sender: AnyObject) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.feedMessageReShareCell(self, didPressOPMessage: sender)
		}
	}

	/// Presents the profile view for the feed message poster.
	@objc fileprivate func opUsernameLabelPressed(_ sender: AnyObject) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.feedMessageReShareCell(self, didPressUserName: sender)
		}
	}
}
