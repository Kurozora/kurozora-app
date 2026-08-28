//
//  TrailerFeaturedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Cosmos
import KurozoraKit
import UIKit

/// Reports interactions with the featured trailer cell.
protocol TrailerFeaturedCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the reader pressed the featured title's library button.
	///
	/// - Parameters:
	///    - cell: The cell whose button was pressed.
	///    - button: The button that was pressed.
	func trailerFeaturedCollectionViewCell(_ cell: TrailerFeaturedCollectionViewCell, didPressAdd button: UIButton) async
}

/// A cell that leads the page with the featured trailer and its details.
class TrailerFeaturedCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	/// The container the featured player is placed into.
	let playerContainer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layerCornerRadius = 16.0
		view.layer.masksToBounds = true
		return view
	}()

	/// The featured title.
	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .title2).bold
		label.numberOfLines = 2
		return label
	}()

	/// The featured title's genres.
	private let genreLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.numberOfLines = 1
		return label
	}()

	/// The featured title's synopsis.
	private let synopsisLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .callout)
		label.numberOfLines = 0
		return label
	}()

	/// The featured title's average rating.
	private let scoreLabel: KTintedLabel = {
		let label = KTintedLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote).bold
		return label
	}()

	/// The stars showing the featured title's average rating.
	private let scoreView: KCosmosView = {
		var settings = CosmosSettings()
		settings.updateOnTouch = false
		settings.starSize = 16.0

		let cosmosView = KCosmosView(frame: .zero, settings: settings)
		cosmosView.translatesAutoresizingMaskIntoConstraints = false
		cosmosView.isUserInteractionEnabled = false
		return cosmosView
	}()

	/// The featured title's poster.
	private let posterImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layerCornerRadius = 8.0
		return imageView
	}()

	/// The button that puts the featured title in the library.
	private let addButton: KTintedButton = {
		let button = KTintedButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .medium)
		button.layerCornerRadius = 15.0
		return button
	}()

	/// The stack arranging the player beside or above the details.
	private let contentStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 16.0
		stackView.alignment = .top
		return stackView
	}()

	/// The placeholder shown in place of the player until the trailer's picture is up.
	private let playerSkeletonView = TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 16.0)

	/// The placeholder shown in place of the poster while the title loads.
	private let posterSkeletonView = TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 8.0)

	/// The placeholder shown in place of the title while it loads.
	private let titleSkeletonView = TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 6.0)

	/// The placeholder shown in place of the genres while they load.
	private let genreSkeletonView = TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 6.0)

	/// The placeholder shown in place of the library button while the title loads.
	private let addButtonSkeletonView = TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 15.0)

	/// The placeholders shown in place of the synopsis while it loads.
	private let synopsisSkeletonViews = [
		TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 6.0),
		TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 6.0),
		TrailerFeaturedCollectionViewCell.makeSkeletonView(cornerRadius: 6.0)
	]

	// MARK: - Properties
	override var isSkeletonEnabled: Bool { false }

	/// The object responsible for delegating interactions.
	weak var delegate: TrailerFeaturedCollectionViewCellDelegate?

	/// The kind of library the featured title belongs to.
	private(set) var libraryKind: LibraryKind = .shows

	/// The width the player takes beside the details on wide layouts.
	private var playerWidthConstraint: NSLayoutConstraint?

	/// The height reserved for the synopsis placeholders while the synopsis loads.
	private var synopsisPlaceholderConstraint: NSLayoutConstraint?

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

		self.applyResponsiveLayout(forWidth: self.bounds.width)
	}

	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		// The layout switch lands before the self-sizing pass, or the cell keeps its old height.
		self.applyResponsiveLayout(forWidth: layoutAttributes.size.width)
		return super.preferredLayoutAttributesFitting(layoutAttributes)
	}

	/// Configures the cell's view hierarchy and layout.
	private func sharedInit() {
		self.addButton.addTarget(self, action: #selector(self.addButtonPressed(_:)), for: .touchUpInside)
		self.addButton.setContentHuggingPriority(.required, for: .horizontal)
		self.addButton.setContentCompressionResistancePriority(.required, for: .horizontal)

		let ratingStackView = UIStackView(arrangedSubviews: [self.scoreLabel, self.scoreView, UIView()])
		ratingStackView.axis = .horizontal
		ratingStackView.spacing = 6.0
		ratingStackView.alignment = .center

		let buttonStackView = UIStackView(arrangedSubviews: [self.addButton, UIView()])
		buttonStackView.axis = .horizontal

		let infoStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.genreLabel, ratingStackView, UIView(), buttonStackView])
		infoStackView.axis = .vertical
		infoStackView.spacing = 4.0

		let headerStackView = UIStackView(arrangedSubviews: [self.posterImageView, infoStackView])
		headerStackView.axis = .horizontal
		headerStackView.spacing = 12.0
		headerStackView.alignment = .top

		let detailsStackView = UIStackView(arrangedSubviews: [headerStackView, self.synopsisLabel])
		detailsStackView.axis = .vertical
		detailsStackView.spacing = 8.0
		detailsStackView.alignment = .fill

		self.contentStackView.addArrangedSubview(self.playerContainer)
		self.contentStackView.addArrangedSubview(detailsStackView)
		self.contentView.addSubview(self.contentStackView)

		let playerWidthConstraint = self.playerContainer.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor, multiplier: 0.6)
		self.playerWidthConstraint = playerWidthConstraint

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20.0),

			self.playerContainer.heightAnchor.constraint(equalTo: self.playerContainer.widthAnchor, multiplier: 9.0 / 16.0),

			self.posterImageView.widthAnchor.constraint(equalToConstant: 90.0),
			self.posterImageView.heightAnchor.constraint(equalTo: self.posterImageView.widthAnchor, multiplier: 3.0 / 2.0),

			infoStackView.heightAnchor.constraint(greaterThanOrEqualTo: self.posterImageView.heightAnchor),

			self.addButton.heightAnchor.constraint(equalToConstant: 30.0),
			self.addButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 84.0)
		])

		self.configureSkeletonViews(infoStackView: infoStackView)
		self.applyResponsiveLayout(forWidth: self.bounds.width)
	}

	/// Places a placeholder over each detail that loads in.
	///
	/// - Parameter infoStackView: The column holding the title details.
	private func configureSkeletonViews(infoStackView: UIStackView) {
		self.contentView.addSubview(self.playerSkeletonView)
		self.contentView.addSubview(self.posterSkeletonView)
		self.contentView.addSubview(self.titleSkeletonView)
		self.contentView.addSubview(self.genreSkeletonView)
		self.contentView.addSubview(self.addButtonSkeletonView)
		self.synopsisSkeletonViews.forEach { self.contentView.addSubview($0) }

		let synopsisPlaceholderConstraint = self.synopsisLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 64.0)
		self.synopsisPlaceholderConstraint = synopsisPlaceholderConstraint

		NSLayoutConstraint.activate([
			self.playerSkeletonView.topAnchor.constraint(equalTo: self.playerContainer.topAnchor),
			self.playerSkeletonView.leadingAnchor.constraint(equalTo: self.playerContainer.leadingAnchor),
			self.playerSkeletonView.trailingAnchor.constraint(equalTo: self.playerContainer.trailingAnchor),
			self.playerSkeletonView.bottomAnchor.constraint(equalTo: self.playerContainer.bottomAnchor),

			self.posterSkeletonView.topAnchor.constraint(equalTo: self.posterImageView.topAnchor),
			self.posterSkeletonView.leadingAnchor.constraint(equalTo: self.posterImageView.leadingAnchor),
			self.posterSkeletonView.trailingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor),
			self.posterSkeletonView.bottomAnchor.constraint(equalTo: self.posterImageView.bottomAnchor),

			self.titleSkeletonView.topAnchor.constraint(equalTo: infoStackView.topAnchor, constant: 2.0),
			self.titleSkeletonView.leadingAnchor.constraint(equalTo: infoStackView.leadingAnchor),
			self.titleSkeletonView.widthAnchor.constraint(equalTo: infoStackView.widthAnchor, multiplier: 0.5),
			self.titleSkeletonView.heightAnchor.constraint(equalToConstant: 20.0),

			self.genreSkeletonView.topAnchor.constraint(equalTo: self.titleSkeletonView.bottomAnchor, constant: 8.0),
			self.genreSkeletonView.leadingAnchor.constraint(equalTo: infoStackView.leadingAnchor),
			self.genreSkeletonView.widthAnchor.constraint(equalTo: infoStackView.widthAnchor, multiplier: 0.35),
			self.genreSkeletonView.heightAnchor.constraint(equalToConstant: 14.0),

			self.addButtonSkeletonView.topAnchor.constraint(equalTo: self.addButton.topAnchor),
			self.addButtonSkeletonView.leadingAnchor.constraint(equalTo: self.addButton.leadingAnchor),
			self.addButtonSkeletonView.trailingAnchor.constraint(equalTo: self.addButton.trailingAnchor),
			self.addButtonSkeletonView.bottomAnchor.constraint(equalTo: self.addButton.bottomAnchor),

			self.synopsisSkeletonViews[0].topAnchor.constraint(equalTo: self.synopsisLabel.topAnchor, constant: 2.0),
			self.synopsisSkeletonViews[0].leadingAnchor.constraint(equalTo: self.synopsisLabel.leadingAnchor),
			self.synopsisSkeletonViews[0].trailingAnchor.constraint(equalTo: self.synopsisLabel.trailingAnchor),
			self.synopsisSkeletonViews[0].heightAnchor.constraint(equalToConstant: 12.0),

			self.synopsisSkeletonViews[1].topAnchor.constraint(equalTo: self.synopsisSkeletonViews[0].bottomAnchor, constant: 8.0),
			self.synopsisSkeletonViews[1].leadingAnchor.constraint(equalTo: self.synopsisLabel.leadingAnchor),
			self.synopsisSkeletonViews[1].trailingAnchor.constraint(equalTo: self.synopsisLabel.trailingAnchor),
			self.synopsisSkeletonViews[1].heightAnchor.constraint(equalToConstant: 12.0),

			self.synopsisSkeletonViews[2].topAnchor.constraint(equalTo: self.synopsisSkeletonViews[1].bottomAnchor, constant: 8.0),
			self.synopsisSkeletonViews[2].leadingAnchor.constraint(equalTo: self.synopsisLabel.leadingAnchor),
			self.synopsisSkeletonViews[2].widthAnchor.constraint(equalTo: self.synopsisLabel.widthAnchor, multiplier: 0.6),
			self.synopsisSkeletonViews[2].heightAnchor.constraint(equalToConstant: 12.0),

			synopsisPlaceholderConstraint
		])
	}

	/// Shows or hides the loading placeholders over the details.
	///
	/// - Parameter isVisible: Whether the placeholders are shown.
	func setDetailsSkeletonVisible(_ isVisible: Bool) {
		let skeletonViews = [self.posterSkeletonView, self.titleSkeletonView, self.genreSkeletonView, self.addButtonSkeletonView] + self.synopsisSkeletonViews
		skeletonViews.forEach { $0.isHidden = !isVisible }
		self.synopsisPlaceholderConstraint?.isActive = isVisible
	}

	/// Shows or hides the loading placeholder over the player.
	///
	/// - Parameter isVisible: Whether the placeholder is shown.
	func setPlayerSkeletonVisible(_ isVisible: Bool) {
		guard (self.playerSkeletonView.alpha == 0.0) == isVisible else { return }

		UIView.animate(withDuration: 0.25) {
			self.playerSkeletonView.alpha = isVisible ? 1.0 : 0.0
		}
	}

	/// Switches between the side-by-side and stacked layouts for the given width.
	///
	/// - Parameter width: The width the cell lays out in.
	private func applyResponsiveLayout(forWidth width: CGFloat) {
		let wideLayoutMinimumWidth: CGFloat = 1200.0
		let isWide = width >= wideLayoutMinimumWidth
		let axisMatches = isWide == (self.contentStackView.axis == .horizontal)
		let constraintMatches = isWide == (self.playerWidthConstraint?.isActive ?? false)
		guard !axisMatches || !constraintMatches else { return }

		self.playerWidthConstraint?.isActive = false
		self.contentStackView.axis = isWide ? .horizontal : .vertical
		self.contentStackView.alignment = isWide ? .top : .fill
		self.playerWidthConstraint?.isActive = isWide
	}

	// MARK: - Functions
	/// Configures the cell with the given show.
	///
	/// - Parameter show: The show to display.
	func configure(using show: Show?) {
		guard let show = show else { return }

		self.setDetailsSkeletonVisible(false)
		self.libraryKind = .shows
		self.titleLabel.text = show.attributes.title
		self.genreLabel.text = show.attributes.genres?.localizedJoined()
		self.synopsisLabel.text = show.attributes.synopsis
		show.attributes.posterImage(imageView: self.posterImageView)
		self.updateScore(withAverage: show.attributes.stats?.ratingAverage)
		self.updateLibraryButton(status: show.libraryAttributes?.status)
	}

	/// Configures the cell with the given game.
	///
	/// - Parameter game: The game to display.
	func configure(using game: Game?) {
		guard let game = game else { return }

		self.setDetailsSkeletonVisible(false)
		self.libraryKind = .games
		self.titleLabel.text = game.attributes.title
		self.genreLabel.text = game.attributes.genres?.localizedJoined()
		self.synopsisLabel.text = game.attributes.synopsis
		game.attributes.posterImage(imageView: self.posterImageView)
		self.updateScore(withAverage: game.attributes.stats?.ratingAverage)
		self.updateLibraryButton(status: game.libraryAttributes?.status)
	}

	/// Updates the score views for the given average rating.
	///
	/// - Parameter ratingAverage: The title's average rating.
	private func updateScore(withAverage ratingAverage: Double?) {
		let ratingAverage = ratingAverage ?? 0.0

		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"
		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0
	}

	/// Updates the library button for the given status.
	///
	/// - Parameter status: The title's library status.
	func updateLibraryButton(status: LibraryStatus?) {
		let status = status ?? .none

		if status == .none {
			self.addButton.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
			return
		}

		let title: String
		switch self.libraryKind {
		case .shows: title = status.showStringValue
		case .literatures: title = status.literatureStringValue
		case .games: title = status.gameStringValue
		}
		self.addButton.setTitle("\(title.capitalized(with: Locale.current)) ▾", for: .normal)
	}

	/// Builds a placeholder view shown while content loads.
	///
	/// - Parameter cornerRadius: The placeholder's corner radius.
	///
	/// - Returns: A configured view.
	private static func makeSkeletonView(cornerRadius: CGFloat) -> UIView {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		view.isUserInteractionEnabled = false
		view.layerCornerRadius = cornerRadius
		view.layer.cornerCurve = .continuous
		return view
	}

	/// Notifies the delegate that the library button was pressed.
	///
	/// - Parameter sender: The button that was pressed.
	@objc private func addButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.trailerFeaturedCollectionViewCell(self, didPressAdd: sender)
		}
	}
}
