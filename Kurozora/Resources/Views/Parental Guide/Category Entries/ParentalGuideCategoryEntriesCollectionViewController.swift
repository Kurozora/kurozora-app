//
//  ParentalGuideCategoryEntriesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A list of every parental guide entry in a single category.
class ParentalGuideCategoryEntriesCollectionViewController: KCollectionViewController {
	// MARK: - SectionLayoutKind
	/// The section layout kind for the entries list.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	// MARK: - ItemKind
	/// The set of available item kinds.
	enum ItemKind: Hashable {
		/// A user-submitted entry card.
		case entry(ParentalGuideEntry)

		func hash(into hasher: inout Hasher) {
			switch self {
			case .entry(let entry):
				hasher.combine(entry.id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.entry(let lhs), .entry(let rhs)):
				return lhs.id == rhs.id
			}
		}
	}

	// MARK: - Properties
	/// The media context whose entries are being displayed.
	var mediaType: ParentalGuide.MediaType?

	/// The category whose entries are being displayed.
	var category: ParentalGuideCategory?

	/// The full set of entries for the chosen category.
	var entries: [ParentalGuideEntry] = []

	/// The ids of entries whose reason text is currently expanded.
	var expandedEntryIDs: Set<KurozoraItemID> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.category?.displayName

		self.configureDataSource()
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchEntries()
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.parentalGuideEntries.lowercased(with: Locale.current)))
		#endif
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.entryDidUpdate(_:)), name: .KPGEntryDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.entryDidDelete(_:)), name: .KPGEntryDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KPGEntryDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KPGEntryDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchEntries()
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.reminders)
		self.emptyBackgroundView.configureLabels(
			title: L10n.noParentalGuideEntries,
			detail: L10n.noParentalGuideEntriesDetail
		)
		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fetches the entries for the bound category.
	func fetchEntries() async {
		guard let mediaType = self.mediaType, let category = self.category else { return }

		do {
			let response: ParentalGuideResponse

			switch mediaType {
			case .show(let identity, _, _, _, _):
				response = try await KService.parentalGuide(for: identity).response()
			case .literature(let identity, _, _, _, _):
				response = try await KService.parentalGuide(for: identity).response()
			case .game(let identity, _, _, _, _):
				response = try await KService.parentalGuide(for: identity).response()
			}

			self.entries = response.data.entries.filter { $0.attributes.category == category }
		} catch {
			print("ParentalGuide entries fetch failed:", String(reflecting: error))
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.updateDataSource()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	/// Reloads the cell at `indexPath` without rebuilding the rest of the snapshot.
	///
	/// - Parameter indexPath: The index path whose item should be re-rendered.
	func reloadEntry(at indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Replaces the entry at the given index path with the updated entry.
	///
	/// - Parameter notification: The notification carrying the updated entry.
	@objc func entryDidUpdate(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self, let category = self.category else { return }

			guard let updatedEntry = notification.userInfo?["entry"] as? ParentalGuideEntry else {
				Task { [weak self] in
					await self?.fetchEntries()
				}
				return
			}

			guard updatedEntry.attributes.category == category else { return }

			let isExisting = self.entries.contains { $0.id == updatedEntry.id }

			if let index = self.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
				self.entries[index] = updatedEntry
			} else {
				self.entries.insert(updatedEntry, at: 0)
			}

			if isExisting {
				self.reconfigureEntry(updatedEntry)
			} else {
				self.updateDataSource()
			}
		}
	}

	/// Forces the diffable data source to reconfigure the cell rendering `entry` so attribute-only changes (like vote counts) propagate without a full snapshot reload.
	///
	/// - Parameter entry: The entry whose cell should be re-rendered.
	private func reconfigureEntry(_ entry: ParentalGuideEntry) {
		var snapshot = self.dataSource.snapshot()
		let item = ItemKind.entry(entry)

		guard snapshot.itemIdentifiers.contains(item) else { return }

		snapshot.reconfigureItems([item])
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Removes the entry referenced in the notification.
	///
	/// - Parameter notification: The notification carrying the deleted entry id.
	@objc func entryDidDelete(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			guard let deletedID = notification.userInfo?["entryID"] as? KurozoraItemID else {
				Task { [weak self] in
					await self?.fetchEntries()
				}
				return
			}

			self.entries.removeAll { $0.id == deletedID }
			self.updateDataSource()
		}
	}
}
