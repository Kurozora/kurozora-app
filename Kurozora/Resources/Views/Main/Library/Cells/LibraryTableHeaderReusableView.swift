//
//  LibraryTableHeaderReusableView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftTheme
import UIKit

protocol LibraryTableHeaderReusableViewDelegate: AnyObject {
	/// Tells the delegate that the user finished resizing a column.
	///
	/// - Parameters:
	///    - header: The header view that emitted the event.
	///    - column: The column whose width changed.
	///    - width: The new width for the column, in points.
	func tableHeader(_ header: LibraryTableHeaderReusableView, didResize column: LibraryColumn, to width: CGFloat)

	/// Tells the delegate that the user dropped a dragged column at a new position.
	///
	/// - Parameters:
	///    - header: The header view that emitted the event.
	///    - columnOrder: The updated left-to-right order of visible columns.
	func tableHeader(_ header: LibraryTableHeaderReusableView, didReorderColumnsTo columnOrder: [LibraryColumn])

	/// Asks the delegate for a width that fits the widest content currently visible for a column.
	///
	/// - Parameters:
	///    - header: The header view requesting the measurement.
	///    - column: The column to measure.
	///
	/// - Returns: The fitted width in points, or `nil` to fall back to the column's default width.
	func tableHeader(_ header: LibraryTableHeaderReusableView, autoFitWidthFor column: LibraryColumn) -> CGFloat?
}

class LibraryTableHeaderReusableView: UICollectionReusableView, ReusableView {
	// MARK: - Subviews
	private let stackView = UIStackView()
	private let bottomSeparator = UIView()

	private var columnLabels: [LibraryColumn: UILabel] = [:]
	private var columnContainers: [LibraryColumn: UIView] = [:]
	private var columnWidthConstraints: [LibraryColumn: NSLayoutConstraint] = [:]
	private var separatorHandles: [LibraryColumn: ResizeHandleView] = [:]

	/// The columns currently laid out by the header, in left-to-right order.
	private(set) var columns: [(column: LibraryColumn, width: CGFloat)] = []

	/// The object to notify about column-resize and reorder events.
	weak var delegate: LibraryTableHeaderReusableViewDelegate?

	private var dragState: DragState?

	// MARK: - Initialization
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - Configuration
	/// Configures the header with one label per column and applies the supplied widths.
	///
	/// - Parameter columns: The visible columns paired with their current widths.
	func configure(columns: [(column: LibraryColumn, width: CGFloat)]) {
		let incomingIdentities = columns.map(\.column)
		let currentIdentities = self.columns.map(\.column)

		if incomingIdentities != currentIdentities {
			self.rebuildLabels(for: incomingIdentities)
		}

		self.columns = columns
		self.applyWidths(columns)
	}

	// MARK: - View
	private func configureView() {
		self.theme_backgroundColor = KThemePicker.barTintColor.rawValue

		self.stackView.axis = .horizontal
		self.stackView.alignment = .fill
		self.stackView.distribution = .fill
		self.stackView.spacing = 0
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.stackView)

