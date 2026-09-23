//
//  ReCapTitleLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A title of a Re:CAP ranking stacked in a two-row column.
final class ReCapTitleLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - Properties
	/// The width of the poster.
	private static let posterWidth: CGFloat = 100.0

	/// The space between the parts of the cell.
	private static let spacing: CGFloat = 8.0

	/// The height the separator adds above the lower cell of a column.
	static let separatorHeight: CGFloat = ReCapTitleLockupCollectionViewCell.spacing * 2.0 + 1.0

	// MARK: - Views
	private let separatorView = UIView()

	private let favoriteImageView = UIImageView(image: UIImage(systemName: "heart.fill"))

	private let posterImageView = PosterImageView(frame: .zero)

	private let posterBorderView = BorderView()

	private let literatureMask = UIImageView(image: .bookMask)

	private let literatureOverlayImageView = UIImageView(image: UIImage(named: "book.texture"))

	private let eyebrowLabel = UILabel()

	private let primaryLabel = UILabel()

	private let detailLabel = UILabel()

	private let secondaryLabel = UILabel()

	private let tertiaryLabel = UILabel()

	private var posterHeightConstraint: NSLayoutConstraint!

	private var contentTopConstraint: NSLayoutConstraint!

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		if self.posterImageView.mask === self.literatureMask {
			self.literatureMask.frame = self.posterImageView.bounds
		}
	}

	// MARK: - Functions
	private func sharedInit() {
		self.clipsToBounds = false
		self.contentView.clipsToBounds = false

		self.separatorView.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
		self.separatorView.translatesAutoresizingMaskIntoConstraints = false

		self.favoriteImageView.theme_tintColor = KThemePicker.tintColor.rawValue
		self.favoriteImageView.contentMode = .scaleAspectFit
		self.favoriteImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10.0, weight: .semibold)
		self.favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
		self.favoriteImageView.accessibilityLabel = L10n.recapFavorited

		self.posterImageView.translatesAutoresizingMaskIntoConstraints = false
		self.posterImageView.applyCornerRadius(22.0)
		self.posterImageView.layer.borderWidth = 0.0
		self.posterBorderView.cornerRadius = 22.0
		self.posterBorderView.translatesAutoresizingMaskIntoConstraints = false
		self.literatureOverlayImageView.translatesAutoresizingMaskIntoConstraints = false
		self.literatureOverlayImageView.contentMode = .scaleToFill

		self.eyebrowLabel.font = UIFont.preferredFont(forTextStyle: .footnote).semibold
		self.eyebrowLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.primaryLabel.font = UIFont.preferredFont(forTextStyle: .body)
		self.primaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.primaryLabel.numberOfLines = 2
		self.detailLabel.font = UIFont.preferredFont(forTextStyle: .caption1).semibold
		self.detailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.secondaryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
		self.secondaryLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.secondaryLabel.numberOfLines = 2
		self.tertiaryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
		self.tertiaryLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.tertiaryLabel.numberOfLines = 2

		let labelsStackView = UIStackView(arrangedSubviews: [self.eyebrowLabel, self.primaryLabel, self.detailLabel, self.secondaryLabel, self.tertiaryLabel])
		labelsStackView.axis = .vertical
		labelsStackView.spacing = 2.0
		labelsStackView.setCustomSpacing(4.0, after: self.detailLabel)
		labelsStackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(self.separatorView)
		self.contentView.addSubview(self.favoriteImageView)
		self.contentView.addSubview(self.posterImageView)
		self.contentView.addSubview(self.literatureOverlayImageView)
		self.contentView.addSubview(self.posterBorderView)
		self.contentView.addSubview(labelsStackView)

		self.posterHeightConstraint = self.posterImageView.heightAnchor.constraint(equalToConstant: Self.posterWidth * 1.5)
		self.contentTopConstraint = self.posterImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor)
		let bottomConstraint = self.posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor)
		let labelsBottomConstraint = labelsStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor)
		let fittingConstraint = self.posterImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
		fittingConstraint.priority = .defaultLow

		NSLayoutConstraint.activate([
			self.separatorView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Self.spacing),
			self.separatorView.leadingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor, constant: Self.spacing),
			self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.separatorView.heightAnchor.constraint(equalToConstant: self.hairlineWidth),

			self.favoriteImageView.trailingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: -1.0),
			self.favoriteImageView.centerYAnchor.constraint(equalTo: self.posterImageView.centerYAnchor),
			self.favoriteImageView.widthAnchor.constraint(equalToConstant: 8.0),

			self.contentTopConstraint,
			self.posterImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.posterImageView.widthAnchor.constraint(equalToConstant: Self.posterWidth),
			self.posterHeightConstraint,
			bottomConstraint,
			fittingConstraint,

			self.literatureOverlayImageView.topAnchor.constraint(equalTo: self.posterImageView.topAnchor),
			self.literatureOverlayImageView.leadingAnchor.constraint(equalTo: self.posterImageView.leadingAnchor),
			self.literatureOverlayImageView.trailingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor),
			self.literatureOverlayImageView.bottomAnchor.constraint(equalTo: self.posterImageView.bottomAnchor),

			self.posterBorderView.topAnchor.constraint(equalTo: self.posterImageView.topAnchor),
			self.posterBorderView.leadingAnchor.constraint(equalTo: self.posterImageView.leadingAnchor),
			self.posterBorderView.trailingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor),
			self.posterBorderView.bottomAnchor.constraint(equalTo: self.posterImageView.bottomAnchor),

			labelsStackView.topAnchor.constraint(equalTo: self.posterImageView.topAnchor),
			labelsStackView.leadingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor, constant: Self.spacing),
			labelsStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			labelsBottomConstraint,
		])
	}

	/// Configures the cell with the given show.
	///
	/// - Parameters:
	///    - show: The show the cell displays.
	///    - rank: The rank of the show.
	///    - eyebrow: The text shown in place of the rank.
	///    - detail: The measure spent on the show.
	///    - showsSeparator: Whether the cell is the lower one of its column.
	func configure(using show: Show?, rank: Int?, eyebrow: String? = nil, detail: String?, showsSeparator: Bool) {
		guard let show else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.configure(
			title: show.attributes.title,
			subtitle: (show.attributes.tagline ?? "").isEmpty ? show.attributes.genres?.localizedJoined() : show.attributes.tagline,
			rating: show.attributes.tvRating.name,
			rank: rank,
			eyebrow: eyebrow,
			detail: detail,
			isFavorited: LibraryStore.shared.effectiveLibrary(forTrackableID: show.id.rawValue, kind: .shows)?.isFavorited ?? false,
			showsSeparator: showsSeparator
		)
		self.configurePoster(isSquare: false, isBook: false, backgroundColor: show.attributes.poster?.backgroundColor)
		show.attributes.posterImage(imageView: self.posterImageView)
	}

	/// Configures the cell with the given literature.
	///
	/// - Parameters:
	///    - literature: The literature the cell displays.
	///    - rank: The rank of the literature.
	///    - eyebrow: The text shown in place of the rank.
	///    - detail: The measure spent on the literature.
	///    - showsSeparator: Whether the cell is the lower one of its column.
	func configure(using literature: Literature?, rank: Int?, eyebrow: String? = nil, detail: String?, showsSeparator: Bool) {
		guard let literature else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.configure(
			title: literature.attributes.title,
			subtitle: (literature.attributes.tagline ?? "").isEmpty ? literature.attributes.genres?.localizedJoined() : literature.attributes.tagline,
			rating: literature.attributes.tvRating.name,
			rank: rank,
			eyebrow: eyebrow,
			detail: detail,
			isFavorited: LibraryStore.shared.effectiveLibrary(forTrackableID: literature.id.rawValue, kind: .literatures)?.isFavorited ?? false,
			showsSeparator: showsSeparator
		)
		self.configurePoster(isSquare: false, isBook: true, backgroundColor: literature.attributes.poster?.backgroundColor)
		literature.attributes.posterImage(imageView: self.posterImageView)
	}

	/// Configures the cell with the given game.
	///
	/// - Parameters:
	///    - game: The game the cell displays.
	///    - rank: The rank of the game.
	///    - eyebrow: The text shown in place of the rank.
	///    - detail: The measure spent on the game.
	///    - showsSeparator: Whether the cell is the lower one of its column.
	func configure(using game: Game?, rank: Int?, eyebrow: String? = nil, detail: String?, showsSeparator: Bool) {
		guard let game else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.configure(
			title: game.attributes.title,
			subtitle: (game.attributes.tagline ?? "").isEmpty ? game.attributes.genres?.localizedJoined() : game.attributes.tagline,
			rating: game.attributes.tvRating.name,
			rank: rank,
			eyebrow: eyebrow,
			detail: detail,
			isFavorited: LibraryStore.shared.effectiveLibrary(forTrackableID: game.id.rawValue, kind: .games)?.isFavorited ?? false,
			showsSeparator: showsSeparator
		)
		self.configurePoster(isSquare: true, isBook: false, backgroundColor: game.attributes.poster?.backgroundColor)
		game.attributes.posterImage(imageView: self.posterImageView)
	}

	/// Configures the labels and accessories of the cell.
	private func configure(title: String, subtitle: String?, rating: String, rank: Int?, eyebrow: String?, detail: String?, isFavorited: Bool, showsSeparator: Bool) {
		if let eyebrow {
			self.eyebrowLabel.text = eyebrow.uppercased(with: LanguageManager.shared.locale)
			self.eyebrowLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		} else {
			self.eyebrowLabel.text = rank.map { "#\($0)" }
			self.eyebrowLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
		self.eyebrowLabel.isHidden = self.eyebrowLabel.text == nil

		self.primaryLabel.text = title
		self.detailLabel.text = detail
		self.detailLabel.isHidden = detail == nil
		self.secondaryLabel.text = subtitle
		self.secondaryLabel.isHidden = (subtitle ?? "").isEmpty
		self.tertiaryLabel.text = rating

		self.favoriteImageView.isHidden = !isFavorited
		self.separatorView.isHidden = !showsSeparator
		self.contentTopConstraint.constant = showsSeparator ? Self.separatorHeight : 0.0
	}

	/// Shapes the poster for the kind of title the cell displays.
	private func configurePoster(isSquare: Bool, isBook: Bool, backgroundColor: String?) {
		self.posterHeightConstraint.constant = isSquare ? Self.posterWidth : Self.posterWidth * 1.5
		self.posterImageView.backgroundColor = backgroundColor.flatMap { UIColor(hexString: $0) }

		if isBook {
			self.posterImageView.applyCornerRadius(0.0)
			self.posterImageView.mask = self.literatureMask
			self.literatureMask.frame = self.posterImageView.bounds
		} else {
			self.posterImageView.applyCornerRadius(22.0)
			self.posterImageView.mask = nil
		}

		self.literatureOverlayImageView.isHidden = !isBook
		self.posterBorderView.isHidden = isBook
	}
}
