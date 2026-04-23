//
//  LibraryViewModel.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 12/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import Observation

@MainActor @Observable
final class LibraryViewModel {
	// MARK: - Properties
	var loadState: LoadState = .idle
	var shows: [Show] = []

	private var hasFetchedOnce = false

	// MARK: - Functions
	func fetchIfNeeded() async {
		guard !self.hasFetchedOnce else { return }
		await self.fetchLibrary()
	}

	func refresh() async {
		self.hasFetchedOnce = false
		await self.fetchLibrary()
	}

	// MARK: - Private
	private func fetchLibrary() async {
		self.hasFetchedOnce = true
		self.loadState = .loading

		do {
			let response = try await KService
				.library(.shows, status: .inProgress)
				.limit(25)
				.response()
			self.shows = response.data.shows ?? []
			self.loadState = .loaded
		} catch {
			self.hasFetchedOnce = false
			self.loadState = .error("Failed to load library.")
			NSLog("Library fetch error: %@", error.localizedDescription)
		}
	}
}
