//
//  SectionFetchable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/11/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A protocol that provides functionality for fetching and caching model data for the sections of a diffable data source.
@MainActor
protocol SectionFetchable: AnyObject {
	// MARK: - Associated Types
	/// The type that identifies each section in the data source.
	associatedtype SectionLayoutKind: Hashable, Sendable
	/// The type that identifies each item in the data source.
	associatedtype ItemKind: Hashable, Sendable
	/// The diffable data source type keyed by `SectionLayoutKind` and `ItemKind`.
	associatedtype DataSource: DiffableDataSourceProtocol
		where DataSource.SectionIdentifierType == SectionLayoutKind,
		DataSource.ItemIdentifierType == ItemKind

	// MARK: - Properties
	/// A cache of fetched models keyed by the item they fill.
	var cache: [ItemKind: KurozoraItem] { get set }
	/// The set of sections that currently have an in-flight fetch.
	var isFetchingSection: Set<SectionLayoutKind> { get set }

	/// The current snapshot of the data source.
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! { get }
	/// The diffable data source that backs the view controller.
	var dataSource: DataSource! { get }

	// MARK: - Methods
	/// Returns the identity contained in the given item, if one exists.
	///
	/// - Parameter item: The item from which to extract an identity.
	///
	/// - Returns: The identity of type `Element`, or `nil` if the item doesn't contain one.
	func extractIdentity<Element: KurozoraItem>(from item: ItemKind) -> Element?

	/// Returns the item that measures the given item's cell.
	///
	/// - Parameters:
	///    - itemKind: The item whose cell is measured.
	///    - section: The section the item belongs to.
	///
	/// - Returns: The item that measures the cell.
	func measurableItem(for itemKind: ItemKind, in section: SectionLayoutKind) -> CellHeightMeasurer.Item?

	/// Returns the width a single cell of the given section is given.
	///
	/// - Parameters:
	///    - section: The section whose cells are measured.
	///    - containerWidth: The width available to the collection view's content.
	///
	/// - Returns: The width of one cell.
	func measuredItemWidth(for section: SectionLayoutKind, containerWidth: CGFloat) -> CGFloat?

	/// Measures and stores the heights of the given items' cells.
	///
	/// - Parameter items: The items whose cells to measure.
	func measureCellHeights(of items: [ItemKind])

	/// Measures and stores the heights of every section's cells.
	func remeasureAllCellHeights()
}

extension SectionFetchable {
	func measurableItem(for itemKind: ItemKind, in section: SectionLayoutKind) -> CellHeightMeasurer.Item? {
		return nil
	}

	func measuredItemWidth(for section: SectionLayoutKind, containerWidth: CGFloat) -> CGFloat? {
		return nil
	}

	func measureCellHeights(of items: [ItemKind]) {}

	func remeasureAllCellHeights() {}

	/// Returns the cached model at the given index path.
	///
	/// - Parameter indexPath: The index path whose model you want to retrieve.
	///
	/// - Returns: The cached model of type `M`.
	func fetchModel<M: KurozoraItem>(at indexPath: IndexPath) -> M? {
		return self.cachedItem(at: indexPath) as? M
	}

	/// Returns the cached model of the given item.
	///
	/// - Parameter itemKind: The item whose model you want to retrieve.
	///
	/// - Returns: The cached model of type `M`.
	func fetchModel<M: KurozoraItem>(for itemKind: ItemKind) -> M? {
		return self.cache[itemKind] as? M
	}

	/// Returns the cached model at the given index path, whatever its type.
	///
	/// - Parameter indexPath: The index path whose model you want to retrieve.
	///
	/// - Returns: The cached model.
	func cachedItem(at indexPath: IndexPath) -> KurozoraItem? {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

		return self.cache[itemKind]
	}

	/// Returns the items the given section lays out.
	///
	/// - Parameter section: The section whose items you want to retrieve.
	///
	/// - Returns: The items of the section.
	func itemKinds(inSection section: Int) -> [ItemKind] {
		guard let sectionIdentifier = self.snapshot?.sectionIdentifiers[safe: section] else { return [] }

		return self.snapshot.itemIdentifiers(inSection: sectionIdentifier)
	}

	/// Returns the cached models of the given section.
	///
	/// - Parameter section: The section whose models you want to retrieve.
	///
	/// - Returns: The cached models of type `Model`.
	func cachedModels<Model: KurozoraItem>(inSection section: Int) -> [Int: Model] {
		var models: [Int: Model] = [:]

		for (index, itemKind) in self.itemKinds(inSection: section).enumerated() {
			guard let model = self.cache[itemKind] as? Model else { continue }
			models[index] = model
		}

		return models
	}

