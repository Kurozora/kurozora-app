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

/// Mirrors the local library store for the watch's library screens.
@MainActor @Observable
final class LibraryViewModel {
	// MARK: - Properties
	/// The library kind the screens show, remembered across launches like the iOS library tab.
	private(set) var selectedKind: LibraryKind

	/// The signed in user's entries of the selected kind, keyed by library status.
	private(set) var itemsByStatus: [LibraryStatus: [LibraryItem]] = [:]

	/// Whether a sync round is pulling rows into the store.
	private(set) var isSyncing = false

	private static let selectedKindKey = "libraryKind"

	private var userSlug: String?
	private var entryObserver: LocalLibraryEntryObserver?
	private var isReloadScheduled = false

	// MARK: - Initializers
	init() {
		self.selectedKind = LibraryKind(rawValue: UserDefaults.standard.integer(forKey: Self.selectedKindKey)) ?? .shows
	}

	// MARK: - Functions
	/// Loads the store for the signed in user and follows every later change to it.
	func start() {
		guard let slug = User.current?.attributes.slug, slug != self.userSlug else { return }

		self.userSlug = slug
		self.entryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] _ in
				self?.scheduleReload()
			},
			onRemove: { [weak self] _ in
				self?.scheduleReload()
			}
		)

		self.refreshSyncState()
		self.reload()
	}

	/// Switches the screens to the given kind and remembers the choice.
	///
	/// - Parameter kind: The library kind to show.
	func selectKind(_ kind: LibraryKind) {
		guard kind != self.selectedKind else { return }

		self.selectedKind = kind
		UserDefaults.standard.set(kind.rawValue, forKey: Self.selectedKindKey)
		self.reload()
	}

	/// Reads whether a sync round is in flight, for the screens that show a spinner over an empty list.
	func refreshSyncState() {
		self.isSyncing = LibrarySyncProgress.shared.isSyncing
	}

	/// Returns the selected kind's entries carrying the given status.
	///
	/// - Parameter status: The library status to list.
	///
	/// - Returns: The matching snapshots, most recently updated first.
	func items(for status: LibraryStatus) -> [LibraryItem] {
		return self.itemsByStatus[status] ?? []
	}

	/// Flips the entry's favorite flag through the outbox.
	///
	/// - Parameter item: The entry to update.
	func toggleFavorite(_ item: LibraryItem) async {
		guard let slug = self.userSlug else { return }

		await LibraryOutbox.shared.enqueueSetFavorite(!item.isFavorited, trackableID: item.id, userSlug: slug, kind: item.kind)
	}

	/// Flips the entry's reminder flag through the outbox.
	///
	/// - Parameter item: The entry to update.
	func toggleReminder(_ item: LibraryItem) async {
		guard let slug = self.userSlug else { return }

		await LibraryOutbox.shared.enqueueSetReminder(!item.isReminded, trackableID: item.id, userSlug: slug, kind: item.kind)
	}

	// MARK: - Private
	/// Folds the burst of per-row callbacks a single save produces into one reload.
	private func scheduleReload() {
		guard !self.isReloadScheduled else { return }
		self.isReloadScheduled = true

		Task { @MainActor [weak self] in
			self?.isReloadScheduled = false
			self?.reload()
		}
	}

	private func reload() {
		guard let slug = self.userSlug else { return }

		var itemsByStatus: [LibraryStatus: [LibraryItem]] = [:]
		for status in LibraryStatus.all {
			let entries = LibraryStore.shared.entries(forUserSlug: slug, kind: self.selectedKind, status: status, sortType: .none, sortOption: .none, offset: 0, limit: 0)
			itemsByStatus[status] = entries.map { LibraryItem(entry: $0) }
		}

		self.itemsByStatus = itemsByStatus
	}
}
