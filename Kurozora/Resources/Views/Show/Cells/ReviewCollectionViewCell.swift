//
//  ReviewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ReviewCollectionViewCellDelegate: AnyObject {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject)
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge)
}

class ReviewCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet weak var dateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var cosmosView: KCosmosView!
	@IBOutlet weak var contentTextView: KTextView!

	// MARK: - Properties
	weak var delegate: ReviewCollectionViewCellDelegate?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the cell.
	fileprivate func sharedInit() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.layerCornerRadius = 8
	}

	/// Configure the cell with the given person details.
	func configureCell(using review: Review?) {
		guard let review = review else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

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

		// Configure date time
		self.dateTimeLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
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
}

// MARK: - UITextViewDelegate
extension ReviewCollectionViewCell: UITextViewDelegate {
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
extension ReviewCollectionViewCell: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) {
		self.delegate?.reviewCollectionViewCell(self, didPressProfileBadge: button, for: profileBadge)
	}
}
