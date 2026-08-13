//
//  LibraryTableCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Cosmos
import KurozoraKit
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

	/// Tells the delegate that the user tapped the cell's visibility affordance.
	///
	/// - Parameters:
	///    - cell: The cell that emitted the event.
	///    - indexPath: The index path of the row whose visibility state should toggle.
	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleVisibilityAt indexPath: IndexPath)

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
	private let rowDivider = SeparatorView()

	private var stackLeadingConstraint: NSLayoutConstraint?

	private var columnOrder: [LibraryColumn] = []
	private var columnContainers: [LibraryColumn: UIView] = [:]
	private var columnWidthConstraints: [LibraryColumn: NSLayoutConstraint] = [:]

	private weak var titleLabel: UILabel?
	private weak var posterContainerView: UIView?
	private weak var posterImageView: PosterImageView?
	private weak var posterBorderView: BorderView?
	private weak var posterImageOverlayView: UIImageView?
	private var posterAspectRatioConstraint: NSLayoutConstraint?
	private weak var inlineCosmosView: KCosmosView?
	private weak var inlineFavoriteButton: UIButton?
	private weak var inlineReminderButton: UIButton?
	private weak var inlineVisibilityButton: UIButton?
	private var rowDividerLeadingConstraint: NSLayoutConstraint?

	private lazy var literatureMask: UIImageView = {
		UIImageView(image: .bookMask)
	}()

	private var posterBoundsObservation: NSKeyValueObservation?

	private var lastShowPoster: Bool?
	private var lastKind: LibraryKind?

	// MARK: - Properties
	private let primaryLabelTag = 1
	private let posterTag = 2
	private let buttonValueTag = 3
	private let cosmosValueTag = 4

	/// The vertical padding applied inside every column's container.
	static let rowVerticalPadding: CGFloat = 10

	/// The rendered width of the inline poster, uniform across library kinds.
	static let posterWidth: CGFloat = 80

	/// The horizontal space reserved for the leading selection indicator.
	private let selectionIconReservedWidth: CGFloat = 38

	/// The index path the cell currently represents.
	private(set) var indexPath: IndexPath?

	/// The object that receives toggle and rating callbacks from the cell.
	weak var delegate: LibraryTableCollectionViewCellDelegate?

	/// A Boolean value that indicates whether the cell renders its selection indicator.
	var showSelectionIcon: Bool = false {
		didSet {
			guard oldValue != self.showSelectionIcon else { return }
			self.stackLeadingConstraint?.constant = self.showSelectionIcon ? self.selectionIconReservedWidth : 0
			self.setNeedsLayout()
		}
	}

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

	// MARK: - Live resize
	/// Updates the in-flight width of the given column without reapplying the data source snapshot.
	///
	/// Used during the column-divider drag so the row mirrors the header in real time.
	///
	/// - Parameters:
	///    - column: The column whose width to update.
	///    - width: The new width, in points.
	func updateColumnWidth(_ column: LibraryColumn, to width: CGFloat) {
		guard let constraint = self.columnWidthConstraints[column] else { return }
		constraint.constant = width
	}

	// MARK: - Auto-fit
	/// Returns the minimum width that fits the supplied text in the given column.
	///
	/// - Parameters:
	///    - text: The rendered string to measure.
	///    - column: The column the text belongs to.
	///    - showPoster: A Boolean that indicates whether the title cell renders an inline poster.
	///
	/// - Returns: The content width in points, including horizontal padding and any poster gutter.
	static func fittedWidth(forText text: String, column: LibraryColumn, showPoster: Bool) -> CGFloat {
		let font: UIFont
		switch column {
		case .title: font = UIFont.preferredFont(forTextStyle: .body)
		default: font = UIFont.preferredFont(forTextStyle: .footnote)
		}

		let textWidth = (text as NSString).size(withAttributes: [.font: font]).width

		if column == .title, showPoster {
			// leading padding + poster + spacing + label + trailing padding.
			return 8 + Self.posterWidth + 12 + ceil(textWidth) + 8
		}
		return ceil(textWidth) + 16
	}

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
		case .favorite, .reminder, .visibility:
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
				let label = container.viewWithTag(self.primaryLabelTag) as? UILabel
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

		self.rowDivider.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.rowDivider)

		let stackLeading = self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
		self.stackLeadingConstraint = stackLeading

		NSLayoutConstraint.activate([
			stackLeading,
			self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.selectionImageOverlayView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8.0),
			self.selectionImageOverlayView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.selectionImageOverlayView.widthAnchor.constraint(equalToConstant: 22.0),
			self.selectionImageOverlayView.heightAnchor.constraint(equalToConstant: 22.0),

			self.rowDivider.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.rowDivider.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.rowDivider.heightAnchor.constraint(equalToConstant: 1.0),
		])
	}

	private func rebuildColumnContainers(for columns: [LibraryColumn], showPoster: Bool, kind: LibraryKind) {
		self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		self.columnContainers.removeAll()
		self.columnWidthConstraints.removeAll()
		self.columnOrder = columns
		self.titleLabel = nil
		self.posterContainerView = nil
		self.posterImageView = nil
		self.posterBorderView = nil
		self.posterImageOverlayView = nil
		self.posterAspectRatioConstraint = nil
		self.inlineCosmosView = nil
		self.inlineFavoriteButton = nil
		self.inlineReminderButton = nil
		self.inlineVisibilityButton = nil
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
		case .visibility:
			return self.makeTintButtonContainer(action: #selector(self.didTapVisibilityStandalone), accessibilityLabel: L10n.visibility)
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
		label.tag = self.primaryLabelTag
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

		let posterContainerView = UIView()
		posterContainerView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(posterContainerView)

		let posterImageView = PosterImageView()
		posterImageView.contentMode = .scaleAspectFill
		posterImageView.clipsToBounds = true
		posterImageView.tag = self.posterTag
		posterImageView.translatesAutoresizingMaskIntoConstraints = false
		posterContainerView.addSubview(posterImageView)

		NSLayoutConstraint.activate([
			posterImageView.leadingAnchor.constraint(equalTo: posterContainerView.leadingAnchor),
			posterImageView.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor),
			posterImageView.topAnchor.constraint(equalTo: posterContainerView.topAnchor),
			posterImageView.bottomAnchor.constraint(equalTo: posterContainerView.bottomAnchor),
		])

		let overlayImageView = UIImageView(image: .bookTexture)
		overlayImageView.contentMode = .scaleAspectFill
		overlayImageView.isUserInteractionEnabled = false
		overlayImageView.translatesAutoresizingMaskIntoConstraints = false
		posterContainerView.addSubview(overlayImageView)

		NSLayoutConstraint.activate([
			overlayImageView.leadingAnchor.constraint(equalTo: posterContainerView.leadingAnchor),
			overlayImageView.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor),
			overlayImageView.topAnchor.constraint(equalTo: posterContainerView.topAnchor),
			overlayImageView.bottomAnchor.constraint(equalTo: posterContainerView.bottomAnchor),
		])

		self.posterImageOverlayView = overlayImageView

		let borderView = BorderView()
		borderView.cornerRadius = 22
		borderView.isUserInteractionEnabled = false
		borderView.translatesAutoresizingMaskIntoConstraints = false
		posterContainerView.addSubview(borderView)

		NSLayoutConstraint.activate([
			borderView.leadingAnchor.constraint(equalTo: posterContainerView.leadingAnchor),
			borderView.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor),
			borderView.topAnchor.constraint(equalTo: posterContainerView.topAnchor),
			borderView.bottomAnchor.constraint(equalTo: posterContainerView.bottomAnchor),
		])

		self.posterContainerView = posterContainerView
		self.posterBorderView = borderView

		let titleLabel = KLabel()
		titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
		titleLabel.adjustsFontForContentSizeCategory = true
		titleLabel.lineBreakMode = .byTruncatingTail
		titleLabel.numberOfLines = 1
		titleLabel.tag = self.primaryLabelTag

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
		let visibilityButton = self.makeTintButton(action: #selector(self.didTapVisibilityInline), accessibilityLabel: L10n.visibility, symbolPointSize: 14)

		reminderButton.isHidden = !LibraryColumn.reminder.isApplicable(to: kind)

		let iconRow = UIStackView(arrangedSubviews: [favoriteButton, reminderButton, visibilityButton, UIView()])
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
		self.inlineVisibilityButton = visibilityButton

		NSLayoutConstraint.activate([
			posterContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
			posterContainerView.widthAnchor.constraint(equalToConstant: Self.posterWidth),
			posterContainerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
			posterContainerView.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: Self.rowVerticalPadding),
			posterContainerView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -Self.rowVerticalPadding),

			metadataContainer.leadingAnchor.constraint(equalTo: posterContainerView.trailingAnchor, constant: 12),
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
		label.tag = self.primaryLabelTag
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
		button.tag = self.buttonValueTag
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
		cosmosView.tag = self.cosmosValueTag
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
		guard let posterContainerView = self.posterContainerView else { return }

		self.posterAspectRatioConstraint?.isActive = false

		let constraint = posterContainerView.heightAnchor.constraint(equalToConstant: height)
		constraint.priority = .required - 1
		constraint.isActive = true
		self.posterAspectRatioConstraint = constraint
	}

	private func applyPosterChrome(for kind: LibraryKind) {
		guard let posterImageView = self.posterImageView else { return }

		switch kind {
		case .shows:
			self.posterContainerView?.layer.cornerRadius = 22
			posterImageView.applyCornerRadius(22.0)
			posterImageView.layer.borderWidth = 0
			posterImageView.mask = nil
			self.posterImageOverlayView?.isHidden = true
			self.posterBorderView?.isHidden = false
		case .literatures:
			self.posterContainerView?.layer.cornerRadius = 0
			posterImageView.applyCornerRadius(0.0)
			posterImageView.mask = self.literatureMask
			self.syncLiteratureMaskFrame()
			self.posterImageOverlayView?.isHidden = false
			self.posterBorderView?.isHidden = true
		case .games:
			self.posterContainerView?.layer.cornerRadius = 22
			posterImageView.applyCornerRadius(22.0)
			posterImageView.layer.borderWidth = 0
			posterImageView.mask = nil
			self.posterImageOverlayView?.isHidden = true
			self.posterBorderView?.isHidden = false
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
			case .visibility:
				self.populateVisibilityColumn(container: container, item: item)
			case .rating:
				self.populateRatingColumn(container: container, item: item)
			default:
				if let label = container.viewWithTag(self.primaryLabelTag) as? UILabel {
					label.text = self.text(for: column, item: item)
				}
			}
		}
	}

	private func populateTitle(container: UIView, item: LibraryListCollectionViewController.ItemKind, showPoster: Bool) {
		if let label = container.viewWithTag(self.primaryLabelTag) as? UILabel {
			label.text = self.text(for: .title, item: item)
		}

		guard showPoster else { return }
		guard case let .entry(entry) = item else { return }

		if let posterImageView = self.posterImageView {
			entry.posterImage(imageView: posterImageView)
		}

		if let cosmosView = self.inlineCosmosView {
			cosmosView.rating = self.rating(for: item) ?? 0
		}

		self.applyFavoriteState(button: self.inlineFavoriteButton, item: item)
		self.applyReminderState(button: self.inlineReminderButton, item: item)
		self.applyVisibilityState(button: self.inlineVisibilityButton, item: item)
	}

	private func populateFavoriteColumn(container: UIView, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = container.viewWithTag(self.buttonValueTag) as? UIButton else { return }
		self.applyFavoriteState(button: button, item: item)
	}

	private func populateReminderColumn(container: UIView, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = container.viewWithTag(self.buttonValueTag) as? UIButton else { return }
		self.applyReminderState(button: button, item: item)
	}

	private func populateVisibilityColumn(container: UIView, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = container.viewWithTag(self.buttonValueTag) as? UIButton else { return }
		self.applyVisibilityState(button: button, item: item)
	}

	private func populateRatingColumn(container: UIView, item: LibraryListCollectionViewController.ItemKind) {
		guard let cosmosView = container.viewWithTag(self.cosmosValueTag) as? KCosmosView else { return }
		cosmosView.rating = self.rating(for: item) ?? 0
	}

	private func applyFavoriteState(button: UIButton?, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = button else { return }
		let isFavorited = self.isFavorited(item)
		self.updateButtonImage(button, systemName: isFavorited ? "heart.fill" : "heart")
		button.accessibilityLabel = isFavorited ? L10n.removeFromFavorites : L10n.addToFavorites
	}

	private func applyReminderState(button: UIButton?, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = button else { return }
		let hasReminder = self.hasReminder(item)
		self.updateButtonImage(button, systemName: hasReminder ? "bell.fill" : "bell")
		button.accessibilityLabel = hasReminder ? L10n.removeReminder : L10n.addReminder
	}

	private func applyVisibilityState(button: UIButton?, item: LibraryListCollectionViewController.ItemKind) {
		guard let button = button else { return }
		let hiddenStatus = self.hiddenStatus(for: item)
		let isDisabled = hiddenStatus == .disabled

		button.isHidden = isDisabled
		button.isEnabled = !isDisabled

		let isHidden = hiddenStatus == .hidden
		self.updateButtonImage(button, systemName: isHidden ? "eye.slash.fill" : "eye.fill")
		button.accessibilityLabel = isHidden ? L10n.showToPublic : L10n.hideFromPublic
	}

	/// Updates the button's image through its configuration so the system honors the configured
	/// symbol size and tinting.
	///
	/// `UIButton.setImage(_:for:)` quietly disables the button's `UIButton.Configuration` and on
	/// Mac Catalyst that legacy-fallback path renders no image at all.
	///
	/// - Parameters:
	///    - button: The button whose image to update.
	///    - systemName: The SF Symbols system name to render.
	private func updateButtonImage(_ button: UIButton, systemName: String) {
		var configuration = button.configuration
		configuration?.image = UIImage(systemName: systemName)
		button.configuration = configuration
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

	@objc private func didTapVisibilityInline() {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.libraryTableCell(self, didToggleVisibilityAt: indexPath)
	}

	@objc private func didTapVisibilityStandalone() {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.libraryTableCell(self, didToggleVisibilityAt: indexPath)
	}

	// MARK: - Model accessors
	private func isFavorited(_ item: LibraryListCollectionViewController.ItemKind) -> Bool {
		guard case let .entry(entry) = item else { return false }
		return entry.isFavorited
	}

	private func hasReminder(_ item: LibraryListCollectionViewController.ItemKind) -> Bool {
		guard case let .entry(entry) = item else { return false }
		return entry.isReminded
	}

	private func hiddenStatus(for item: LibraryListCollectionViewController.ItemKind) -> HiddenStatus {
		guard case let .entry(entry) = item else { return .notHidden }
		// Visibility is only meaningful for shows; other kinds keep the affordance disabled.
		switch entry.kind {
		case .shows: return entry.isHidden ? .hidden : .notHidden
		case .literatures, .games: return .disabled
		}
	}

	private func rating(for item: LibraryListCollectionViewController.ItemKind) -> Double? {
		guard case let .entry(entry) = item else { return nil }
		return entry.reviewScore?.doubleValue
	}

	/// Returns the rendered text for the given column of the supplied item.
	///
	/// - Parameters:
	///    - column: The column whose value to render.
	///    - item: The list item wrapping the local library entry.
	///
	/// - Returns: The rendered string.
	static func text(for column: LibraryColumn, item: LibraryListCollectionViewController.ItemKind) -> String {
		guard case let .entry(entry) = item else { return "" }
		return self.text(for: column, entry: entry)
	}

	private func text(for column: LibraryColumn, item: LibraryListCollectionViewController.ItemKind) -> String {
		return Self.text(for: column, item: item)
	}

	/// Returns the rendered text for the given column of the supplied entry.
	///
	/// - Parameters:
	///    - column: The column whose value to render.
	///    - entry: The local library entry whose value to read.
	///
	/// - Returns: The rendered string.
	static func text(for column: LibraryColumn, entry: LocalLibraryEntry) -> String {
		switch column {
		case .title: return entry.title ?? ""
		case .type: return entry.mediaTypeName ?? ""
		case .status: return entry.statusName ?? ""
		case .genres: return entry.genresLocalized ?? ""
		case .year, .studio, .tvRating, .episodes, .chapters, .volumes, .editions, .dateAdded, .progress: return ""
		case .rating, .favorite, .reminder, .visibility: return ""
		}
	}
}
