//
//  CellHeightMeasurer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Measures the cells of a section so the section can lay them out at one height.
@MainActor
final class CellHeightMeasurer {
	// MARK: - Properties
	/// The cells the measurements are taken from, keyed by their type.
	private var sizingCells: [ObjectIdentifier: KCollectionViewCell] = [:]

	/// The environment the sizing cells were built for.
	private var environment: Environment?

	#if DEBUG
	/// The width each cell type was last measured at.
	private var measuredWidths: [ObjectIdentifier: CGFloat] = [:]

	/// The cell types already reported for rendering at the wrong width.
	private var reportedWidthMismatches: Set<ObjectIdentifier> = []
	#endif

	// MARK: - Functions
	/// Returns the height of the tallest cell the given items render.
	///
	/// - Parameters:
	///    - items: The items the section lays out.
	///    - width: The width a single cell is given.
	///    - contentSizeCategory: The type size the section is laid out at.
	///
	/// - Returns: The tallest measured height.
	func maximumHeight(for items: [Item], width: CGFloat, contentSizeCategory: UIContentSizeCategory) -> CGFloat? {
		guard width > 0.0, !items.isEmpty else { return nil }

		let environment = Environment(contentSizeCategory: contentSizeCategory, locale: LanguageManager.shared.locale)

		// A detached cell never receives trait or language changes, so it is rebuilt instead.
		if self.environment != environment {
			self.sizingCells.removeAll()
			self.environment = environment
		}

		var maximumHeight = 0.0

		for item in items {
			let sizingCell = self.sizingCell(of: item.cellType)
			item.configure(sizingCell)

			maximumHeight = max(maximumHeight, self.fittingHeight(of: sizingCell, width: width))

			#if DEBUG
			self.measuredWidths[ObjectIdentifier(item.cellType)] = width
			#endif
		}

		return maximumHeight > 0.0 ? maximumHeight : nil
	}

	/// Returns the cell the given type's measurements are taken from.
	///
	/// - Parameter cellType: The type of cell to measure with.
	///
	/// - Returns: The sizing cell.
	private func sizingCell(of cellType: KCollectionViewCell.Type) -> KCollectionViewCell {
		let key = ObjectIdentifier(cellType)

		if let sizingCell = self.sizingCells[key] {
			return sizingCell
		}

		let sizingCell = Self.makeCell(of: cellType)
		sizingCell.isSizingCell = true
		self.sizingCells[key] = sizingCell

		return sizingCell
	}

	/// Returns a cell of the given type, loaded from its nib when the bundle carries one.
	///
	/// - Parameter cellType: The type of cell to create.
	///
	/// - Returns: The created cell.
	private static func makeCell(of cellType: KCollectionViewCell.Type) -> KCollectionViewCell {
		let identifier = String(describing: cellType)

		if Bundle.main.path(forResource: identifier, ofType: "nib") != nil,
		   let cell = UINib(nibName: identifier, bundle: nil).instantiate(withOwner: nil).first as? KCollectionViewCell {
			return cell
		}

		// Swift only allows metatype construction through a `required` initializer, which the
		// imported UIKit one satisfies and a Swift subclass declaration does not.
		let uiKitCellType: UICollectionViewCell.Type = cellType

		guard let cell = uiKitCellType.init(frame: .zero) as? KCollectionViewCell else {
			preconditionFailure("\(identifier) is neither a KCollectionViewCell nor backed by a nib.")
		}

		return cell
	}

	/// Returns the height the given cell fits into at the given width.
	///
	/// - Parameters:
	///    - cell: The cell to measure.
	///    - width: The width the cell is given.
	///
	/// - Returns: The cell's fitting height.
	private func fittingHeight(of cell: KCollectionViewCell, width: CGFloat) -> CGFloat {
		cell.bounds.size.width = width
		cell.layoutIfNeeded()

		let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
		let size = cell.contentView.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)

		return size.height.rounded(.up)
	}

	#if DEBUG
	/// Reports every cell rendering at a different width than the one its height was measured at.
	///
	/// - Parameter cells: The cells currently on screen.
	func validateWidths(of cells: [UICollectionViewCell]) {
		for cell in cells {
			let cellType = ObjectIdentifier(type(of: cell))

			guard let measuredWidth = self.measuredWidths[cellType] else { continue }
			guard abs(cell.bounds.width - measuredWidth) > 0.5 else { continue }
			guard self.reportedWidthMismatches.insert(cellType).inserted else { continue }

			print("ERROR: \(type(of: cell)) was measured at width \(measuredWidth) but renders at \(cell.bounds.width). Its measured height is wrong by every constraint that depends on width.")
		}
	}
	#endif
}

// MARK: - Item
extension CellHeightMeasurer {
	/// An item whose cell the measurer sizes.
	struct Item {
		// MARK: - Properties
		/// The type of cell the content is rendered in.
		let cellType: KCollectionViewCell.Type

		/// Applies the content to a sizing cell.
		let configure: (KCollectionViewCell) -> Void

		// MARK: - Initializers
		/// Creates an item that measures the given cell once it is configured.
		///
		/// - Parameters:
		///    - cellType: The type of cell the content is rendered in.
		///    - configure: Applies the content to a sizing cell.
		init<Cell: KCollectionViewCell>(cellType: Cell.Type, configure: @escaping (Cell) -> Void) {
			self.cellType = cellType
			self.configure = { cell in
				guard let cell = cell as? Cell else { return }
				configure(cell)
			}
		}
	}
}

// MARK: - Environment
extension CellHeightMeasurer {
	/// The inputs that change what a sizing cell renders at a given width.
	private struct Environment: Equatable {
		let contentSizeCategory: UIContentSizeCategory
		let locale: Locale
	}
}
