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
	#if DEBUG
	/// Whether every measurement also times a width-only re-solve.
	static var isSplitTimingEnabled = false
	#endif

	/// The hosts the measurements are taken from.
	private var sizingHosts: [ObjectIdentifier: SizingHost] = [:]

	/// The hosts the skeleton measurements are taken from.
	private var skeletonSizingHosts: [ObjectIdentifier: SizingHost] = [:]

	/// The environment the sizing cells were built for.
	private var environment: Environment?

	#if DEBUG
	/// The width each section was measured at during the current layout pass.
	private var measuredWidths: [Int: CGFloat] = [:]

	/// The sections already reported for rendering at the wrong width.
	private var reportedWidthMismatches: Set<Int> = []

	/// The running measurement cost of each cell type.
	private var measurementSplits: [String: MeasurementSplit] = [:]

	/// The cell types measured since the last report.
	private var pendingMeasurementSplits: Set<String> = []
	#endif

	// MARK: - Functions
	/// Returns the height of the tallest cell the given items render.
	///
	/// - Parameters:
	///    - items: The items the section lays out.
	///    - section: The section the items belong to.
	///    - width: The width a single cell is given.
	///    - contentSizeCategory: The type size the section is laid out at.
	///
	/// - Returns: The tallest measured height.
	func maximumHeight(for items: [Item], inSection section: Int, width: CGFloat, contentSizeCategory: UIContentSizeCategory) -> CGFloat? {
		guard width > 0.0, !items.isEmpty else { return nil }

		var maximumHeight = 0.0

		#if DEBUG
		let startedAt = CFAbsoluteTimeGetCurrent()
		#endif

		for item in items {
			maximumHeight = max(maximumHeight, self.height(of: item, width: width, contentSizeCategory: contentSizeCategory))
		}

		#if DEBUG
		self.measuredWidths[section] = width
		let elapsed = (CFAbsoluteTimeGetCurrent() - startedAt) * 1000.0
		print("----- [measure] section \(section) items \(items.count) \(String(format: "%.1f", elapsed))ms cells \(Set(items.map { String(describing: $0.cellType) }).sorted())")
		self.flushMeasurementSplits()
		#endif

		return maximumHeight > 0.0 ? maximumHeight : nil
	}

	/// Returns the height the given item's cell renders at.
	///
	/// - Parameters:
	///    - item: The item to measure.
	///    - width: The width a single cell is given.
	///    - contentSizeCategory: The type size the cell is laid out at.
	///
	/// - Returns: The measured height.
	func height(of item: Item, width: CGFloat, contentSizeCategory: UIContentSizeCategory) -> CGFloat {
		guard width > 0.0 else { return 0.0 }

		let environment = Environment(contentSizeCategory: contentSizeCategory, locale: LanguageManager.shared.locale)

		if self.environment != environment {
			self.sizingHosts.removeAll()
			self.skeletonSizingHosts.removeAll()
			self.environment = environment
		}

		let sizingHost = self.sizingHost(of: item.cellType, isSkeleton: item.isSkeleton)

		#if DEBUG
		if Self.isSplitTimingEnabled {
			return self.splitTimedHeight(of: item, in: sizingHost, width: width)
		}
		#endif

		item.configure(sizingHost.cell)

		return self.fittingHeight(of: sizingHost, width: width)
	}

	/// Returns the host the given type's measurements are taken from.
	///
	/// - Parameters:
	///    - cellType: The type of cell to measure with.
	///    - isSkeleton: Whether the cell measures a skeleton.
	///
	/// - Returns: The sizing host.
	private func sizingHost(of cellType: KCollectionViewCell.Type, isSkeleton: Bool) -> SizingHost {
		let key = ObjectIdentifier(cellType)

		if let sizingHost = isSkeleton ? self.skeletonSizingHosts[key] : self.sizingHosts[key] {
			return sizingHost
		}

		let sizingCell = Self.makeCell(of: cellType)
		sizingCell.isSizingCell = true

		let sizingHost = SizingHost(cell: sizingCell)

		if isSkeleton {
			self.skeletonSizingHosts[key] = sizingHost
		} else {
			self.sizingHosts[key] = sizingHost
		}

		return sizingHost
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

	/// Returns the height the given host's cell fits into at the given width.
	///
	/// - Parameters:
	///    - host: The host to measure.
	///    - width: The width the cell is given.
	///
	/// - Returns: The cell's fitting height.
	private func fittingHeight(of host: SizingHost, width: CGFloat) -> CGFloat {
		let height = host.layOutCell(atWidth: width)

		#if DEBUG
		assert(!host.cell.hasAmbiguousLayout, "\(type(of: host.cell)) has an ambiguous layout at width \(width).")
		#endif

		return height.rounded(.up)
	}

	#if DEBUG
	/// Returns the given item's measured height and records its split timings.
	///
	/// - Parameters:
	///    - item: The item to measure.
	///    - host: The host the measurement is taken from.
	///    - width: The width a single cell is given.
	///
	/// - Returns: The measured height.
	private func splitTimedHeight(of item: Item, in host: SizingHost, width: CGFloat) -> CGFloat {
		let configureStartedAt = CFAbsoluteTimeGetCurrent()
		item.configure(host.cell)
		let configureElapsed = (CFAbsoluteTimeGetCurrent() - configureStartedAt) * 1000.0

		let layoutStartedAt = CFAbsoluteTimeGetCurrent()
		let height = self.fittingHeight(of: host, width: width)
		let layoutElapsed = (CFAbsoluteTimeGetCurrent() - layoutStartedAt) * 1000.0

		let relayoutStartedAt = CFAbsoluteTimeGetCurrent()
		_ = self.fittingHeight(of: host, width: width + 1.0)
		let relayoutElapsed = (CFAbsoluteTimeGetCurrent() - relayoutStartedAt) * 1000.0
		_ = self.fittingHeight(of: host, width: width)

		self.recordMeasurementSplit(of: item.cellType, configure: configureElapsed, layout: layoutElapsed, relayout: relayoutElapsed)

		return height
	}

	/// Adds one cell's split timings to its type's running totals.
	///
	/// - Parameters:
	///    - cellType: The measured type of cell.
	///    - configure: The milliseconds the configure call took.
	///    - layout: The milliseconds the first layout took.
	///    - relayout: The milliseconds the width-only re-solve took.
	private func recordMeasurementSplit(of cellType: KCollectionViewCell.Type, configure: Double, layout: Double, relayout: Double) {
		let name = String(describing: cellType)
		var split = self.measurementSplits[name] ?? MeasurementSplit()

		split.add(configure: configure, layout: layout, relayout: relayout)

		self.measurementSplits[name] = split
		self.pendingMeasurementSplits.insert(name)
	}

	/// Prints the running totals of every cell type measured since the last report.
	func flushMeasurementSplits() {
		defer { self.pendingMeasurementSplits.removeAll() }

		for name in self.pendingMeasurementSplits.sorted() {
			guard let split = self.measurementSplits[name] else { continue }

			let configure = "\(String(format: "%.3f", split.averageConfigure))/\(String(format: "%.3f", split.maximumConfigure))ms"
			let layout = "\(String(format: "%.3f", split.averageLayout))/\(String(format: "%.3f", split.maximumLayout))ms"
			let relayout = "\(String(format: "%.3f", split.averageRelayout))/\(String(format: "%.3f", split.maximumRelayout))ms"

			print("----- [measure-split] \(name) n=\(split.count) configure avg/max \(configure) layout avg/max \(layout) relayout avg/max \(relayout)")
		}
	}

	/// Returns the width the given section was measured at during the current layout pass.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The recorded width.
	func measuredWidth(forSection section: Int) -> CGFloat? {
		return self.measuredWidths[section]
	}

	/// Reports every cell rendering at a different width than its section was measured at.
	///
	/// - Parameter cells: The cells currently on screen, the section of each, and the width each was measured at.
	func validateWidths(of cells: [(cell: UICollectionViewCell, section: Int, measuredWidth: CGFloat?)]) {
		defer { self.measuredWidths.removeAll() }

		for (cell, section, measuredWidth) in cells {
			guard let measuredWidth = measuredWidth else { continue }

			// A laid out frame is snapped to the pixel grid within a point of the measurement.
			guard abs(cell.bounds.width - measuredWidth) >= 1.0 else { continue }
			guard self.reportedWidthMismatches.insert(section).inserted else { continue }

			fatalError("ERROR: \(type(of: cell)) in section \(section) renders at width \(cell.bounds.width) but the section was measured at \(measuredWidth). Its measured height is wrong by every constraint that depends on width.")
		}
	}
	#endif
}