		self.bottomSeparator.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		self.bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.bottomSeparator)

		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.bottomSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.bottomSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.bottomSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.bottomSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
		])
	}

	private func rebuildLabels(for columns: [LibraryColumn]) {
		self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		self.separatorHandles.values.forEach { $0.removeFromSuperview() }

		self.columnLabels.removeAll()
		self.columnContainers.removeAll()
		self.columnWidthConstraints.removeAll()
		self.separatorHandles.removeAll()

		for (index, column) in columns.enumerated() {
			let labelContainer = self.makeLabelContainer(for: column)
			self.stackView.addArrangedSubview(labelContainer)
			self.columnContainers[column] = labelContainer

			let isLast = index == columns.count - 1
			let widthConstraint = labelContainer.widthAnchor.constraint(equalToConstant: column.defaultWidth)

			if isLast {
				widthConstraint.priority = .defaultHigh
				labelContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)
			} else {
				widthConstraint.priority = .required
			}

			widthConstraint.isActive = true
			self.columnWidthConstraints[column] = widthConstraint

			self.attachReorderGesture(to: labelContainer, for: column)

			if !isLast {
				self.installResizeHandle(after: labelContainer, for: column)
			}
		}
	}

	private func applyWidths(_ columns: [(column: LibraryColumn, width: CGFloat)]) {
		for pair in columns {
			self.columnWidthConstraints[pair.column]?.constant = pair.width
		}
	}

	private func makeLabelContainer(for column: LibraryColumn) -> UIView {
		let container = UIView()
		container.backgroundColor = .clear
		container.isAccessibilityElement = true
		container.accessibilityLabel = column.accessibilityLabel
		container.accessibilityTraits = .header

		#if targetEnvironment(macCatalyst)
		container.toolTip = column.accessibilityLabel
		#endif

		if let iconName = column.headerIconSystemName {
			let iconView = UIImageView(image: UIImage(systemName: iconName))
			iconView.contentMode = .scaleAspectFit
			iconView.theme_tintColor = KThemePicker.subTextColor.rawValue
			iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
			iconView.isUserInteractionEnabled = false
			iconView.translatesAutoresizingMaskIntoConstraints = false
			container.addSubview(iconView)

			NSLayoutConstraint.activate([
				iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
				iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
				iconView.widthAnchor.constraint(equalToConstant: 18),
				iconView.heightAnchor.constraint(equalToConstant: 18),
			])
		} else {
			let label = UILabel()
			label.text = column.title
			label.font = UIFont.preferredFont(forTextStyle: .footnote).bold
			label.adjustsFontForContentSizeCategory = true
			label.lineBreakMode = .byTruncatingTail
			label.numberOfLines = 1
			label.theme_textColor = KThemePicker.subTextColor.rawValue
			label.isUserInteractionEnabled = false
			label.translatesAutoresizingMaskIntoConstraints = false
			container.addSubview(label)

			NSLayoutConstraint.activate([
				label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
				label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
				label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
			])

			self.columnLabels[column] = label
		}

		return container
	}

	private func installResizeHandle(after container: UIView, for column: LibraryColumn) {
		let handle = ResizeHandleView(column: column)
		handle.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(handle)

		NSLayoutConstraint.activate([
			handle.centerXAnchor.constraint(equalTo: container.trailingAnchor),
			handle.topAnchor.constraint(equalTo: self.topAnchor),
			handle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])

		handle.addPanTarget(self, action: #selector(self.handleResizePan(_:)))
		handle.addDoubleTapTarget(self, action: #selector(self.handleResetDoubleTap(_:)))
		self.separatorHandles[column] = handle
	}

	// MARK: - Resize handling
	@objc private func handleResizePan(_ recognizer: UIPanGestureRecognizer) {
		guard
			let handle = recognizer.view as? ResizeHandleView,
			let widthConstraint = self.columnWidthConstraints[handle.column]
		else { return }

		let translation = recognizer.translation(in: self).x

		switch recognizer.state {
		case .began:
			handle.initialWidth = widthConstraint.constant
		case .changed:
			let proposed = handle.initialWidth + translation
			widthConstraint.constant = max(handle.column.minWidth, proposed)
			self.setNeedsLayout()
			self.layoutIfNeeded()
		case .ended, .cancelled, .failed:
			self.delegate?.tableHeader(self, didResize: handle.column, to: widthConstraint.constant)
		default:
			break
		}
	}

	/// Resizes the column beneath the handle to fit its widest visible content.
	///
	/// - Parameter recognizer: The double-tap gesture that triggered the fit.
	@objc private func handleResetDoubleTap(_ recognizer: UITapGestureRecognizer) {
		guard
			let handle = recognizer.view as? ResizeHandleView,
			let widthConstraint = self.columnWidthConstraints[handle.column]
		else { return }

		let fittedWidth = self.delegate?.tableHeader(self, autoFitWidthFor: handle.column) ?? handle.column.defaultWidth
		let clamped = max(handle.column.minWidth, fittedWidth)

		widthConstraint.constant = clamped
		self.setNeedsLayout()
		self.layoutIfNeeded()

		self.delegate?.tableHeader(self, didResize: handle.column, to: clamped)
	}

	// MARK: - Drag-to-reorder
	private func attachReorderGesture(to container: UIView, for column: LibraryColumn) {
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleReorderDrag(_:)))
		longPressGestureRecognizer.minimumPressDuration = 0.2
		longPressGestureRecognizer.allowableMovement = .greatestFiniteMagnitude
		container.addGestureRecognizer(longPressGestureRecognizer)
		container.isUserInteractionEnabled = true
	}

	@objc private func handleReorderDrag(_ recognizer: UILongPressGestureRecognizer) {
		guard let container = recognizer.view else { return }
		guard let sourceColumn = self.columnContainers.first(where: { $0.value === container })?.key else { return }

		let location = recognizer.location(in: self.stackView)

		switch recognizer.state {
		case .began:
			self.dragState = DragState(column: sourceColumn)
			container.alpha = 0.5
		case .changed:
			guard self.dragState != nil else {
				return
			}

			self.swapIfPastNeighborMidpoint(from: sourceColumn, fingerX: location.x)
		case .ended, .cancelled, .failed:
			container.alpha = 1.0
			self.dragState = nil
			self.delegate?.tableHeader(self, didReorderColumnsTo: self.columns.map(\.column))
		default:
			break
		}
	}

	/// Swaps the dragged column with a neighbor once the finger crosses that neighbor's midpoint.
	///
	/// The midpoint threshold prevents oscillation when the dragged column is narrow and its
	/// neighbor is wide.
	///
	/// - Parameters:
	///    - sourceColumn: The column currently being dragged.
	///    - fingerX: The current finger x-coordinate in the stack view's coordinate space.
	private func swapIfPastNeighborMidpoint(from sourceColumn: LibraryColumn, fingerX: CGFloat) {
		guard let sourceIndex = self.columns.firstIndex(where: { $0.column == sourceColumn }) else { return }

		if sourceIndex < self.columns.count - 1 {
			let rightColumn = self.columns[sourceIndex + 1].column
			if let rightContainer = self.columnContainers[rightColumn], fingerX > rightContainer.frame.midX {
				self.swapColumn(sourceColumn, with: rightColumn)
				return
			}
		}

		if sourceIndex > 0 {
			let leftColumn = self.columns[sourceIndex - 1].column
			if let leftContainer = self.columnContainers[leftColumn], fingerX < leftContainer.frame.midX {
				self.swapColumn(sourceColumn, with: leftColumn)
			}
		}
	}

	private func swapColumn(_ source: LibraryColumn, with target: LibraryColumn) {
		guard let sourceIndex = self.columns.firstIndex(where: { $0.column == source }) else { return }
		guard let targetIndex = self.columns.firstIndex(where: { $0.column == target }) else { return }

		self.columns.swapAt(sourceIndex, targetIndex)

		// Re-insert each arranged subview in data order. `insertArrangedSubview` moves a view
		// that's already arranged, so this realigns both source and target in one pass.
		for (index, pair) in self.columns.enumerated() {
			if let view = self.columnContainers[pair.column] {
				self.stackView.insertArrangedSubview(view, at: index)
			}
		}

		self.reinstallResizeHandles()

		// After a swap, the previous last column still carries the flexible-width priority and
		// would keep the new last column from stretching. Sync priorities to the new order.
		self.updateLastColumnWidthPriority()

		UIView.animate(withDuration: 0.2) {
			self.layoutIfNeeded()
		}
	}

	private func reinstallResizeHandles() {
		self.separatorHandles.values.forEach { $0.removeFromSuperview() }
		self.separatorHandles.removeAll()

		for (index, pair) in self.columns.enumerated() where index < self.columns.count - 1 {
			guard let container = self.columnContainers[pair.column] else {
				continue
			}

			self.installResizeHandle(after: container, for: pair.column)
		}
	}

	/// Applies the flexible width priority to the current last column and the rigid priority to every other column.
	private func updateLastColumnWidthPriority() {
		for (index, pair) in self.columns.enumerated() {
			let isLast = index == self.columns.count - 1
			if let widthConstraint = self.columnWidthConstraints[pair.column] {
				widthConstraint.priority = isLast ? .defaultHigh : .required
			}
			if let container = self.columnContainers[pair.column] {
				container.setContentHuggingPriority(isLast ? .defaultLow : .defaultHigh, for: .horizontal)
			}
		}
	}
}

