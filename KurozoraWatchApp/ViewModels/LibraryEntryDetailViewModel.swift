//
//  LibraryEntryDetailViewModel.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import Observation

/// Follows one library entry in the local store and routes its status changes through the outbox.
@MainActor @Observable
final class LibraryEntryDetailViewModel {
	// MARK: - Properties
	/// The snapshot the detail screen was opened with.
	let item: LibraryItem

	/// The fields fetched from the server that the local store does not carry.
	private(set) var details: LibraryEntryDetails?

	/// The entry's current library status, kept live from the local store.
	private(set) var libraryStatus: LibraryStatus?

	private var entryObserver: LocalLibraryEntryObserver?

	// MARK: - Initializers
	/// Creates the view model, taking the server fields up front when the caller already holds them.
	///
	/// - Parameters:
	///    - item: The snapshot the detail screen was opened with.
	///    - details: The server fields, when the caller already fetched the item.
	init(item: LibraryItem, details: LibraryEntryDetails? = nil) {
		self.item = item
		self.details = details
		self.libraryStatus = item.libraryStatus
	}

	// MARK: - Functions
	/// Follows the entry in the local store and fetches the details the store does not carry.
	func start() async {
		guard let slug = User.current?.attributes.slug else { return }

		if self.entryObserver == nil {
			self.refreshLibraryStatus(forUserSlug: slug)
			self.entryObserver = LocalLibraryEntryObserver(
				matching: LocalLibraryEntryObserver.matches(userSlug: slug, kind: self.item.kind, trackableID: self.item.id),
				onChange: { [weak self] _ in
					self?.refreshLibraryStatus(forUserSlug: slug)
				},
				onRemove: { [weak self] _ in
					self?.refreshLibraryStatus(forUserSlug: slug)
				}
			)
		}

		guard self.details == nil else { return }

		do {
			self.details = try await self.fetchDetails()
		} catch {
			print("Library entry details fetch failed:", error.localizedDescription)
		}
	}

	/// Moves the entry to the given library status.
	///
	/// - Parameter status: The status to assign.
	func setStatus(_ status: LibraryStatus) async {
		guard let slug = User.current?.attributes.slug else { return }

		await LibraryOutbox.shared.enqueueSetStatus(status, trackableID: self.item.id, userSlug: slug, kind: self.item.kind, seed: self.details?.seed)
	}

	/// Removes the entry from the library.
	func removeFromLibrary() async {
		guard let slug = User.current?.attributes.slug else { return }

		await LibraryOutbox.shared.enqueueRemove(trackableID: self.item.id, userSlug: slug, kind: self.item.kind)
	}

	// MARK: - Private
	/// Reads the status back from the store by trackable identity.
	///
	/// - Parameter userSlug: The user's account slug.
	private func refreshLibraryStatus(forUserSlug userSlug: String) {
		self.libraryStatus = LibraryStore.shared.entry(forTrackableID: self.item.id, userSlug: userSlug, kind: self.item.kind)?.libraryStatus
	}

	private func fetchDetails() async throws -> LibraryEntryDetails? {
		let itemID = KurozoraItemID(self.item.id)

		switch self.item.kind {
		case .shows:
			let shows = try await KService.details([ShowIdentity(id: itemID)]).response().data
			return shows.first.map { LibraryEntryDetails(show: $0) }
		case .literatures:
			let literatures = try await KService.details([LiteratureIdentity(id: itemID)]).response().data
			return literatures.first.map { LibraryEntryDetails(literature: $0) }
		case .games:
			let games = try await KService.details([GameIdentity(id: itemID)]).response().data
			return games.first.map { LibraryEntryDetails(game: $0) }
		}
	}
}
