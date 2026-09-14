//
//  SpotlightManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import CoreData
import CoreSpotlight
import MobileCoreServices
import os.log

private nonisolated let spotlightLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "SpotlightManager")

/// Keeps the account's library searchable from Spotlight.
actor SpotlightManager {
	// MARK: - Properties
	/// Returns the singleton `SpotlightManager` instance.
	static let shared = SpotlightManager()

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Rebuilds the Spotlight index from the account's library.
	///
	/// - Parameter userSlug: The user's account slug.
	func refresh(forUserSlug userSlug: String) async {
		guard CSSearchableIndex.isIndexingAvailable() else { return }

		let items = await self.items(forUserSlug: userSlug)

		do {
			try await CSSearchableIndex.default().deleteAllSearchableItems()
			guard !items.isEmpty else { return }
			try await CSSearchableIndex.default().indexSearchableItems(items)
			spotlightLogger.info("INDEX items=\(items.count)")
		} catch {
			spotlightLogger.error("Indexing failed: \(error.localizedDescription, privacy: .public)")
		}
	}

	/// Removes every item the app has indexed.
	func clear() async {
		guard CSSearchableIndex.isIndexingAvailable() else { return }

		do {
			try await CSSearchableIndex.default().deleteAllSearchableItems()
		} catch {
			spotlightLogger.error("Clearing the index failed: \(error.localizedDescription, privacy: .public)")
		}
	}

	/// The searchable items for the account's library.
	///
	/// - Parameter userSlug: The user's account slug.
	///
	/// - Returns: One item per visible library entry.
	private func items(forUserSlug userSlug: String) async -> [CSSearchableItem] {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true

		return await context.perform {
			let request = LocalLibraryEntry.fetchRequest()
			request.predicate = NSPredicate(format: "userSlug == %@ AND isHidden == NO", userSlug)
			request.relationshipKeyPathsForPrefetching = ["trackable"]

			guard let entries = try? context.fetch(request) else { return [] }

			return entries.compactMap { entry in
				guard entry.trackable?.title != nil else { return nil }

				return CSSearchableItem(
					uniqueIdentifier: entry.spotlightIdentifier,
					domainIdentifier: entry.spotlightDomainIdentifier,
					attributeSet: entry.contentAttributeSet
				)
			}
		}
	}
}