	/// Returns every cached model in the given section, whatever their types, keyed by their item index.
	///
	/// - Parameter section: The section whose models you want to retrieve.
	///
	/// - Returns: The cached models, keyed by their item index.
	func cachedItems(inSection section: Int) -> [Int: KurozoraItem] {
		var items: [Int: KurozoraItem] = [:]

		for (index, itemKind) in self.itemKinds(inSection: section).enumerated() {
			guard let item = self.cache[itemKind] else { continue }
			items[index] = item
		}

		return items
	}

	/// Returns the cached model of the given item and fetches its section when nothing is cached.
	///
	/// - Parameters:
	///    - itemKind: The item whose model you want to retrieve.
	///    - response: The response type used to fetch the section.
	///    - identity: The identity type extracted from each item in the section.
	///
	/// - Returns: The cached model of type `Model`.
	func fetchModelOrTriggerSectionFetch<Model: KurozoraItem, Response: KurozoraRequestable, Identity: Fetchable>(for itemKind: ItemKind, response: Response.Type, identity: Identity.Type) -> Model? where Identity.Response == Response {
		let model: Model? = self.fetchModel(for: itemKind)

		if model == nil,
		   let section = self.snapshot.sectionIdentifier(containingItem: itemKind),
		   !self.isFetchingSection.contains(section) {
			Task { await self.fetchSectionIfNeeded(Response.self, Identity.self, for: itemKind) }
		}

		return model
	}

	/// Reconfigures every item in the given section, prompting the data source to redraw them.
	///
	/// - Parameter section: The section whose items need to be updated.
	func setSectionNeedsUpdate(_ section: SectionLayoutKind) {
		var snapshot = self.dataSource.snapshot()

		guard snapshot.indexOfSection(section) != nil else { return }

		let itemsInSection = snapshot.itemIdentifiers(inSection: section)
		snapshot.reconfigureItems(itemsInSection)
		self.measureCellHeights(of: itemsInSection)

		#if DEBUG
		print("----- [apply] setSectionNeedsUpdate \(section) items \(itemsInSection.count)")
		#endif

		self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
	}

	/// Reconfigures every item the given predicate matches.
	///
	/// - Parameter matches: Returns whether the item needs to be redrawn.
	func reconfigureItems(where matches: (ItemKind) -> Bool) {
		guard let dataSource = self.dataSource else { return }

		var snapshot = dataSource.snapshot()
		let matchedItems = snapshot.itemIdentifiers.filter(matches)

		guard !matchedItems.isEmpty else { return }

		snapshot.reconfigureItems(matchedItems)
		self.measureCellHeights(of: matchedItems)
		dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
	}

	/// Returns whether the given item's episode has a watch status change still settling.
	///
	/// - Parameter itemKind: The item whose episode is inspected.
	///
	/// - Returns: Whether the change is still settling.
	func isEpisodeWatchStatusPending(for itemKind: ItemKind) -> Bool {
		let episodeIdentity: EpisodeIdentity? = self.extractIdentity(from: itemKind)

		guard let episodeIdentity = episodeIdentity else { return false }

		return WatchedStore.shared.isPending(forEpisodeID: episodeIdentity.id.rawValue)
	}

	/// Records whether the given episode's watch status change is still settling and redraws its items.
	///
	/// - Parameters:
	///    - isPending: Whether the change is still settling.
	///    - episodeID: The identifier of the episode.
	func setEpisodeWatchStatusPending(_ isPending: Bool, forEpisodeID episodeID: String) {
		WatchedStore.shared.setPending(isPending, forEpisodeID: episodeID)

		self.reconfigureItems { itemKind in
			let episodeIdentity: EpisodeIdentity? = self.extractIdentity(from: itemKind)

			return episodeIdentity?.id.rawValue == episodeID
		}
	}