// MARK: - SizingHost
extension CellHeightMeasurer {
	/// A detached view that lays one sizing cell out at a given width.
	@MainActor
	final class SizingHost {
		// MARK: - Views
		/// The view the cell is laid out in.
		private let view = UIView()

		/// The cell the measurements are taken from.
		let cell: KCollectionViewCell

		// MARK: - Properties
		/// The width the cell is laid out at.
		private let widthConstraint: NSLayoutConstraint

		// MARK: - Initializers
		/// Creates a host around the given cell.
		///
		/// - Parameter cell: The cell to measure.
		init(cell: KCollectionViewCell) {
			self.cell = cell
			self.widthConstraint = cell.widthAnchor.constraint(equalToConstant: 0.0)

			let compressionConstraint = cell.heightAnchor.constraint(equalToConstant: 0.0)
			compressionConstraint.priority = .fittingSizeLevel

			cell.translatesAutoresizingMaskIntoConstraints = false
			cell.contentView.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(cell)

			NSLayoutConstraint.activate([
				cell.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				cell.topAnchor.constraint(equalTo: self.view.topAnchor),
				self.widthConstraint,
				compressionConstraint,

				cell.contentView.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
				cell.contentView.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
				cell.contentView.topAnchor.constraint(equalTo: cell.topAnchor),
				cell.contentView.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
			])
		}

