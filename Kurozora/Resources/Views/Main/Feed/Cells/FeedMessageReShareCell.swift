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

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.opPostTextViewContainer?.isHidden = false
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

		if let opView = self.opView, opView.gestureRecognizers.isNilOrEmpty {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOPMessage(_:)))
			self.opView?.addGestureRecognizer(tapGestureRecognizer)
		}

		// Configure body
		self.opPostTextView.text = ""
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
				Task(priority: .background) {
					if let metadata = await RichLink.shared.fetchMetadata(for: url) {
						DispatchQueue.main.async {
							self.displayMetadata(metadata)
							self.configurePostTextView(for: opMessage, byRemovingURL: url)
						}
					}
				}
			}
		} else {
			self.opPostTextView.setAttributedText(opMessage.attributes.contentMarkdown.markdownAttributedString())
		}
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
