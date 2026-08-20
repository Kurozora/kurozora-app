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

	/// Tells the delegate the user voted on the review rendered by `cell`.
	///
	/// - Parameters:
	///    - cell: The cell that received the vote.
	///    - vote: The vote cast.
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapVote vote: ReviewVote)
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
	private var voteRowView: UIStackView!

	private let helpfulButton: CellActionButton = {
		let button = CellActionButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
		return button
	}()

	private let unhelpfulButton: CellActionButton = {
		let button = CellActionButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
		return button
	}()

	// MARK: - Properties
	weak var delegate: ReviewCollectionViewCellDelegate?

	/// Whether the reader revealed this review's spoiler.
	private var isSpoilerRevealed = false

	/// The review the cell is showing.
	private var review: Review?

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
		self.review = nil
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

		let voteRowView = UIStackView(arrangedSubviews: [self.helpfulButton, self.unhelpfulButton, UIView()])
		voteRowView.axis = .horizontal
		voteRowView.spacing = UIStackView.spacingUseSystem
		voteRowView.alignment = .center
		voteRowView.isHidden = true
		contentStackView.addArrangedSubview(voteRowView)
		self.voteRowView = voteRowView

		self.helpfulButton.addTarget(self, action: #selector(self.helpfulButtonPressed), for: .touchUpInside)
		self.unhelpfulButton.addTarget(self, action: #selector(self.unhelpfulButtonPressed), for: .touchUpInside)

		let spoilerOverlayView = SpoilerOverlayView()
		spoilerOverlayView.configure(warning: Self.spoilerWarningText, cornerRadius: 10)
		spoilerOverlayView.revealHandler = { [weak self] in
			self?.isSpoilerRevealed = true
		}

		self.contentTextViewPlaceholder.addSubview(spoilerOverlayView)
		NSLayoutConstraint.activate([
			spoilerOverlayView.topAnchor.constraint(equalTo: textView.topAnchor),
			spoilerOverlayView.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
			spoilerOverlayView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
			spoilerOverlayView.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
		])

		self.spoilerOverlayView = spoilerOverlayView
	}

	/// Configure the cell with the given person details.
	///
	/// - Parameters:
	///    - review: The review details to configure the cell with.
	///    - showsFullReview: Whether to show the full review text without truncation.
	///    - isElevated: Whether the review was elevated to Editor's Choice by staff.
	func configureCell(using review: Review?, showsFullReview: Bool = false, isElevated: Bool = false) {
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
		let metadataText = self.metadataText(for: review, isElevated: isElevated)
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

		// Configure votes
		self.review = review
		self.updateVoteRow(for: review)

		// Configure date time
		self.dateTimeLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)

		// Configure more view
		self.moreImageView?.theme_tintColor = KThemePicker.tableViewCellBackgroundColor.rawValue

	}

	/// Builds the recommendation and progress badge shown above a review's body.
	///
	/// - Parameters:
	///    - review: The review to build the badge text from.
	///    - isElevated: Whether the review was elevated to Editor's Choice by staff.
	///
	/// - Returns: The joined badge text, or `nil` when the review has no badge to show.
	private func metadataText(for review: Review, isElevated: Bool) -> String? {
		var parts: [String] = []

		if isElevated {
			parts.append(L10n.communityPick)
		}

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

		if let revisionCount = review.attributes.revisionCount, revisionCount > 0 {
			parts.append(L10n.reviewEdited)
		}

		return parts.isEmpty ? nil : parts.joined(separator: " · ")
	}

	/// Shows the tapped vote before the server confirms it.
	///
	/// - Parameter vote: The vote the reader tapped.
	private func showVote(_ vote: ReviewVote) {
		guard User.isSignedIn else { return }
		guard var review = self.review else { return }

		let tappedHelpful = vote == .helpful
		let predicted: Bool? = review.attributes.isHelpful == tappedHelpful ? nil : tappedHelpful

		review.attributes.applyVote(predicted)
		self.review = review
		self.updateVoteRow(for: review)
	}

	/// Shows the vote row and refreshes both buttons for the given review.
	///
	/// - Parameter review: The review the row votes on.
	private func updateVoteRow(for review: Review) {
		let isOwnReview = User.current?.id == review.relationships?.users?.data.first?.id
		self.voteRowView.isHidden = false

		// The author has a right to their own counts; only the vote is withheld.
		self.voteRowView.isUserInteractionEnabled = !isOwnReview

		self.updateHelpfulButton(for: review)
		self.updateUnhelpfulButton(for: review)
	}

	/// Refreshes the helpful button for the given review.
	///
	/// - Parameter review: The review the button votes on.
	private func updateHelpfulButton(for review: Review) {
		var count: Int? = review.attributes.helpfulCount
		count = count == 0 ? nil : count
		self.helpfulButton.setTitle(count?.kkFormatted(precision: 0), for: .normal)

		if review.attributes.isHelpful == true {
			self.helpfulButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
			self.helpfulButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
			self.helpfulButton.theme_tintColor = KThemePicker.tintColor.rawValue
		} else {
			self.helpfulButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
			self.helpfulButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.helpfulButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	/// Refreshes the unhelpful button for the given review.
	///
	/// - Parameter review: The review the button votes on.
	private func updateUnhelpfulButton(for review: Review) {
		var count: Int? = review.attributes.unhelpfulCount
		count = count == 0 ? nil : count
		self.unhelpfulButton.setTitle(count?.kkFormatted(precision: 0), for: .normal)

		if review.attributes.isHelpful == false {
			self.unhelpfulButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
			self.unhelpfulButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
			self.unhelpfulButton.theme_tintColor = KThemePicker.tintColor.rawValue
		} else {
			self.unhelpfulButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
			self.unhelpfulButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.unhelpfulButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
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

	@objc private func helpfulButtonPressed() {
		self.showVote(.helpful)
		self.delegate?.reviewCollectionViewCell(self, didTapVote: .helpful)
	}

	@objc private func unhelpfulButtonPressed() {
		self.showVote(.unhelpful)
		self.delegate?.reviewCollectionViewCell(self, didTapVote: .unhelpful)
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
