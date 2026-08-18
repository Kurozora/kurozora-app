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
	func reviewCollectionViewCellDidTapTranslation(_ cell: ReviewCollectionViewCell)
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapTranslationSettings button: UIButton)
}

class ReviewCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var borderView: BorderView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet weak var dateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var cosmosView: KCosmosView!
	@IBOutlet weak var contentTextViewPlaceholder: UIView!
	@IBOutlet weak var moreButton: KButton!
	@IBOutlet weak var moreImageView: UIImageView!
	@IBOutlet weak var moreButtonView: UIView!

	// MARK: - Views
	private(set) var contentTextView: KSelectableTextView!
	private(set) var translationBarView: TranslationBarView!
	private var metadataLabel: KTintedLabel!
	private var spoilerOverlayView: SpoilerOverlayView!

	// MARK: - Properties
	weak var delegate: ReviewCollectionViewCellDelegate?

	/// Whether the reader revealed this review's spoiler.
	private var isSpoilerRevealed = false

	private static var spoilerWarningText: String {
		#if targetEnvironment(macCatalyst)
		return L10n.reviewSpoilerClick
		#else
		return L10n.reviewSpoilerTap
		#endif
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.configureContentTextView()

		self.profileImageView.layer.borderWidth = 0
		self.borderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.borderView.cornerRadius = self.profileImageView.bounds.height / 2.0
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.isSpoilerRevealed = false
	}

	// MARK: - Functions
	private func configureContentTextView() {
		let textView = KSelectableTextView()
		textView.isScrollEnabled = false
		textView.bounces = false

		// Stacking inside the placeholder puts the row above the body without every
		// review nib needing its own layout for it.
		let contentStackView = UIStackView(arrangedSubviews: [textView])
		contentStackView.axis = .vertical

		self.contentTextViewPlaceholder.addSubview(contentStackView)
		contentStackView.fillToSuperview()

		self.contentTextView = textView
		self.translationBarView = TranslationBarView.install(in: contentStackView, at: 0, delegate: self)

		let metadataLabel = KTintedLabel()
		metadataLabel.font = .preferredFont(forTextStyle: .caption1).bold
		metadataLabel.adjustsFontForContentSizeCategory = true
		metadataLabel.numberOfLines = 0
		contentStackView.insertArrangedSubview(metadataLabel, at: 0)
		self.metadataLabel = metadataLabel

		let spoilerOverlayView = SpoilerOverlayView()
		spoilerOverlayView.configure(warning: Self.spoilerWarningText, cornerRadius: 10)
		spoilerOverlayView.revealHandler = { [weak self] in
			self?.isSpoilerRevealed = true
		}

		self.contentTextViewPlaceholder.addSubview(spoilerOverlayView)
		NSLayoutConstraint.activate([
			spoilerOverlayView.topAnchor.constraint(equalTo: self.contentTextViewPlaceholder.topAnchor),
			spoilerOverlayView.bottomAnchor.constraint(equalTo: self.contentTextViewPlaceholder.bottomAnchor),
			spoilerOverlayView.leadingAnchor.constraint(equalTo: self.contentTextViewPlaceholder.leadingAnchor),
			spoilerOverlayView.trailingAnchor.constraint(equalTo: self.contentTextViewPlaceholder.trailingAnchor)
		])

		self.spoilerOverlayView = spoilerOverlayView
	}

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
			self.layer.cornerCurve = .continuous
			self.contentView.theme_backgroundColor = nil
			self.contentView.backgroundColor = .clear

			// Configure body
			self.contentTextView.textContainer.maximumNumberOfLines = 0
			self.contentTextView.isSelectable = true
			self.contentTextView.allowsFullTextInteraction = true

			// Configure more view
			self.moreButtonView.isHidden = true
		} else {
			// Configure view
			self.layerCornerRadius = 22
			self.layer.cornerCurve = .continuous
			self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			// Configure body
			self.contentTextView.textContainer.maximumNumberOfLines = 6
			self.contentTextView.textContainer.lineBreakMode = .byWordWrapping
			self.contentTextView.isSelectable = false
			self.contentTextView.allowsFullTextInteraction = false
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
		let metadataText = self.metadataText(for: review)
		self.metadataLabel.text = metadataText
		self.metadataLabel.isHidden = metadataText == nil

		var translatedBody: NSAttributedString?

		if #available(iOS 26.4, macCatalyst 26.4, *) {
			let translationState = TranslationService.shared.state(for: review)
			self.translationBarView.configure(using: translationState)
			translatedBody = translationState.body
		} else {
			self.translationBarView.isHidden = true
		}

		self.contentTextView.setAttributedText(translatedBody ?? review.attributes.description?.markdownAttributedString())
		self.spoilerOverlayView.isHidden = self.isSpoilerRevealed || !(review.attributes.isSpoiler && !(review.attributes.description ?? "").isEmpty)
		self.contentTextView.delegate = self
		self.contentTextView.layoutManager.delegate = self

		// Configure date time
		self.dateTimeLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)

		// Configure more view
		self.moreImageView?.theme_tintColor = KThemePicker.tableViewCellBackgroundColor.rawValue

	}

	/// Builds the recommendation and progress badge shown above a review's body.
	///
	/// - Parameter review: The review to build the badge text from.
	///
	/// - Returns: The joined badge text, or `nil` when the review has neither a recommendation nor a progress.
	private func metadataText(for review: Review) -> String? {
		var parts: [String] = []

		if let recommendation = review.attributes.recommendation {
			parts.append(recommendation.localizedName)
		}

		if let progress = review.attributes.progress {
			if let progressTotal = review.attributes.progressTotal {
				parts.append(L10n.reviewProgressEpisode("\(progress)", "\(progressTotal)"))
			} else {
				parts.append(L10n.reviewProgressEpisodeOnly("\(progress)"))
			}
		}

		return parts.isEmpty ? nil : parts.joined(separator: " · ")
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
			let userIdentityResponse = try await KService.searchUsers(username).response()
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

// MARK: - TranslationBarViewDelegate
extension ReviewCollectionViewCell: TranslationBarViewDelegate {
	func translationBarViewDidTapAction(_ translationBarView: TranslationBarView) {
		self.delegate?.reviewCollectionViewCellDidTapTranslation(self)
	}

	func translationBarView(_ translationBarView: TranslationBarView, didTapSettings button: UIButton) {
		self.delegate?.reviewCollectionViewCell(self, didTapTranslationSettings: button)
	}
}
