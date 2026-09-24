//
//  ReCapComparisonLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A card comparing a top title of a year with the one of the year before.
final class ReCapComparisonLockupCollectionViewCell: ReCapCardCollectionViewCell {
	// MARK: - Properties
	override var surface: Surface {
		return .blur
	}

	/// Called with the index of the selected entry.
	var entrySelectedHandler: ((Int) -> Void)?

	/// The context menus of the compared titles.
	let contextMenuHandler = ReCapContextMenuHandler()

	/// The button that shares the card.
	let shareButton = ReCapShareButton()

	// MARK: - Views
	private let currentGradientView = ReCapGradientView()

	private let previousGradientView = ReCapGradientView()

	private let previousClipView = UIView()

	private let titleLabel = UILabel()

	private let subtitleLabel = UILabel()

	private let entryViews = [ReCapComparisonEntryView(isReversed: false), ReCapComparisonEntryView(isReversed: true)]

	private let separatorView = UIView()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.cardView.layoutIfNeeded()
		self.currentGradientView.frame = self.cardView.bounds.offsetBy(dx: 0.0, dy: -20.0)

		let previousEntryFrame = self.entryViews[1].convert(self.entryViews[1].bounds, to: self.cardView)
		self.previousClipView.frame = previousEntryFrame
		self.previousGradientView.transform = .identity
		self.previousGradientView.frame = self.previousClipView.bounds
		self.previousGradientView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
	}

	// MARK: - Functions
	private func configureView() {
		self.currentGradientView.blobs = ReCapGradientView.comparison(isPrevious: false)
		self.currentGradientView.blurRadius = { _ in 32.0 }
		self.previousGradientView.blobs = ReCapGradientView.comparison(isPrevious: true)
		self.previousGradientView.blurRadius = { _ in 32.0 }
		self.currentGradientView.clipping = .none
		self.previousGradientView.clipping = .none
		self.previousClipView.clipsToBounds = true
		self.previousClipView.isUserInteractionEnabled = false
		self.previousClipView.addSubview(self.previousGradientView)
		self.cardView.addSubview(self.currentGradientView)

		self.titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).semibold
		self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.subtitleLabel.font = UIFont.preferredFont(forTextStyle: .title2).semibold
		self.subtitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		self.separatorView.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue

		let headerStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
		headerStackView.axis = .vertical
		headerStackView.isLayoutMarginsRelativeArrangement = true
		headerStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16.0, leading: 16.0, bottom: 0.0, trailing: 16.0)

		let separatorContainerView = UIView()
		separatorContainerView.addSubview(self.separatorView)
		self.separatorView.translatesAutoresizingMaskIntoConstraints = false

		let stackView = UIStackView(arrangedSubviews: [headerStackView, self.entryViews[0], separatorContainerView, self.entryViews[1]])
		stackView.axis = .vertical
		stackView.translatesAutoresizingMaskIntoConstraints = false
		self.cardView.addSubview(stackView)
		self.cardView.insertSubview(self.previousClipView, belowSubview: stackView)
		self.cardView.addSubview(self.shareButton)

		self.contextMenuHandler.previewCornerRadius = 0.0

		for (index, entryView) in self.entryViews.enumerated() {
			entryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.entryTapped(_:))))
			self.contextMenuHandler.addInteraction(to: entryView, index: index)
		}

		NSLayoutConstraint.activate([
			self.shareButton.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor, constant: -ReCapShareButton.inset),
			self.shareButton.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -ReCapShareButton.inset),

			stackView.topAnchor.constraint(equalTo: self.cardView.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor),

			self.separatorView.topAnchor.constraint(equalTo: separatorContainerView.topAnchor),
			self.separatorView.leadingAnchor.constraint(equalTo: separatorContainerView.leadingAnchor, constant: 16.0),
			self.separatorView.trailingAnchor.constraint(equalTo: separatorContainerView.trailingAnchor),
			self.separatorView.bottomAnchor.constraint(equalTo: separatorContainerView.bottomAnchor),
			self.separatorView.heightAnchor.constraint(equalToConstant: self.hairlineWidth),
		])
	}

	/// Configures the card with the given comparison.
	///
	/// - Parameters:
	///    - comparison: The comparison the card shows.
	///    - colors: The recap colors the card is painted with.
	func configure(using comparison: ReCapComparison, colors: [UIColor]) {
		self.titleLabel.text = comparison.title
		self.subtitleLabel.text = L10n.recapComparison
		self.currentGradientView.colors = colors
		self.previousGradientView.colors = colors

		for (entryView, entry) in zip(self.entryViews, comparison.entries) {
			entryView.configure(using: entry)
		}

		self.setNeedsLayout()
	}

	@objc private func entryTapped(_ sender: UITapGestureRecognizer) {
		guard let index = sender.view?.tag else { return }
		self.entrySelectedHandler?(index)
	}
}

