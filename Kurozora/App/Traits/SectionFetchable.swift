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
	associatedtype SectionLayoutKind: Hashable
	/// The type that identifies each item in the data source.
	associatedtype ItemKind: Hashable
	/// The diffable data source type keyed by `SectionLayoutKind` and `ItemKind`.
	associatedtype DataSource: DiffableDataSourceProtocol
		where DataSource.SectionIdentifierType == SectionLayoutKind,
		DataSource.ItemIdentifierType == ItemKind

	// MARK: - Properties
	/// A cache of fetched models keyed by their index path.
	var cache: [IndexPath: KurozoraItem] { get set }
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
}

extension SectionFetchable {
	/// Returns the cached model at the given index path.
	///
	/// - Parameter indexPath: The index path whose model you want to retrieve.
	///
	/// - Returns: The cached model of type `M`, or `nil` if no model is cached at that index path.
	func fetchModel<M: KurozoraItem>(at indexPath: IndexPath) -> M? {
		self.cache[indexPath] as? M
	}

	/// Returns the cached model at the given index path, starting a batched section fetch when no model is cached.
	///
	/// - Parameters:
	///    - indexPath: The index path whose model you want to retrieve.
	///    - itemKind: The item at the given index path.
	///    - response: The response type used to fetch the section.
	///    - identity: The identity type extracted from each item in the section.
	///
	/// - Returns: The cached model of type `Model`, or `nil` if no model is cached yet.
	func fetchModelOrTriggerSectionFetch<Model: KurozoraItem, Response: KurozoraRequestable, Identity: Fetchable>(at indexPath: IndexPath, itemKind: ItemKind, response: Response.Type, identity: Identity.Type) -> Model? where Identity.Response == Response {
		let model: Model? = self.fetchModel(at: indexPath)

		if model == nil,
		   let section = self.snapshot.sectionIdentifier(containingItem: itemKind),
		   !self.isFetchingSection.contains(section) {
			Task { await self.fetchSectionIfNeeded(Response.self, Identity.self, at: indexPath, itemKind: itemKind) }
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
		self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
	}

	/// Fetches details for every uncached item in the section that contains the given index path.
	///
	/// Items are fetched in chunks and applied to the snapshot as each chunk completes,
	/// so rows become visible without waiting for the entire section to load.
	///
	/// - Parameters:
	///    - response: The response type used to fetch the items.
	///    - item: The identity type extracted from each item in the section.
	///    - indexPath: An index path within the section to fetch.
	///    - itemKind: The item at the given index path.
	func fetchSectionIfNeeded<I: KurozoraRequestable, Element: Fetchable>(_ response: I.Type, _ item: Element.Type, at indexPath: IndexPath, itemKind: ItemKind) async where Element.Response == I {
		guard
			self.cache[indexPath] == nil,
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

				let identities: [Element] = currentSnapshot
					.itemIdentifiers(inSection: section)
					.compactMap { self.extractIdentity(from: $0) }

				let uncached: [(index: Int, identity: Element)] = identities.enumerated().compactMap { index, id in
					let ip = IndexPath(item: index, section: indexPath.section)
					return self.cache[ip] == nil ? (index, id) : nil
				}

				guard !uncached.isEmpty else { break }

				let chunk = Array(uncached.prefix(chunkSize))
				let identitiesToFetch = chunk.map { $0.identity }
				let response: I = try await KService.details(identitiesToFetch).response()

				// If the section is no longer in the snapshot, abandon this fetch.
				guard self.dataSource.snapshot().indexOfSection(section) != nil else { break }

				let orderLookup = Dictionary(identitiesToFetch.enumerated().map { ($1.id, $0) }, uniquingKeysWith: { first, _ in first })
				let sorted = response.data.sorted {
					guard
						let lhsIndex = orderLookup[$0.id],
						let rhsIndex = orderLookup[$1.id]
					else { return false }
					return lhsIndex < rhsIndex
				}

				let chunkLookup = Dictionary(chunk.map { ($0.identity.id, $0.index) }, uniquingKeysWith: { first, _ in first })
				var cachedThisIteration = 0
				for model in sorted {
					if let originalIndex = chunkLookup[model.id] {
						let ip = IndexPath(item: originalIndex, section: indexPath.section)
						self.cache[ip] = model
						cachedThisIteration += 1
					}
				}

				// Avoid re-requesting the same uncached set when the server returns nothing usable.
				guard cachedThisIteration > 0 else { break }

				let postFetchSnapshot = self.dataSource.snapshot()
				let sectionItems = postFetchSnapshot.itemIdentifiers(inSection: section)
				let reconfigured: [ItemKind] = chunk.compactMap { sectionItems[safe: $0.index] }

				if !reconfigured.isEmpty {
					var snapshot = postFetchSnapshot
					snapshot.reconfigureItems(reconfigured)
					self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
				}
			}
		} catch {
			print("----- Fetch error for section \(section): \(error)")
		}
	}
}
