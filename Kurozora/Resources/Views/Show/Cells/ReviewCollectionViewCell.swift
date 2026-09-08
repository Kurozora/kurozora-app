//
//  ReviewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Cosmos
import KurozoraKit
import UIKit

protocol ReviewCollectionViewCellDelegate: AnyObject {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject)
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge)
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressMoreButton button: UIButton)
	func reviewCollectionViewCellDidTapTranslation(_ cell: ReviewCollectionViewCell)
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapTranslationSettings button: UIButton)

	/// Tells the delegate the reader tapped a profile link inside the review's body.
	///
	/// - Parameters:
	///    - cell: The cell whose body carries the link.
	///    - url: The profile link that was tapped.
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapProfileLink url: URL)

	/// Tells the delegate the user voted on the review rendered by `cell`.
	///
	/// - Parameters:
	///    - cell: The cell that received the vote.
	///    - vote: The vote cast.
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapVote vote: ReviewVote)
}

class ReviewCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let profileImageView: ProfileImageView = {
		let imageView = ProfileImageView(frame: .zero)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.borderWidth = 0
		return imageView
	}()

	private let borderView: BorderView = {
		let borderView = BorderView()
		borderView.translatesAutoresizingMaskIntoConstraints = false
		borderView.isUserInteractionEnabled = false
		return borderView
	}()

	private let usernameLabel: KLabel = {
		let label = KLabel()
		label.font = .preferredFont(forTextStyle: .headline)
		label.adjustsFontForContentSizeCategory = true
		label.lineBreakMode = .byTruncatingTail
		label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
		label.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
		return label
	}()

	private let profileBadgeStackView = ProfileBadgeStackView()

	private let dateTimeLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.font = .preferredFont(forTextStyle: .caption1)
		label.adjustsFontForContentSizeCategory = true
		label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
		return label
	}()

	private let cosmosView: KCosmosView = {
		var settings = CosmosSettings()
		settings.updateOnTouch = false
		settings.starSize = 16
		settings.textFont = settings.textFont.withSize(12)

		let cosmosView = KCosmosView(frame: .zero, settings: settings)
		cosmosView.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
		cosmosView.setContentCompressionResistancePriority(.required, for: .vertical)
		return cosmosView
	}()

	private let metadataLabel: KTintedLabel = {
		let label = KTintedLabel()
		label.font = .preferredFont(forTextStyle: .caption1).bold
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}()

	private var translationBarView: TranslationBarView!

	/// The container sized to the rendered body, so the overlays track the text instead of the cell.
	private let bodyView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let bodyTextView: KSelectableTextView = {
		let textView = KSelectableTextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false
		textView.bounces = false

		// Keeps the text view at its rendered height, so its bottom edge is the last line's.
		textView.setContentHuggingPriority(.required, for: .vertical)
		return textView
	}()

	/// Carries one line of the body's font, so the `more` mask can match the line it covers.
	private let bodyMetricsView: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .body)
		label.adjustsFontForContentSizeCategory = true
		label.text = " "
		label.isHidden = true
		return label
	}()

	/// The gradient that fades out the words clipped beneath the `more` button.
	private let moreGradientImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "shadow.right"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.clipsToBounds = true
		imageView.theme_tintColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		return imageView
	}()

	private let moreButton: KButton = {
		let button = KButton()
		button.translatesAutoresizingMaskIntoConstraints = false

		// Matches `KButton`'s semibold weight at the body's metrics.
		button.titleLabel?.font = .preferredFont(forTextStyle: .body).semibold
		button.titleLabel?.adjustsFontForContentSizeCategory = true
		button.setTitle(L10n.reviewMore, for: .normal)
		return button
	}()

	/// The mask that rides the body's last rendered line.
	private let moreView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	private let spoilerOverlayView = SpoilerOverlayView()

	private let helpfulButton: CellActionButton = {
		let button = CellActionButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .preferredFont(forTextStyle: .body)
		button.titleLabel?.adjustsFontForContentSizeCategory = true
		button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(textStyle: .body), forImageIn: .normal)
		button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
		return button
	}()

	private let unhelpfulButton: CellActionButton = {
		let button = CellActionButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .preferredFont(forTextStyle: .body)
		button.titleLabel?.adjustsFontForContentSizeCategory = true
		button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(textStyle: .body), forImageIn: .normal)
		button.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
		return button
	}()

	private let voteRowView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = UIStackView.spacingUseSystem
		stackView.alignment = .center
		return stackView
	}()

	// MARK: - Properties
	weak var delegate: ReviewCollectionViewCellDelegate?

	/// Closes the body container around the text view.
	private var bodyBottomConstraint: NSLayoutConstraint!

	/// Whether the reader revealed this review's spoiler.
	private var isSpoilerRevealed = false

	/// The number of body lines shown before the review is clipped behind the `more` button.
	private static let bodyLineLimit = 6

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.updateMoreView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard self.traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else { return }

		// `KTextView` resolves its font once, and the body's attributes pin that font across the whole range.
		self.bodyTextView.font = .preferredFont(forTextStyle: .body)
		self.bodyTextView.setAttributedText(self.bodyTextView.attributedText)

		// A button's intrinsic size does not follow its title label's own type size updates.
		for button in [self.helpfulButton, self.unhelpfulButton] {
			button.titleLabel?.font = .preferredFont(forTextStyle: .body)
			button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(textStyle: .body), forImageIn: .normal)
			button.invalidateIntrinsicContentSize()
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.isSpoilerRevealed = false
	}

	// MARK: - Functions
	/// Configures the cell with the given review.
	///
	/// - Parameters:
	///    - review: The review to configure the cell with.
	///    - showsFullReview: Whether to show the full review text without truncation.
	///    - isElevated: Whether the review was elevated to Editor's Choice by staff.
	func configureCell(using review: Review?, showsFullReview: Bool = false, isElevated: Bool = false) {
		guard let review = review else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.configureAppearance(showsFullReview: showsFullReview)
		self.configureHeader(for: review)
		self.configureBody(for: review, isElevated: isElevated)
		self.configureVoteRow(for: review)
	}

	/// Lays the cell out for the given presentation.
	///
	/// - Parameter showsFullReview: Whether to show the full review text without truncation.
	private func configureAppearance(showsFullReview: Bool) {
		self.layer.cornerCurve = .continuous

		if showsFullReview {
			self.layerCornerRadius = 0
			self.contentView.theme_backgroundColor = nil
			self.contentView.backgroundColor = .clear

			self.bodyTextView.textContainer.maximumNumberOfLines = 0
			self.bodyTextView.isSelectable = true
			self.bodyTextView.allowsFullTextInteraction = true
		} else {
			self.layerCornerRadius = 22
			self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			self.bodyTextView.textContainer.maximumNumberOfLines = Self.bodyLineLimit
			self.bodyTextView.textContainer.lineBreakMode = .byWordWrapping
			self.bodyTextView.isSelectable = false
			self.bodyTextView.allowsFullTextInteraction = false
		}
	}

	/// Configures the cell's header with the given review.
	///
	/// - Parameter review: The review to configure the header with.
	private func configureHeader(for review: Review) {
		if let user = review.relationships?.users?.data.first {
			self.usernameLabel.text = user.attributes.username
			user.attributes.profileImage(imageView: self.profileImageView)

			self.profileBadgeStackView.delegate = self
			self.profileBadgeStackView.configure(for: user)
		} else {
			self.usernameLabel.text = nil
			self.profileImageView.image = nil
			self.profileBadgeStackView.reset()
		}

		self.cosmosView.rating = review.attributes.score
		self.dateTimeLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
	}

	/// Configures the cell's body with the given review.
	///
	/// - Parameters:
	///    - review: The review to configure the body with.
	///    - isElevated: Whether the review was elevated to Editor's Choice by staff.
	private func configureBody(for review: Review, isElevated: Bool) {
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

		self.bodyTextView.setAttributedText(translatedBody ?? review.attributes.description?.markdownAttributedString())
		self.spoilerOverlayView.isHidden = self.isSpoilerRevealed || !(review.attributes.isSpoiler && !(review.attributes.description ?? "").isEmpty)

		self.updateMoreView()
	}

	/// Returns the badge text shown above the given review's body.
	///
	/// - Parameters:
	///    - review: The review to build the badge text from.
	///    - isElevated: Whether the review was elevated to Editor's Choice by staff.
	///
	/// - Returns: The badge text, or `nil` when the review has no badge to show.
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

	/// Shows the `more` button while the body is clipped.
	private func updateMoreView() {
		let textContainer = self.bodyTextView.textContainer
		let isClipped: Bool

		if textContainer.maximumNumberOfLines > 0, self.bodyTextView.bounds.width > 0 {
			// Measured against an unbounded height, because the container still carries the reused cell's.
			let target = CGSize(width: self.bodyTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
			let cappedHeight = self.bodyTextView.sizeThatFits(target).height
			let fullHeight = self.bodyTextView.attributedText.boundingRect(with: target, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height

			isClipped = fullHeight.rounded() > cappedHeight.rounded()
		} else {
			isClipped = false
		}

		guard self.moreView.isHidden == isClipped else { return }
		self.moreView.isHidden = !isClipped
	}

	/// Refreshes the vote buttons for the given review.
	///
	/// - Parameter review: The review the row votes on.
	private func configureVoteRow(for review: Review) {
		let isOwnReview = User.current?.id == review.relationships?.users?.data.first?.id

		// The author keeps their own counts on screen while the vote itself is withheld.
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

	/// Adds a `UITapGestureRecognizer` which opens the profile page onto the given view.
	///
	/// - Parameter view: The view to which the tap gesture should be attached.
	private func configureProfilePageGesture(for view: UIView) {
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabelPressed(_:)))
		gestureRecognizer.numberOfTouchesRequired = 1
		gestureRecognizer.numberOfTapsRequired = 1

		view.addGestureRecognizer(gestureRecognizer)
		view.isUserInteractionEnabled = true
	}

	private func configureSubviews() {
		let headerRowView = UIStackView(arrangedSubviews: [self.usernameLabel, self.profileBadgeStackView, self.dateTimeLabel])
		headerRowView.axis = .horizontal
		headerRowView.spacing = 8.0
		headerRowView.alignment = .center
		headerRowView.setCustomSpacing(2.0, after: self.usernameLabel)

		self.voteRowView.addArrangedSubview(self.helpfulButton)
		self.voteRowView.addArrangedSubview(self.unhelpfulButton)
		self.voteRowView.addArrangedSubview(UIView())

		// The spacer soaks up any extra height, so the body stays at the top and the
		// vote row sits at the bottom.
		let spacerView = UIView()
		spacerView.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)

		let contentStackView = UIStackView(arrangedSubviews: [headerRowView, self.cosmosView, self.metadataLabel, self.bodyView, spacerView, self.voteRowView])
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.setCustomSpacing(8.0, after: self.cosmosView)

		self.translationBarView = TranslationBarView.install(in: contentStackView, at: 3, delegate: self)

		self.moreView.addSubview(self.moreGradientImageView)
		self.moreView.addSubview(self.moreButton)

		self.bodyView.addSubview(self.bodyMetricsView)
		self.bodyView.addSubview(self.bodyTextView)
		self.bodyView.addSubview(self.moreView)
		self.bodyView.addSubview(self.spoilerOverlayView)

		self.contentView.addSubview(self.profileImageView)
		self.contentView.addSubview(self.borderView)
		self.contentView.addSubview(contentStackView)

		let spacerHeightConstraint = spacerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0)
		let cosmosHeightConstraint = self.cosmosView.heightAnchor.constraint(equalToConstant: 40.0)
		cosmosHeightConstraint.priority = .defaultLow

		let profileImageDiameter = 44.0
		self.borderView.cornerRadius = profileImageDiameter / 2.0

		self.bodyBottomConstraint = self.bodyTextView.bottomAnchor.constraint(equalTo: self.bodyView.bottomAnchor)

		NSLayoutConstraint.activate([
			self.profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8.0),
			self.profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
			self.profileImageView.widthAnchor.constraint(equalToConstant: profileImageDiameter),
			self.profileImageView.heightAnchor.constraint(equalToConstant: profileImageDiameter),
			self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: self.profileImageView.bottomAnchor, constant: 8.0),

			self.borderView.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
			self.borderView.leadingAnchor.constraint(equalTo: self.profileImageView.leadingAnchor),
			self.borderView.trailingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor),
			self.borderView.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),

			contentStackView.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 8.0),
			contentStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8.0),
			contentStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
			contentStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.profileBadgeStackView.heightAnchor.constraint(equalToConstant: 20.0),
			spacerHeightConstraint,
			cosmosHeightConstraint,

			// The HIG's minimum hit target, which the title and symbol grow past on their own.
			self.helpfulButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44.0),
			self.helpfulButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0),
			self.unhelpfulButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44.0),
			self.unhelpfulButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0),

			self.bodyMetricsView.topAnchor.constraint(equalTo: self.bodyView.topAnchor),
			self.bodyMetricsView.leadingAnchor.constraint(equalTo: self.bodyView.leadingAnchor),
			self.bodyMetricsView.trailingAnchor.constraint(equalTo: self.bodyView.trailingAnchor),

			self.bodyTextView.topAnchor.constraint(equalTo: self.bodyView.topAnchor),
			self.bodyTextView.leadingAnchor.constraint(equalTo: self.bodyView.leadingAnchor),
			self.bodyTextView.trailingAnchor.constraint(equalTo: self.bodyView.trailingAnchor),
			// Closes the vertical chain from birth, so the cell self-sizes before it is configured.
			self.bodyBottomConstraint,

			// The body's last rendered line ends at the text view's bottom edge, because
			// `KTextView` zeroes both the container inset and the line fragment padding.
			self.moreView.trailingAnchor.constraint(equalTo: self.bodyTextView.trailingAnchor),
			self.moreView.bottomAnchor.constraint(equalTo: self.bodyTextView.bottomAnchor),

			self.moreGradientImageView.topAnchor.constraint(equalTo: self.moreView.topAnchor),
			self.moreGradientImageView.leadingAnchor.constraint(equalTo: self.moreView.leadingAnchor),
			self.moreGradientImageView.trailingAnchor.constraint(equalTo: self.moreView.trailingAnchor),
			self.moreGradientImageView.bottomAnchor.constraint(equalTo: self.moreView.bottomAnchor),

			// One line of the body, so the mask covers the last line rather than the button's own height.
			self.moreView.heightAnchor.constraint(equalTo: self.bodyMetricsView.heightAnchor),

			self.moreButton.centerYAnchor.constraint(equalTo: self.moreGradientImageView.centerYAnchor),
			self.moreButton.leadingAnchor.constraint(equalTo: self.moreGradientImageView.leadingAnchor, constant: 70.0),
			self.moreButton.trailingAnchor.constraint(equalTo: self.moreGradientImageView.trailingAnchor, constant: -8.0),

			self.spoilerOverlayView.topAnchor.constraint(equalTo: self.bodyTextView.topAnchor),
			self.spoilerOverlayView.leadingAnchor.constraint(equalTo: self.bodyTextView.leadingAnchor),
			self.spoilerOverlayView.trailingAnchor.constraint(equalTo: self.bodyTextView.trailingAnchor),
			self.spoilerOverlayView.bottomAnchor.constraint(equalTo: self.bodyTextView.bottomAnchor)
		])

		self.spoilerOverlayView.configure(warning: L10n.reviewSpoiler, cornerRadius: 10)
		self.spoilerOverlayView.revealHandler = { [weak self] in
			self?.isSpoilerRevealed = true
		}

		self.bodyTextView.delegate = self

		self.configureProfilePageGesture(for: self.usernameLabel)
		self.configureProfilePageGesture(for: self.profileImageView)

		self.moreButton.addTarget(self, action: #selector(self.moreButtonPressed(_:)), for: .touchUpInside)
		self.helpfulButton.addTarget(self, action: #selector(self.helpfulButtonPressed), for: .touchUpInside)
		self.unhelpfulButton.addTarget(self, action: #selector(self.unhelpfulButtonPressed), for: .touchUpInside)
	}

	// MARK: - Actions
	@objc private func usernameLabelPressed(_ sender: AnyObject) {
		self.delegate?.reviewCollectionViewCell(self, didPressUserName: sender)
	}

	@objc private func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.reviewCollectionViewCell(self, didPressMoreButton: sender)
	}

	@objc private func helpfulButtonPressed() {
		self.delegate?.reviewCollectionViewCell(self, didTapVote: .helpful)
	}

	@objc private func unhelpfulButtonPressed() {
		self.delegate?.reviewCollectionViewCell(self, didTapVote: .unhelpful)
	}
}

// MARK: - UITextViewDelegate
extension ReviewCollectionViewCell: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		guard url.absoluteString.starts(with: "https://kurozora.app/profile") else { return true }

		self.delegate?.reviewCollectionViewCell(self, didTapProfileLink: url)
		return false
	}
}

// MARK: - Measurement
extension ReviewCollectionViewCell {
	/// Returns the item that measures the given review.
	///
	/// - Parameter review: The review the item measures.
	///
	/// - Returns: The item that measures the review.
	static func measurableItem(for review: Review) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: ReviewCollectionViewCell.self) { cell in
			cell.configureCell(using: review, isElevated: review.attributes.isElevated)
		}
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