// MARK: - ReCapComparisonEntryView
/// A title of a comparison card.
private final class ReCapComparisonEntryView: UIView {
	// MARK: - Properties
	/// The height of the poster.
	private static let posterHeight: CGFloat = 112.0

	// MARK: - Views
	private let yearLabel = UILabel()

	private let titleLabel = UILabel()

	private let detailLabel = UILabel()

	private let posterImageView = PosterImageView(frame: .zero)

	private let posterBorderView = BorderView()

	private var posterWidthConstraint: NSLayoutConstraint!

	// MARK: - Initializers
	init(isReversed: Bool) {
		super.init(frame: .zero)
		self.sharedInit(isReversed: isReversed)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit(isReversed: false)
	}

	// MARK: - Functions
	private func sharedInit(isReversed: Bool) {
		self.isAccessibilityElement = true
		self.accessibilityTraits = .button

		self.yearLabel.font = UIFont.preferredFont(forTextStyle: .footnote).semibold
		self.yearLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.titleLabel.numberOfLines = 2
		self.detailLabel.font = UIFont.preferredFont(forTextStyle: .body)
		self.detailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.detailLabel.numberOfLines = 2

		let labelsStackView = UIStackView(arrangedSubviews: [self.yearLabel, self.titleLabel, self.detailLabel])
		labelsStackView.axis = .vertical
		labelsStackView.spacing = 4.0

		self.posterImageView.applyCornerRadius(12.0)
		self.posterImageView.layer.borderWidth = 0.0
		self.posterBorderView.cornerRadius = 12.0
		self.posterImageView.addSubview(self.posterBorderView)
		self.posterBorderView.translatesAutoresizingMaskIntoConstraints = false
		self.posterBorderView.fillToSuperview()
		self.posterImageView.setContentHuggingPriority(.required, for: .horizontal)
		self.posterImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

		let arrangedSubviews: [UIView] = isReversed ? [self.posterImageView, labelsStackView] : [labelsStackView, self.posterImageView]
		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = 16.0
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: isReversed ? 24.0 : 32.0, leading: 16.0, bottom: isReversed ? 32.0 : 24.0, trailing: 16.0)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(stackView)
		stackView.fillToSuperview()

		if isReversed {
			let spacerView = UIView()
			spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			stackView.addArrangedSubview(spacerView)
		} else {
			labelsStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		}

		self.posterWidthConstraint = self.posterImageView.widthAnchor.constraint(equalToConstant: Self.posterHeight * 3.0 / 4.23)

		NSLayoutConstraint.activate([
			self.posterImageView.heightAnchor.constraint(equalToConstant: Self.posterHeight),
			self.posterWidthConstraint,
		])
	}

	/// Configures the view with the given entry.
	///
	/// - Parameter entry: The entry the view shows.
	func configure(using entry: ReCapComparison.Entry) {
		self.yearLabel.text = String(entry.year)
		self.detailLabel.text = entry.detail
		self.detailLabel.isHidden = entry.detail == nil
		self.posterImageView.image = nil

		switch entry.model {
		case let show as Show:
			self.titleLabel.text = show.attributes.title
			self.posterImageView.backgroundColor = show.attributes.poster?.backgroundColor.flatMap { UIColor(hexString: $0) }
			self.posterWidthConstraint.constant = Self.posterHeight * 3.0 / 4.23
			show.attributes.posterImage(imageView: self.posterImageView)
		case let literature as Literature:
			self.titleLabel.text = literature.attributes.title
			self.posterImageView.backgroundColor = literature.attributes.poster?.backgroundColor.flatMap { UIColor(hexString: $0) }
			self.posterWidthConstraint.constant = Self.posterHeight * 3.0 / 4.23
			literature.attributes.posterImage(imageView: self.posterImageView)
		case let game as Game:
			self.titleLabel.text = game.attributes.title
			self.posterImageView.backgroundColor = game.attributes.poster?.backgroundColor.flatMap { UIColor(hexString: $0) }
			self.posterWidthConstraint.constant = Self.posterHeight
			game.attributes.posterImage(imageView: self.posterImageView)
		default:
			self.titleLabel.text = nil
		}

		self.accessibilityLabel = [self.yearLabel.text, self.titleLabel.text, entry.detail].compactMap { $0 }.joined(separator: ", ")
	}
}
