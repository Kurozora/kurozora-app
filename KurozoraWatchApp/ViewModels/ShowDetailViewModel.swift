//
//  ShowDetailViewModel.swift
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
final class ShowDetailViewModel {
	// MARK: - Properties
	/// The snapshot the detail screen was opened with.
	let item: LibraryItem

	/// The full show, fetched for the fields the local store does not carry.
	private(set) var show: Show?

	/// The entry's current library status, kept live from the local store.
	private(set) var libraryStatus: LibraryStatus?

	private var entryObserver: LocalLibraryEntryObserver?

	// MARK: - Initializers
	init(item: LibraryItem) {
		self.item = item
		self.libraryStatus = item.libraryStatus
	}

	// MARK: - Functions
	/// Follows the entry in the local store and fetches the details the store does not carry.
	func start() async {
		guard let slug = User.current?.attributes.slug else { return }

		if self.entryObserver == nil {
			self.libraryStatus = LibraryStore.shared.entry(forTrackableID: self.item.id, userSlug: slug, kind: .shows)?.libraryStatus
			self.entryObserver = LocalLibraryEntryObserver(
				matching: LocalLibraryEntryObserver.matches(userSlug: slug, kind: .shows, trackableID: self.item.id),
				onChange: { [weak self] entry in
					self?.libraryStatus = entry.libraryStatus
				},
				onRemove: { [weak self] _ in
					self?.libraryStatus = nil
				}
			)
		}

		guard self.show == nil else { return }

		do {
			let identity = ShowIdentity(id: KurozoraItemID(self.item.id))
			self.show = try await KService.details([identity]).response().data.first
		} catch {
			print("Show details fetch failed:", error.localizedDescription)
		}
	}

	/// Moves the show to the given library status.
	///
	/// - Parameter status: The status to assign.
	func setStatus(_ status: LibraryStatus) async {
		guard let slug = User.current?.attributes.slug else { return }

		let seed = self.show.map { LibraryOutboxSeed(show: $0) }
		await LibraryOutbox.shared.enqueueSetStatus(status, trackableID: self.item.id, userSlug: slug, kind: .shows, seed: seed)
	}

	/// Removes the show from the library.
	func removeFromLibrary() async {
		guard let slug = User.current?.attributes.slug else { return }

		await LibraryOutbox.shared.enqueueRemove(trackableID: self.item.id, userSlug: slug, kind: .shows)
	}
}