	/// Fetches details for every uncached item in the section that holds the given item.
	///
	/// - Parameters:
	///    - response: The response type used to fetch the items.
	///    - item: The identity type extracted from each item in the section.
	///    - itemKind: The item whose section to fetch.
	func fetchSectionIfNeeded<I: KurozoraRequestable, Element: Fetchable>(_ response: I.Type, _ item: Element.Type, for itemKind: ItemKind) async where Element.Response == I {
		guard
			self.cache[itemKind] == nil,
			let section = self.snapshot.sectionIdentifier(containingItem: itemKind),
			!self.isFetchingSection.contains(section)
		else { return }

		self.isFetchingSection.insert(section)
		defer { self.isFetchingSection.remove(section) }

		let chunkSize = 25

		do {
			while true {
				let currentSnapshot = self.dataSource.snapshot()
				guard currentSnapshot.indexOfSection(section) != nil else { break }

				let uncached: [(itemKind: ItemKind, identity: Element)] = currentSnapshot
					.itemIdentifiers(inSection: section)
					.compactMap { itemKind in
						guard self.cache[itemKind] == nil else { return nil }
						guard let identity: Element = self.extractIdentity(from: itemKind) else { return nil }

						return (itemKind, identity)
					}

				guard !uncached.isEmpty else { break }

				let chunk = Array(uncached.prefix(chunkSize))
				let identitiesToFetch = chunk.map { $0.identity }
				let response: I = try await KService.details(identitiesToFetch).response()

				// If the section is no longer in the snapshot, abandon this fetch.
				guard self.dataSource.snapshot().indexOfSection(section) != nil else { break }

				let itemKinds = Dictionary(chunk.map { ($0.identity.id, $0.itemKind) }, uniquingKeysWith: { first, _ in first })
				var cachedThisIteration: [ItemKind] = []

				for model in response.data {
					guard let itemKind = itemKinds[model.id] else { continue }

					self.cache[itemKind] = model
					cachedThisIteration.append(itemKind)
				}

				// Avoid re-requesting the same uncached set when the server returns nothing usable.
				guard !cachedThisIteration.isEmpty else { break }

				var snapshot = self.dataSource.snapshot()
				let reconfigured = cachedThisIteration.filter { snapshot.indexOfItem($0) != nil }

				if !reconfigured.isEmpty {
					snapshot.reconfigureItems(reconfigured)
					self.measureCellHeights(of: reconfigured)

					#if DEBUG
					print("----- [apply] fetchSectionIfNeeded \(section) items \(reconfigured.count)")
					#endif

					self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
				}
			}
		} catch {
			print("----- Fetch error for section \(section): \(error)")
		}
	}
}

// MARK: - Measurement
extension SectionFetchable where Self: KCollectionViewController {
	/// Returns the height of the tallest cell the given section's cached models render.
	///
	/// - Parameters:
	///    - section: The section to measure.
	///    - width: The width a single cell is given.
	///    - layoutEnvironment: The environment the section is laid out in.
	///    - measurableItem: Returns the item that measures the cached model at an item index.
	///
	/// - Returns: The tallest measured height.
	func maximumCellHeight<Model: KurozoraItem>(inSection section: Int, width: CGFloat, layoutEnvironment: NSCollectionLayoutEnvironment, measurableItem: (Int, Model) -> CellHeightMeasurer.Item) -> CGFloat? {
		let models: [Int: Model] = self.cachedModels(inSection: section)
		let items = models.map { measurableItem($0.key, $0.value) }

		return self.maximumCellHeight(for: items, inSection: section, width: width, layoutEnvironment: layoutEnvironment)
	}

	func measureCellHeights(of items: [ItemKind]) {
		guard !self.cellHeightStore.isEmpty else { return }

		let containerWidth = self.layoutContainerWidth

		guard containerWidth > 0.0 else { return }

		let environment = self.cellHeightEnvironment()

		guard self.cellHeightStore.matches(containerWidth: containerWidth, environment: environment) else {
			self.remeasureAllCellHeights()
			return
		}

		var itemsBySection: [SectionLayoutKind: [ItemKind]] = [:]
		var fallbackSnapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>?
		var didLoadFallbackSnapshot = false

		for item in items {
			var section = self.cellHeightStore.section(containing: AnyHashable(item)) as? SectionLayoutKind

			if section == nil {
				if !didLoadFallbackSnapshot {
					fallbackSnapshot = self.dataSource?.snapshot()
					didLoadFallbackSnapshot = true
				}

				section = fallbackSnapshot?.sectionIdentifier(containingItem: item)
			}

			guard let section = section else { continue }

			itemsBySection[section, default: []].append(item)
		}

		for (section, sectionItems) in itemsBySection {
			self.measureCellHeights(of: sectionItems, in: section, containerWidth: containerWidth, environment: environment)
		}
	}

	func remeasureAllCellHeights() {
		let containerWidth = self.layoutContainerWidth

		guard containerWidth > 0.0 else { return }

		let environment = self.cellHeightEnvironment()
		self.cellHeightStore.reset(containerWidth: containerWidth, environment: environment)

		#if DEBUG
		let startedAt = CFAbsoluteTimeGetCurrent()
		#endif

		let sections = self.cellHeightStore.sections.compactMap { $0.base as? SectionLayoutKind }

		for section in sections {
			let items = self.cellHeightStore.items(in: AnyHashable(section)).compactMap { $0.base as? ItemKind }
			self.measureCellHeights(of: items, in: section, containerWidth: containerWidth, environment: environment)
		}

		#if DEBUG
		let elapsed = (CFAbsoluteTimeGetCurrent() - startedAt) * 1000.0
		print("----- [measure] all sections \(sections.count) width \(String(format: "%.1f", containerWidth)) \(String(format: "%.1f", elapsed))ms")
		#endif
	}