// MARK: - DragState
private extension LibraryTableHeaderReusableView {
	/// The column currently being dragged during a reorder gesture.
	struct DragState {
		/// The column being dragged.
		let column: LibraryColumn
	}
}

// MARK: - ResizeHandleView
/// A thin vertical separator with an extended horizontal hit-target that resizes its column.
private final class ResizeHandleView: UIView {
	// MARK: - Properties
	/// The column the handle resizes.
	let column: LibraryColumn

	/// The column's width when the current pan gesture began.
	var initialWidth: CGFloat = 0

	// MARK: - Subviews
	private let visibleLine = UIView()

	// MARK: - Initialization
	init(column: LibraryColumn) {
		self.column = column
		super.init(frame: .zero)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Adds a pan-gesture recognizer that forwards events to the supplied target.
	///
	/// - Parameters:
	///    - target: The object that receives the pan-gesture messages.
	///    - action: The selector invoked on each gesture update.
	func addPanTarget(_ target: Any, action: Selector) {
		let panGestureRecognizer = UIPanGestureRecognizer(target: target, action: action)
		self.panGestureRecognizer = panGestureRecognizer
		self.addGestureRecognizer(panGestureRecognizer)
	}

	/// Adds a double-tap recognizer that requests an auto-fit.
	///
	/// - Parameters:
	///    - target: The object that receives the tap message.
	///    - action: The selector invoked when the double-tap is recognized.
	func addDoubleTapTarget(_ target: Any, action: Selector) {
		let doubleTapRecognizer = UITapGestureRecognizer(target: target, action: action)
		doubleTapRecognizer.numberOfTapsRequired = 2
		self.addGestureRecognizer(doubleTapRecognizer)
		self.panGestureRecognizer?.require(toFail: doubleTapRecognizer)
	}

	// MARK: - Helpers
	private var panGestureRecognizer: UIPanGestureRecognizer?

	private func configureView() {
		self.backgroundColor = .clear

		self.visibleLine.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		self.visibleLine.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.visibleLine)

		NSLayoutConstraint.activate([
			self.widthAnchor.constraint(equalToConstant: 20),

			self.visibleLine.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.visibleLine.topAnchor.constraint(equalTo: self.topAnchor, constant: 6),
			self.visibleLine.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6),
			self.visibleLine.widthAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
		])

		#if targetEnvironment(macCatalyst)
		self.addInteraction(UIPointerInteraction(delegate: self))
		#endif
	}
}

#if targetEnvironment(macCatalyst)
// MARK: - UIPointerInteractionDelegate
extension ResizeHandleView: UIPointerInteractionDelegate {
	func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
		return UIPointerStyle(shape: .beam(length: 16, axis: .vertical), constrainedAxes: [])
	}
}
#endif
