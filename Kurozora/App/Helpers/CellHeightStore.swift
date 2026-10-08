//
//  CellHeightStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreGraphics

/// Holds the measured cell height of every item a controller lays out.
@MainActor
final class CellHeightStore<Section: Hashable, Item: Hashable> {
	// MARK: - Properties
	/// The container width the stored heights were measured at.
	private(set) var containerWidth: CGFloat = 0.0

	/// The environment the stored heights were measured in.
	private(set) var environment: CellHeightMeasurer.Environment?

	/// The items each section lays out.
	private var itemsBySection: [Section: [Item]] = [:]

	/// The section each item belongs to.
	private var sectionByItem: [Item: Section] = [:]

	/// The measured height of each item.
	private var heights: [Item: CGFloat] = [:]

	/// The width a single cell was measured at, per section.
	private var itemWidths: [Section: CGFloat] = [:]

	/// The sections the store holds items for.
	var sections: [Section] {
		return Array(self.itemsBySection.keys)
	}

	/// Whether the store holds no membership.
	var isEmpty: Bool {
		return self.itemsBySection.isEmpty
	}

	// MARK: - Functions
	/// Replaces the items of the given section.
	///
	/// - Parameters:
	///    - items: The items the section lays out.
	///    - section: The section the items belong to.
	func setItems(_ items: [Item], for section: Section) {
		let retained = Set(items)

		for item in self.itemsBySection[section] ?? [] {
			guard !retained.contains(item) else { continue }
			guard self.sectionByItem[item] == section else { continue }

			self.sectionByItem.removeValue(forKey: item)
			self.heights.removeValue(forKey: item)
		}

		self.itemsBySection[section] = items

		for item in items {
			self.sectionByItem[item] = section
		}
	}

	/// Drops every section absent from the given list.
	///
	/// - Parameter sections: The sections the store keeps.
	func removeSections(notIn sections: [Section]) {
		let retained = Set(sections)

		for section in Array(self.itemsBySection.keys) {
			guard !retained.contains(section) else { continue }

			self.setItems([], for: section)
			self.itemsBySection.removeValue(forKey: section)
			self.itemWidths.removeValue(forKey: section)
		}
	}

	/// Stores the measured height of the given item.
	///
	/// - Parameters:
	///    - height: The measured height.
	///    - item: The item the height belongs to.
	func setHeight(_ height: CGFloat, for item: Item) {
		self.heights[item] = height
	}

	/// Stores the width a single cell of the given section was measured at.
	///
	/// - Parameters:
	///    - width: The width of one cell.
	///    - section: The section the width belongs to.
	func setItemWidth(_ width: CGFloat, for section: Section) {
		self.itemWidths[section] = width
	}

	/// Returns the height of the tallest item in the given section.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The tallest stored height.
	func height(for section: Section) -> CGFloat? {
		return (self.itemsBySection[section] ?? []).compactMap { self.heights[$0] }.max()
	}

	/// Returns the width a single cell of the given section was measured at.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The width of one cell.
	func itemWidth(for section: Section) -> CGFloat? {
		return self.itemWidths[section]
	}

	/// Returns the items of the given section.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The items the section lays out.
	func items(in section: Section) -> [Item] {
		return self.itemsBySection[section] ?? []
	}

	/// Returns the items of the given section that carry no height.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The items without a stored height.
	func unmeasuredItems(in section: Section) -> [Item] {
		return (self.itemsBySection[section] ?? []).filter { self.heights[$0] == nil }
	}

	/// Returns the section that holds the given item.
	///
	/// - Parameter item: The item to look up.
	///
	/// - Returns: The section the item belongs to.
	func section(containing item: Item) -> Section? {
		return self.sectionByItem[item]
	}

	/// Returns whether the stored heights match the given width and environment.
	///
	/// - Parameters:
	///    - containerWidth: The width available to the content.
	///    - environment: The inputs that change what a cell renders.
	///
	/// - Returns: Whether the stored heights still apply.
	func matches(containerWidth: CGFloat, environment: CellHeightMeasurer.Environment) -> Bool {
		return self.containerWidth == containerWidth && self.environment == environment
	}

	/// Drops every stored height and adopts the given width and environment.
	///
	/// - Parameters:
	///    - containerWidth: The width available to the content.
	///    - environment: The inputs that change what a cell renders.
	func reset(containerWidth: CGFloat, environment: CellHeightMeasurer.Environment) {
		self.containerWidth = containerWidth
		self.environment = environment
		self.heights.removeAll()
		self.itemWidths.removeAll()
	}
}
