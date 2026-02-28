//
//  ReviewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol ReviewCollectionViewCellDelegate: AnyObject {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject)
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge)
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressMoreButton button: UIButton)
}

class ReviewCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet weak var dateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var cosmosView: KCosmosView!
	@IBOutlet weak var contentTextView: KTextView!
	@IBOutlet weak var moreButton: KButton!
	@IBOutlet weak var moreImageView: UIImageView!
	@IBOutlet weak var moreButtonView: UIView!

	// MARK: - Properties
	weak var delegate: ReviewCollectionViewCellDelegate?

	/// Configure the cell with the given person details.
	///
	/// - Parameters:
	///    - review: The review details to configure the cell with.
	///    - showsFullReview: Whether to show the full review text without truncation.
	func configureCell(using review: Review?, showsFullReview: Bool = false) {
		guard let review = review else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		if showsFullReview {
			// Configure view
			self.layerCornerRadius = 0
			self.contentView.theme_backgroundColor = nil
			self.contentView.backgroundColor = .clear

			// Configure body
			self.contentTextView.textContainer.maximumNumberOfLines = 0
			self.contentTextView.isSelectable = true

			// Configure more view
			self.moreButtonView.isHidden = true
		} else {
			// Configure view
			self.layerCornerRadius = 8
			self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			// Configure body
			self.contentTextView.textContainer.maximumNumberOfLines = 6
			self.contentTextView.textContainer.lineBreakMode = .byWordWrapping
			self.contentTextView.isSelectable = false
		}

		if let user = review.relationships?.users?.data.first {
			self.usernameLabel.text = user.attributes.username
			user.attributes.profileImage(imageView: self.profileImageView)

			// Attach gestures
			self.configureProfilePageGesture(for: self.usernameLabel)
			self.configureProfilePageGesture(for: self.profileImageView)

			// Badges
			self.profileBadgeStackView.delegate = self
			self.profileBadgeStackView.configure(for: user)
		}

		// Configure rating
		self.cosmosView.rating = review.attributes.score

		// Configure body
		self.contentTextView.setAttributedText(review.attributes.description?.markdownAttributedString())
		self.contentTextView.delegate = self
		self.contentTextView.layoutManager.delegate = self

		// Configure date time
		self.dateTimeLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		
		// Configure more view
		self.moreImageView?.theme_tintColor = KThemePicker.tableViewCellBackgroundColor.rawValue

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
		self.delegate?.reviewCollectionViewCell(self, didPressUserName: sender)
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.reviewCollectionViewCell(self, didPressMoreButton: sender)
	}
}

// MARK: - UITextViewDelegate
extension ReviewCollectionViewCell: UITextViewDelegate {
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

// MARK: - NSLayoutManagerDelegate
extension ReviewCollectionViewCell: NSLayoutManagerDelegate {
	func layoutManager(_ layoutManager: NSLayoutManager, textContainer: NSTextContainer, didChangeGeometryFrom oldSize: CGSize) {
		guard self.contentTextView.textContainer.maximumNumberOfLines != 0 else { return }
		self.moreButtonView?.isHidden = !(self.contentTextView.layoutManager.numberOfLines > 6)
	}
}

// MARK: - ProfileBadgeStackViewDelegate
extension ReviewCollectionViewCell: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) {
		self.delegate?.reviewCollectionViewCell(self, didPressProfileBadge: button, for: profileBadge)
	}
}