	/// Replaces the items the given section lays out.
	///
	/// - Parameters:
	///    - items: The items the section lays out.
	///    - section: The section the items belong to.
	func setMeasuredItems(_ items: [ItemKind], for section: SectionLayoutKind) {
		self.cellHeightStore.setItems(items.map { AnyHashable($0) }, for: AnyHashable(section))
	}

	/// Drops every measured section absent from the given list.
	///
	/// - Parameter sections: The sections the store keeps.
	func removeMeasuredSections(notIn sections: [SectionLayoutKind]) {
		self.cellHeightStore.removeSections(notIn: sections.map { AnyHashable($0) })
	}

	/// Returns the items of the given section that carry no measured height.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The items without a measured height.
	func unmeasuredItems(in section: SectionLayoutKind) -> [ItemKind] {
		return self.cellHeightStore.unmeasuredItems(in: AnyHashable(section)).compactMap { $0.base as? ItemKind }
	}

	/// Returns the height of the tallest measured cell in the given section.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The tallest measured height.
	func cellHeight(for section: SectionLayoutKind) -> CGFloat? {
		return self.cellHeightStore.height(for: AnyHashable(section))
	}

	/// Returns the width a single cell of the given section was measured at.
	///
	/// - Parameter section: The section to look up.
	///
	/// - Returns: The width of one cell.
	func measuredItemWidth(forSection section: SectionLayoutKind) -> CGFloat? {
		return self.cellHeightStore.itemWidth(for: AnyHashable(section))
	}

	/// Returns the inputs that change what the controller's cells render.
	///
	/// - Returns: The measurement environment.
	private func cellHeightEnvironment() -> CellHeightMeasurer.Environment {
		return CellHeightMeasurer.Environment(contentSizeCategory: self.traitCollection.preferredContentSizeCategory, locale: LanguageManager.shared.locale)
	}

	/// Measures and stores the heights of the given section's items.
	///
	/// - Parameters:
	///    - items: The items whose cells to measure.
	///    - section: The section the items belong to.
	///    - containerWidth: The width available to the collection view's content.
	///    - environment: The inputs that change what a cell renders.
	private func measureCellHeights(of items: [ItemKind], in section: SectionLayoutKind, containerWidth: CGFloat, environment: CellHeightMeasurer.Environment) {
		guard let itemWidth = self.measuredItemWidth(for: section, containerWidth: containerWidth) else { return }

		self.cellHeightStore.setItemWidth(itemWidth, for: AnyHashable(section))

		#if DEBUG
		let startedAt = CFAbsoluteTimeGetCurrent()
		var cellTypes: Set<String> = []
		var measuredCount = 0
		#endif

		for item in items {
			guard let measurableItem = self.measurableItem(for: item, in: section) else { continue }

			let height = self.cellHeightMeasurer.height(of: measurableItem, width: itemWidth, contentSizeCategory: environment.contentSizeCategory)
			self.cellHeightStore.setHeight(height, for: AnyHashable(item))

			#if DEBUG
			cellTypes.insert(String(describing: measurableItem.cellType))
			measuredCount += 1
			#endif
		}

		#if DEBUG
		guard measuredCount > 0 else { return }

		let elapsed = (CFAbsoluteTimeGetCurrent() - startedAt) * 1000.0
		let sectionIndex: Int? = self.snapshot?.indexOfSection(section) ?? nil
		let storedHeight = self.cellHeight(for: section)
		print("----- [measure] section \(sectionIndex.map(String.init) ?? "?") \(Self.name(of: section)) items \(measuredCount) \(String(format: "%.1f", elapsed))ms height \(storedHeight.map { String(format: "%.1f", $0) } ?? "-") cells \(cellTypes.sorted())")
		#endif
	}

	#if DEBUG
	/// Returns the given section's case name without its associated values.
	///
	/// - Parameter section: The section to describe.
	///
	/// - Returns: The section's case name.
	private static func name(of section: SectionLayoutKind) -> String {
		let description = String(describing: section)

		guard let openingParenthesis = description.firstIndex(of: "(") else { return description }

		return String(description[description.startIndex ..< openingParenthesis])
	}
	#endif
}
