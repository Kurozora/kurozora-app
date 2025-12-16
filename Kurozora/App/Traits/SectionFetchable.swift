//
//  SectionFetchable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/11/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A protocol that provides functionality for fetching and caching section data in a view controller.
@MainActor
protocol SectionFetchable: AnyObject {
	// MARK: - Associated Types
	/// The type of sections in the view controller.
	associatedtype SectionLayoutKind: Hashable
	/// The type of items in the view controller.
	associatedtype ItemKind: Hashable
	/// The type of the diffable data source used by the view controller.
	associatedtype DataSource: DiffableDataSourceProtocol
		where DataSource.SectionIdentifierType == SectionLayoutKind,
		DataSource.ItemIdentifierType == ItemKind

	// MARK: - Properties
	/// A cache mapping IndexPaths to their corresponding KurozoraItem models.
	var cache: [IndexPath: KurozoraItem] { get set }
	/// A set of sections currently being fetched to prevent duplicate fetches.
	var isFetchingSection: Set<SectionLayoutKind> { get set }

	/// The current snapshot of the data source.
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! { get }
	/// The view controller's diffable data source.
	var dataSource: DataSource! { get }

	// MARK: - Methods
	/// Extracts a Kurozora identity from an ItemKind
	func extractIdentity<Element: KurozoraItem>(from item: ItemKind) -> Element?
}

extension SectionFetchable {
	/// Fetches a cached model of the specified type at the given index path.
	///
	/// - Parameter indexPath: The index path of the item.
	///
	/// - Returns: The cached model of type `M` if available, otherwise `nil`.
	func fetchModel<M: KurozoraItem>(at indexPath: IndexPath) -> M? {
		self.cache[indexPath] as? M
	}

	/// Marks all items in the given section as needing an update by reconfiguring them in the data source snapshot.
	///
	/// - Parameter section: The section to mark for update.
	func setSectionNeedsUpdate(_ section: SectionLayoutKind) {
		var snapshot = self.dataSource.snapshot()

		guard snapshot.indexOfSection(section) != nil else { return }

		let itemsInSection = snapshot.itemIdentifiers(inSection: section)
		snapshot.reconfigureItems(itemsInSection)
		self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
	}

	/// Fetches details for all uncached identities in the section containing the given index path.
	///
	/// - Parameters:
	///   - response: The `KurozoraRequestable` type to fetch.
	///   - item: The `KurozoraItem` type to extract identities from.
	///   - indexPath: The index path that triggered the fetch.
	///   - itemKind: The item kind at the given index path.
	func fetchSectionIfNeeded<
		I: KurozoraRequestable,
		Element: KurozoraItem
	>(
		_ response: I.Type,
		_ item: Element.Type,
		at indexPath: IndexPath,
		itemKind: ItemKind
	) async {
		guard
			self.cache[indexPath] == nil,
			let section = self.snapshot.sectionIdentifier(containingItem: itemKind),
			!self.isFetchingSection.contains(section)
		else { return }

		self.isFetchingSection.insert(section)
		defer { self.isFetchingSection.remove(section) }

		// Extract all identities in this section
		let identities: [Element] = self.snapshot
			.itemIdentifiers(inSection: section)
			.compactMap { self.extractIdentity(from: $0) }

		// Identify only the uncached ones
		let uncached: [(index: Int, identity: Element)] = identities.enumerated().compactMap { index, id in
			let ip = IndexPath(item: index, section: indexPath.section)
			return self.cache[ip] == nil ? (index, id) : nil
		}

		guard !uncached.isEmpty else { return }

		// Chunk to respect API limits
		let chunkSize = 25
		let chunks = uncached.chunked(into: chunkSize)

		// Fetch each chunk sequentially
		do {
			for chunk in chunks {
				let identitiesToFetch = chunk.map { $0.identity }
				let response: I = try await KService.getDetails(for: identitiesToFetch).value

				// Preserve order relative to the chunk
				let orderLookup = Dictionary(uniqueKeysWithValues: identitiesToFetch.enumerated().map { ($1.id, $0) })
				let sorted = response.data.sorted {
					guard
						let lhsIndex = orderLookup[$0.id],
						let rhsIndex = orderLookup[$1.id]
					else { return false }
					return lhsIndex < rhsIndex
				}

				// Cache results at their correct global index paths
				for (localIdx, model) in sorted.enumerated() {
					let originalIndex = chunk[localIdx].index
					let ip = IndexPath(item: originalIndex, section: indexPath.section)
					self.cache[ip] = model
				}
			}

			self.setSectionNeedsUpdate(section)
		} catch {
			print("----- Fetch error for section \(section): \(error)")
		}
	}
}
