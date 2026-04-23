//
//  LibraryTableCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Cosmos
import KurozoraKit
import SwiftTheme
import UIKit

protocol LibraryTableCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate that the user tapped the cell's favorite affordance.
	///
	/// - Parameters:
	///    - cell: The cell that emitted the event.
	///    - indexPath: The index path of the row whose favorite state should toggle.
	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleFavoriteAt indexPath: IndexPath)

	/// Tells the delegate that the user tapped the cell's reminder affordance.
	///
	/// - Parameters:
	///    - cell: The cell that emitted the event.
	///    - indexPath: The index path of the row whose reminder state should toggle.
	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleReminderAt indexPath: IndexPath)

	/// Tells the delegate that the user finished rating the cell's item.
	///
	/// - Parameters:
	///    - cell: The cell that emitted the event.
	///    - rating: The new rating value in stars.
	///    - indexPath: The index path of the row whose rating changed.
	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didUpdateRating rating: Double, at indexPath: IndexPath)
}

class LibraryTableCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let stackView = UIStackView()
	private let selectionImageOverlayView = UIImageView()
	private let rowDivider = UIView()

	private var columnOrder: [LibraryColumn] = []
	private var columnContainers: [LibraryColumn: UIView] = [:]
	private var columnWidthConstraints: [LibraryColumn: NSLayoutConstraint] = [:]

	private weak var titleLabel: UILabel?
	private weak var posterImageView: PosterImageView?
	private weak var posterImageOverlayView: UIImageView?
	private var posterAspectRatioConstraint: NSLayoutConstraint?
	private weak var inlineCosmosView: KCosmosView?
	private weak var inlineFavoriteButton: UIButton?
	private weak var inlineReminderButton: UIButton?
	private var rowDividerLeadingConstraint: NSLayoutConstraint?

	private lazy var literatureMask: UIImageView = {
		UIImageView(image: UIImage(named: "book_mask"))
	}()

	private var posterBoundsObservation: NSKeyValueObservation?

	private var lastShowPoster: Bool?
	private var lastKind: LibraryKind?

	// MARK: - Properties
	private static let primaryLabelTag = 1
	private static let posterTag = 2
	private static let buttonValueTag = 3
	private static let cosmosValueTag = 4

	/// The vertical padding applied inside every column's container.
	static let rowVerticalPadding: CGFloat = 10

	/// The rendered width of the inline poster, uniform across library kinds.
	private static let posterWidth: CGFloat = 80

	/// The index path the cell currently represents.
	private(set) var indexPath: IndexPath?

	/// The object that receives toggle and rating callbacks from the cell.
	weak var delegate: LibraryTableCollectionViewCellDelegate?

	/// A Boolean value that indicates whether the cell renders its selection indicator.
	var showSelectionIcon: Bool = false

	override var isSelected: Bool {
		didSet {
			self.setNeedsLayout()
		}
	}

	// MARK: - Initialization
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.showSelectionIcon = false
		self.indexPath = nil
		self.delegate = nil
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.selectionImageOverlayView.isHidden = !self.showSelectionIcon
		self.selectionImageOverlayView.image = self.isSelected
			? UIImage(systemName: "checkmark.circle.fill")
			: UIImage(systemName: "circle")

		self.syncLiteratureMaskFrame()
	}

	// MARK: - Configuration
	/// Populates the cell with data drawn from the given library item.
	///
	/// - Parameters:
	///    - item: The library item to render.
	///    - kind: The library kind the item belongs to.
	///    - columns: The visible columns paired with their current widths, in left-to-right order.
	///    - showPoster: A Boolean that indicates whether the title cell renders a poster with inline metadata.
	///    - showSelectionIcon: A Boolean that indicates whether the cell renders its selection indicator.
	///    - isLastRow: A Boolean that indicates whether the cell is the last row in its section. When `true`, the bottom row divider is hidden.
	///    - indexPath: The index path of the row. Relayed to the delegate on interactive events.
	///    - delegate: The object that receives favorite, reminder, and rating callbacks.
	func configure(
		using item: LibraryListCollectionViewController.ItemKind,
		kind: LibraryKind,
		columns: [(column: LibraryColumn, width: CGFloat)],
		showPoster: Bool,
		showSelectionIcon: Bool,
		isLastRow: Bool,
		indexPath: IndexPath,
		delegate: LibraryTableCollectionViewCellDelegate?
	) {
		self.indexPath = indexPath
		self.delegate = delegate

		let columnIdentities = columns.map(\.column)
		let needsRebuild = columnIdentities != self.columnOrder
			|| showPoster != self.lastShowPoster
			|| kind != self.lastKind

		if needsRebuild {
			self.rebuildColumnContainers(for: columnIdentities, showPoster: showPoster, kind: kind)
			self.lastShowPoster = showPoster
			self.lastKind = kind
		}

		self.applyWidths(columns)
		self.populate(item: item, kind: kind, columns: columnIdentities, showPoster: showPoster)

		self.rowDivider.isHidden = isLastRow
		self.showSelectionIcon = showSelectionIcon
		self.setNeedsLayout()
	}

	// MARK: - Auto-fit
	/// Returns the minimum width that fits the column's content as currently rendered.
	///
	/// Measures the underlying label's `intrinsicContentSize` directly rather than asking the
	/// container. `systemLayoutSizeFitting` returns the already-constrained width and prevents
	/// a true fit-to-content measurement.
	///
	/// - Parameter column: The column whose content width to measure.
	///
	/// - Returns: The content width in points, including horizontal padding.
	func contentWidth(for column: LibraryColumn) -> CGFloat {
		switch column {
		case .favorite, .reminder:
			return column.defaultWidth
		case .rating:
			return column.defaultWidth
		case .title:
			let labelWidth = self.titleLabel?.intrinsicContentSize.width ?? 0
			if self.lastShowPoster == true {
				// leading padding + poster + spacing + label + trailing padding.
				return 8 + Self.posterWidth + 12 + ceil(labelWidth) + 8
			}
			return ceil(labelWidth) + 16
		default:
			guard
				let container = self.columnContainers[column],
				let label = container.viewWithTag(Self.primaryLabelTag) as? UILabel
			else {
				return column.defaultWidth
			}
			return ceil(label.intrinsicContentSize.width) + 16
		}
	}

	// MARK: - Helpers
	private func configureView() {
		self.contentView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		self.stackView.axis = .horizontal
		self.stackView.alignment = .fill
		self.stackView.distribution = .fill
		self.stackView.spacing = 0
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.stackView)

		self.selectionImageOverlayView.contentMode = .center
		self.selectionImageOverlayView.theme_tintColor = KThemePicker.tintColor.rawValue
		self.selectionImageOverlayView.isHidden = true
		self.selectionImageOverlayView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.selectionImageOverlayView)

		self.rowDivider.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		self.rowDivider.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.rowDivider)

		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.selectionImageOverlayView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
			self.selectionImageOverlayView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.selectionImageOverlayView.widthAnchor.constraint(equalToConstant: 22),
			self.selectionImageOverlayView.heightAnchor.constraint(equalToConstant: 22),

			self.rowDivider.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.rowDivider.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.rowDivider.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
		])
	}

	private func rebuildColumnContainers(for columns: [LibraryColumn], showPoster: Bool, kind: LibraryKind) {
		self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		self.columnContainers.removeAll()
		self.columnWidthConstraints.removeAll()
		self.columnOrder = columns
		self.titleLabel = nil
		self.posterImageView = nil
		self.posterImageOverlayView = nil
		self.posterAspectRatioConstraint = nil
		self.inlineCosmosView = nil
		self.inlineFavoriteButton = nil
		self.inlineReminderButton = nil
		self.posterBoundsObservation = nil
		self.rowDividerLeadingConstraint?.isActive = false
		self.rowDividerLeadingConstraint = nil

		for (index, column) in columns.enumerated() {
			let container = self.makeContainer(for: column, showPoster: showPoster, kind: kind)
			self.stackView.addArrangedSubview(container)
			self.columnContainers[column] = container

			let isLast = index == columns.count - 1
			let widthConstraint = container.widthAnchor.constraint(equalToConstant: column.defaultWidth)
			if isLast {
				widthConstraint.priority = .defaultHigh
				container.setContentHuggingPriority(.defaultLow, for: .horizontal)
			} else {
				widthConstraint.priority = .required
			}
			widthConstraint.isActive = true
			self.columnWidthConstraints[column] = widthConstraint
		}

		if let titleLabel = self.titleLabel {
			let leading = self.rowDivider.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
			leading.isActive = true
			self.rowDividerLeadingConstraint = leading
		} else {
			let leading = self.rowDivider.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16)
			leading.isActive = true
			self.rowDividerLeadingConstraint = leading
		}
	}

	private func applyWidths(_ columns: [(column: LibraryColumn, width: CGFloat)]) {
		for pair in columns {
			self.columnWidthConstraints[pair.column]?.constant = pair.width
		}
	}

	private func makeContainer(for column: LibraryColumn, showPoster: Bool, kind: LibraryKind) -> UIView {
		switch column {
		case .title:
			return showPoster ? self.makeRichTitleContainer(for: kind) : self.makePlainTitleContainer()
		case .favorite:
			return self.makeTintButtonContainer(action: #selector(self.didTapFavoriteStandalone), accessibilityLabel: L10n.favorite)
		case .reminder:
			return self.makeTintButtonContainer(action: #selector(self.didTapReminderStandalone), accessibilityLabel: L10n.reminder)
		case .rating:
			return self.makeRatingColumnContainer()
		default:
			return self.makeLabelContainer(textStyle: .footnote, using: KSecondaryLabel())
		}
	}

	private func makePlainTitleContainer() -> UIView {
		let container = UIView()
		let label = KLabel()
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.adjustsFontForContentSizeCategory = true
		label.lineBreakMode = .byTruncatingTail
		label.numberOfLines = 1
		label.tag = Self.primaryLabelTag
		label.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(label)

		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
			label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
			label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
		])

		self.titleLabel = label
		return container
	}

	private func makeRichTitleContainer(for kind: LibraryKind) -> UIView {
		let container = UIView()

		let posterImageView = PosterImageView()
		posterImageView.contentMode = .scaleAspectFill
		posterImageView.clipsToBounds = true
		posterImageView.tag = Self.posterTag
		posterImageView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(posterImageView)

		let overlayImageView = UIImageView(image: UIImage(named: "book_texture_overlay"))
		overlayImageView.contentMode = .scaleAspectFill
		overlayImageView.isUserInteractionEnabled = false
		overlayImageView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(overlayImageView)

		NSLayoutConstraint.activate([
			overlayImageView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
			overlayImageView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
			overlayImageView.topAnchor.constraint(equalTo: posterImageView.topAnchor),
			overlayImageView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),
		])

		self.posterImageOverlayView = overlayImageView

		let titleLabel = KLabel()
		titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
		titleLabel.adjustsFontForContentSizeCategory = true
		titleLabel.lineBreakMode = .byTruncatingTail
		titleLabel.numberOfLines = 1
		titleLabel.tag = Self.primaryLabelTag

		let cosmosView = KCosmosView()
		cosmosView.settings.starSize = 16
		cosmosView.settings.starMargin = 1
		cosmosView.settings.totalStars = 5
		cosmosView.settings.fillMode = .half
		cosmosView.settings.updateOnTouch = true
		cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self, let indexPath = self.indexPath else { return }
			self.delegate?.libraryTableCell(self, didUpdateRating: rating, at: indexPath)
		}

		let favoriteButton = self.makeTintButton(action: #selector(self.didTapFavoriteInline), accessibilityLabel: L10n.favorite, symbolPointSize: 14)
		let reminderButton = self.makeTintButton(action: #selector(self.didTapReminderInline), accessibilityLabel: L10n.reminder, symbolPointSize: 14)

		reminderButton.isHidden = !LibraryColumn.reminder.isApplicable(to: kind)

		let iconRow = UIStackView(arrangedSubviews: [favoriteButton, reminderButton, UIView()])
		iconRow.axis = .horizontal
		iconRow.alignment = .center
		iconRow.spacing = 6
		iconRow.translatesAutoresizingMaskIntoConstraints = false

		let cosmosRow = UIStackView(arrangedSubviews: [cosmosView, UIView()])
		cosmosRow.axis = .horizontal
		cosmosRow.alignment = .center
		cosmosRow.spacing = 0
		cosmosRow.translatesAutoresizingMaskIntoConstraints = false

		let topStack = UIStackView(arrangedSubviews: [titleLabel, cosmosRow])
		topStack.axis = .vertical
		topStack.alignment = .fill
		topStack.distribution = .fill
		topStack.spacing = 3
		topStack.translatesAutoresizingMaskIntoConstraints = false

		let metadataContainer = UIView()
		metadataContainer.translatesAutoresizingMaskIntoConstraints = false
		metadataContainer.addSubview(topStack)
		metadataContainer.addSubview(iconRow)
		container.addSubview(metadataContainer)

		self.titleLabel = titleLabel
		self.posterImageView = posterImageView
		self.inlineCosmosView = cosmosView
		self.inlineFavoriteButton = favoriteButton
		self.inlineReminderButton = reminderButton

		NSLayoutConstraint.activate([
			posterImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
			posterImageView.widthAnchor.constraint(equalToConstant: Self.posterWidth),
			posterImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
			posterImageView.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: Self.rowVerticalPadding),
			posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -Self.rowVerticalPadding),

			metadataContainer.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
			metadataContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
			metadataContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: Self.rowVerticalPadding),
			metadataContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Self.rowVerticalPadding),

			topStack.topAnchor.constraint(equalTo: metadataContainer.topAnchor),
			topStack.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor),
			topStack.trailingAnchor.constraint(equalTo: metadataContainer.trailingAnchor),

			iconRow.bottomAnchor.constraint(equalTo: metadataContainer.bottomAnchor),
			iconRow.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor),
			iconRow.trailingAnchor.constraint(equalTo: metadataContainer.trailingAnchor),
			iconRow.topAnchor.constraint(greaterThanOrEqualTo: topStack.bottomAnchor, constant: 8),
		])

		self.applyPosterHeight(self.posterHeight(for: kind))
		self.applyPosterChrome(for: kind)

		self.posterBoundsObservation = posterImageView.observe(\.bounds, options: [.new]) { [weak self] _, _ in
			self?.syncLiteratureMaskFrame()
		}

		return container
	}

	private func makeLabelContainer(textStyle: UIFont.TextStyle, using label: UILabel) -> UIView {
		let container = UIView()

		label.font = UIFont.preferredFont(forTextStyle: textStyle)
		label.adjustsFontForContentSizeCategory = true
		label.lineBreakMode = .byTruncatingTail
		label.numberOfLines = 1
		label.tag = Self.primaryLabelTag
		label.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(label)

		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
			label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
			label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
		])

		return container
	}

	private func makeTintButtonContainer(action: Selector, accessibilityLabel: String) -> UIView {
		let container = UIView()
		let button = self.makeTintButton(action: action, accessibilityLabel: accessibilityLabel, symbolPointSize: 13)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tag = Self.buttonValueTag
		container.addSubview(button)

		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
			button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
			button.widthAnchor.constraint(equalToConstant: 22),
			button.heightAnchor.constraint(equalToConstant: 22),
		])

		return container
	}

	private func makeTintButton(action: Selector, accessibilityLabel: String, symbolPointSize: CGFloat) -> UIButton {
		let button = UIButton(type: .system)
		button.theme_tintColor = KThemePicker.tintColor.rawValue
		button.addTarget(self, action: action, for: .touchUpInside)
		button.accessibilityLabel = accessibilityLabel
		button.configuration = {
			var config = UIButton.Configuration.plain()
			config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
			config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: symbolPointSize, weight: .regular)
			return config
		}()
		return button
	}

	private func makeRatingColumnContainer() -> UIView {
		let container = UIView()
		let cosmosView = KCosmosView()
		cosmosView.settings.starSize = 14
		cosmosView.settings.starMargin = 1
		cosmosView.settings.totalStars = 5
		cosmosView.settings.fillMode = .half
		cosmosView.settings.updateOnTouch = true
		cosmosView.tag = Self.cosmosValueTag
		cosmosView.translatesAutoresizingMaskIntoConstraints = false
		cosmosView.didFinishTouchingCosmos = { [weak self] rating in
			guard let self = self, let indexPath = self.indexPath else {
				return
			}
			self.delegate?.libraryTableCell(self, didUpdateRating: rating, at: indexPath)
		}
		container.addSubview(cosmosView)

		NSLayoutConstraint.activate([
			cosmosView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
			cosmosView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
		])

		return container
	}

	// MARK: - Poster chrome
	/// Returns the rendered poster height for the given library kind.
	///
	/// Width is fixed to ``posterWidth`` across every kind; only height varies.
	///
	/// - Parameter kind: The library kind whose poster height to resolve.
	///
	/// - Returns: The poster height in points.
	private func posterHeight(for kind: LibraryKind) -> CGFloat {
		switch kind {
		case .games: return Self.posterWidth
		default: return Self.posterWidth * 3.0 / 2.0
		}
	}

	private func applyPosterHeight(_ height: CGFloat) {
		guard let posterImageView = self.posterImageView else { return }

		self.posterAspectRatioConstraint?.isActive = false

		let constraint = posterImageView.heightAnchor.constraint(equalToConstant: height)
		constraint.priority = .required - 1
		constraint.isActive = true
		self.posterAspectRatioConstraint = constraint
	}

	private func applyPosterChrome(for kind: LibraryKind) {
		guard let posterImageView = self.posterImageView else { return }

		switch kind {
		case .shows:
			posterImageView.applyCornerRadius(10.0)
			posterImageView.mask = nil
			self.posterImageOverlayView?.isHidden = true
		case .literatures:
			posterImageView.applyCornerRadius(0.0)
			posterImageView.mask = self.literatureMask
			self.syncLiteratureMaskFrame()
			self.posterImageOverlayView?.isHidden = false
		case .games:
			posterImageView.applyCornerRadius(18.0)
			posterImageView.mask = nil
			self.posterImageOverlayView?.isHidden = true
		}
	}

	private func syncLiteratureMaskFrame() {
		guard let posterImageView = self.posterImageView else { return }
		guard posterImageView.mask === self.literatureMask else { return }

		self.literatureMask.frame = posterImageView.bounds
	}

	private func populate(item: LibraryListCollectionViewController.ItemKind, kind: LibraryKind, columns: [LibraryColumn], showPoster: Bool) {
		for column in columns {
			guard let container = self.columnContainers[column] else {
				continue
			}

			switch column {
			case .title:
				self.populateTitle(container: container, item: item, showPoster: showPoster)
			case .favorite:
				self.populateFavoriteColumn(container: container, item: item)
			case .reminder:
				self.populateReminderColumn(container: container, item: item)
			case .rating:
				self.populateRatingColumn(container: container, item: item)
			default:
				if let label = container.viewWithTag(Self.primaryLabelTag) as? UILabel {
					label.text = self.text(for: column, item: item)
				}
			}
		}
	}

	private func populateTitle(container: UIView, item: LibraryListCollectionViewController.ItemKind, showPoster: Bool) {
		if let label = container.viewWithTag(Self.primaryLabelTag) as? UILabel {
			label.text = self.text(for: .title, item: item)
		}

		guard showPoster else { return }

		if let posterImageView = self.posterImageView {
			switch item {
			case .show(let show):
				show.attributes.posterImage(imageView: posterImageView)
			case .literature(let literature):
				literature.attributes.posterImage(imageView: posterImageView)
			case .game(let game):
				game.attributes.posterImage(imageView: posterImageView)
			}
		}

		if let cosmosView = self.inlineCosmosView {
			cosmosView.rating = self.rating(for: item) ?? 0
		}

		self.applyFavoriteState(button: self.inlineFavoriteButton, item: item)
		self.applyReminderState(button: self.inlineReminderButton, item: item)
	}

	private func populateFavoriteColumn(container: UIView, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = container.viewWithTag(Self.buttonValueTag) as? UIButton else { return }
		self.applyFavoriteState(button: button, item: item)
	}

	private func populateReminderColumn(container: UIView, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = container.viewWithTag(Self.buttonValueTag) as? UIButton else { return }
		self.applyReminderState(button: button, item: item)
	}

	private func populateRatingColumn(container: UIView, item: LibraryListCollectionViewController.ItemKind) {
		guard let cosmosView = container.viewWithTag(Self.cosmosValueTag) as? KCosmosView else { return }
		cosmosView.rating = self.rating(for: item) ?? 0
	}

	private func applyFavoriteState(button: UIButton?, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = button else { return }
		let isFavorited = self.isFavorited(item)
		button.setImage(UIImage(systemName: isFavorited ? "heart.fill" : "heart"), for: .normal)
		button.accessibilityLabel = isFavorited ? L10n.removeFromFavorites : L10n.addToFavorites
	}

	private func applyReminderState(button: UIButton?, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = button else { return }
		let hasReminder = self.hasReminder(item)
		button.setImage(UIImage(systemName: hasReminder ? "bell.fill" : "bell"), for: .normal)
		button.accessibilityLabel = hasReminder ? L10n.removeReminder : L10n.addReminder
	}

	// MARK: - Actions
	@objc private func didTapFavoriteInline() {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.libraryTableCell(self, didToggleFavoriteAt: indexPath)
	}

	@objc private func didTapReminderInline() {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.libraryTableCell(self, didToggleReminderAt: indexPath)
	}

	@objc private func didTapFavoriteStandalone() {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.libraryTableCell(self, didToggleFavoriteAt: indexPath)
	}

	@objc private func didTapReminderStandalone() {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.libraryTableCell(self, didToggleReminderAt: indexPath)
	}

	// MARK: - Model accessors
	private func isFavorited(_ item: LibraryListCollectionViewController.ItemKind) -> Bool {
		switch item {
		case .show(let show):
			return show.attributes.library?.favoriteStatus == .favorited
		case .literature(let literature):
			return literature.attributes.library?.favoriteStatus == .favorited
		case .game(let game):
			return game.attributes.library?.favoriteStatus == .favorited
		}
	}

	private func hasReminder(_ item: LibraryListCollectionViewController.ItemKind) -> Bool {
		switch item {
		case .show(let show):
			return show.attributes.library?.reminderStatus == .reminded
		case .literature(let literature):
			return literature.attributes.library?.reminderStatus == .reminded
		case .game(let game):
			return game.attributes.library?.reminderStatus == .reminded
		}
	}

	private func rating(for item: LibraryListCollectionViewController.ItemKind) -> Double? {
		switch item {
		case .show(let show):
			return show.attributes.library?.rating
		case .literature(let literature):
			return literature.attributes.library?.rating
		case .game(let game):
			return game.attributes.library?.rating
		}
	}

	private func text(for column: LibraryColumn, item: LibraryListCollectionViewController.ItemKind) -> String {
		switch item {
		case .show(let show):
			return self.text(for: column, show: show)
		case .literature(let literature):
			return self.text(for: column, literature: literature)
		case .game(let game):
			return self.text(for: column, game: game)
		}
	}

	private func text(for column: LibraryColumn, show: Show) -> String {
		let attributes = show.attributes
		switch column {
		case .title: return attributes.title
		case .type: return attributes.type.name
		case .status: return attributes.status.name
		case .genres: return attributes.genres?.localizedJoined() ?? ""
		case .year: return Self.formatYear(attributes.startedAt)
		case .studio: return attributes.studio ?? ""
		case .tvRating: return attributes.tvRating.name
		case .episodes: return "\(attributes.episodeCount)"
		case .dateAdded, .progress: return "" // TODO: Add support in API response
		case .rating, .favorite, .reminder, .chapters, .volumes, .editions: return ""
		}
	}

	private func text(for column: LibraryColumn, literature: Literature) -> String {
		let attributes = literature.attributes
		switch column {
		case .title: return attributes.title
		case .type: return attributes.type.name
		case .status: return attributes.status.name
		case .genres: return attributes.genres?.localizedJoined() ?? ""
		case .year: return Self.formatYear(attributes.startedAt)
		case .studio: return attributes.studio ?? ""
		case .tvRating: return attributes.tvRating.name
		case .chapters: return "\(attributes.chapterCount)"
		case .volumes: return "\(attributes.volumeCount)"
		case .dateAdded, .progress: return ""
		case .rating, .favorite, .reminder, .episodes, .editions: return ""
		}
	}

	private func text(for column: LibraryColumn, game: Game) -> String {
		let attributes = game.attributes
		switch column {
		case .title: return attributes.title
		case .type: return attributes.type.name
		case .status: return attributes.status.name
		case .genres: return attributes.genres?.localizedJoined() ?? ""
		case .year: return Self.formatYear(attributes.startedAt)
		case .studio: return attributes.studio ?? ""
		case .tvRating: return attributes.tvRating.name
		case .editions: return "\(attributes.editionCount)"
		case .dateAdded, .progress: return ""
		case .rating, .favorite, .reminder, .episodes, .chapters, .volumes: return ""
		}
	}

	private static func formatYear(_ date: Date?) -> String {
		guard let date = date else {
			return ""
		}

		return "\(Calendar.current.component(.year, from: date))"
	}
}
