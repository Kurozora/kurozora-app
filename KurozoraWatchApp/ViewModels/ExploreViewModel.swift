//
//  ExploreViewModel.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 12/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import Observation
import TRON

@MainActor @Observable
final class ExploreViewModel {
	// MARK: - Properties
	var loadState: LoadState = .idle
	var categories: [ExploreCategory] = []

	/// Per-category show models. `nil` value = skeleton state, empty array = loaded but empty.
	var showsByCategory: [String: [Show]?] = [:]

	private var hasFetchedOnce = false

	// MARK: - Functions
	func fetchIfNeeded() async {
		guard !self.hasFetchedOnce else { return }
		await self.fetchExplore()
	}

	func refresh() async {
		self.hasFetchedOnce = false
		await self.fetchExplore()
	}

	// MARK: - Private
	private func fetchExplore() async {
		self.hasFetchedOnce = true
		self.loadState = .loading

		do {
			// Phase 1: Fetch category identities
			let response = try await KService.getExplore().value
			let fetchedCategories = response.data.filter { category in
				guard let showIdentities = category.relationships.shows?.data else { return false }
				return !showIdentities.isEmpty
			}

			self.categories = fetchedCategories

			// Initialize all categories in skeleton state
			for category in fetchedCategories {
				self.showsByCategory[category.id.description] = nil as [Show]?
			}

			// View can now render skeleton sections
			self.loadState = .loaded

			// Phase 2: Fetch show details per category concurrently
			await withTaskGroup(of: Void.self) { group in
				for category in fetchedCategories {
					group.addTask {
						await self.fetchShows(for: category)
					}
				}
			}
		} catch {
			self.hasFetchedOnce = false
			if self.categories.isEmpty {
				self.loadState = .error("Failed to load explore.")
			}
			NSLog("Explore fetch error: %@", error.localizedDescription)
		}
	}

	private func fetchShows(for category: ExploreCategory) async {
		guard let showIdentities = category.relationships.shows?.data, !showIdentities.isEmpty else { return }

		let limited = Array(showIdentities.prefix(10))

		do {
			let showResponse = try await KService.getDetails(forShows: limited).value
			self.showsByCategory[category.id.description] = showResponse.data
		} catch {
			NSLog("Failed to fetch shows for category %@: %@", category.attributes.title, error.localizedDescription)
			self.showsByCategory[category.id.description] = []
		}
	}
}
