//
//  KotodamaArchiveCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaArchiveCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The puzzles available to replay.
	var entries: [KotodamaArchiveEntry] = []

	/// The cursor of the next page of entries.
	var nextCursor: PageCursor?

	/// Whether a page is in flight.
	var isFetchingNextPage = false

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, KotodamaArchiveEntry>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, KotodamaArchiveEntry>!

	private var _prefersActivityIndicatorHidden = false {
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

		self.title = L10n.kotodamaArchive
		self.configureDataSource()

		Task { [weak self] in
			await self?.fetchEntries(resetting: true)
		}
	}

	// MARK: - Functions
	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.seasons)
		self.emptyBackgroundView.configureLabels(
			title: L10n.kotodamaNoArchive,
			detail: L10n.kotodamaNoArchiveDescription
		)

		self.collectionView.backgroundView?.alpha = 0
	}

	override func handleRefreshControl() {
		Task { [weak self] in
			await self?.fetchEntries(resetting: true)
		}
	}

	/// Fades the empty data view in or out according to the number of items.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches a page of archive entries.
	///
	/// - Parameter resetting: Whether the fetch replaces the entries already loaded.
	func fetchEntries(resetting: Bool) async {
		guard !self.isFetchingNextPage else { return }

		self.isFetchingNextPage = true

		do {
			let request = resetting
				? KService.kotodamaArchive(limit: 25)
				: KService.kotodamaArchive(limit: 100).cursor(self.nextCursor)
			let response = try await request.response()

			if resetting {
				self.entries = response.data
			} else {
				self.entries.append(contentsOf: response.data)
			}

			self.nextCursor = response.nextCursor
		} catch {
			if resetting {
				self.entries = []
			}
		}

		self.isFetchingNextPage = false
		self._prefersActivityIndicatorHidden = true
		self.configureEmptyDataView()
		self.updateDataSource()

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
	}

	/// Opens the puzzle of an archive entry.
	///
	/// - Parameter entry: The entry to replay.
	func openPuzzle(for entry: KotodamaArchiveEntry) {
		guard let date = Self.dateFormatter.date(from: entry.attributes.puzzleDate ?? "") else { return }

		self.show(KotodamaGameViewController(puzzle: .archive(date)), sender: nil)
	}
}

// MARK: - Formatters
extension KotodamaArchiveCollectionViewController {
	/// The formatter used to read the date of an archive entry.
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}

// MARK: - SectionLayoutKind
extension KotodamaArchiveCollectionViewController {
	/// The set of available sections.
	enum SectionLayoutKind: Int, CaseIterable {
		/// The archive entries.
		case main = 0
	}
}

// MARK: - Cell Configuration
extension KotodamaArchiveCollectionViewController {
	/// Returns the cell registration for an archive tile.
	func getConfiguredArchiveCell() -> UICollectionView.CellRegistration<KotodamaArchiveCollectionViewCell, KotodamaArchiveEntry> {
		return UICollectionView.CellRegistration<KotodamaArchiveCollectionViewCell, KotodamaArchiveEntry> { cell, _, entry in
			let date = Self.dateFormatter.date(from: entry.attributes.puzzleDate ?? "")
			cell.configure(using: entry, date: date)
		}
	}
}