		// MARK: - Functions
		/// Lays the cell out at the given width and returns the height it took.
		///
		/// - Parameter width: The width the cell is given.
		///
		/// - Returns: The laid out height.
		func layOutCell(atWidth width: CGFloat) -> CGFloat {
			self.widthConstraint.constant = width

			self.view.setNeedsLayout()
			self.view.layoutIfNeeded()

			return self.cell.bounds.height
		}
	}
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

		/// Whether the item renders the cell's skeleton.
		let isSkeleton: Bool

		// MARK: - Initializers
		/// Creates an item that measures the given cell once it is configured.
		///
		/// - Parameters:
		///    - cellType: The type of cell the content is rendered in.
		///    - isSkeleton: Whether the item renders the cell's skeleton.
		///    - configure: Applies the content to a sizing cell.
		init<Cell: KCollectionViewCell>(cellType: Cell.Type, isSkeleton: Bool = false, configure: @escaping (Cell) -> Void) {
			self.cellType = cellType
			self.isSkeleton = isSkeleton
			self.configure = { cell in
				guard let cell = cell as? Cell else { return }
				configure(cell)
			}
		}
	}
}

#if DEBUG
// MARK: - MeasurementSplit
extension CellHeightMeasurer {
	/// What one cell type's measurements cost, split by step.
	struct MeasurementSplit {
		// MARK: - Properties
		/// The number of measurements taken.
		var count = 0

		/// The total milliseconds spent configuring.
		var totalConfigure = 0.0

		/// The longest configure in milliseconds.
		var maximumConfigure = 0.0

		/// The total milliseconds spent on the first layout.
		var totalLayout = 0.0

		/// The longest first layout in milliseconds.
		var maximumLayout = 0.0

		/// The total milliseconds spent on the width-only re-solve.
		var totalRelayout = 0.0

		/// The longest width-only re-solve in milliseconds.
		var maximumRelayout = 0.0

		/// The mean milliseconds spent configuring.
		var averageConfigure: Double {
			return self.count > 0 ? self.totalConfigure / Double(self.count) : 0.0
		}

		/// The mean milliseconds spent on the first layout.
		var averageLayout: Double {
			return self.count > 0 ? self.totalLayout / Double(self.count) : 0.0
		}

		/// The mean milliseconds spent on the width-only re-solve.
		var averageRelayout: Double {
			return self.count > 0 ? self.totalRelayout / Double(self.count) : 0.0
		}

		// MARK: - Functions
		/// Adds one measurement to the totals.
		///
		/// - Parameters:
		///    - configure: The milliseconds the configure call took.
		///    - layout: The milliseconds the first layout took.
		///    - relayout: The milliseconds the width-only re-solve took.
		mutating func add(configure: Double, layout: Double, relayout: Double) {
			self.count += 1

			self.totalConfigure += configure
			self.maximumConfigure = max(self.maximumConfigure, configure)

			self.totalLayout += layout
			self.maximumLayout = max(self.maximumLayout, layout)

			self.totalRelayout += relayout
			self.maximumRelayout = max(self.maximumRelayout, relayout)
		}
	}
}
#endif

// MARK: - Environment
extension CellHeightMeasurer {
	/// The inputs that change what a sizing cell renders at a given width.
	struct Environment: Equatable {
		// MARK: - Properties
		/// The type size the cell is laid out at.
		let contentSizeCategory: UIContentSizeCategory

		/// The locale the cell's strings are rendered in.
		let locale: Locale
	}
}
