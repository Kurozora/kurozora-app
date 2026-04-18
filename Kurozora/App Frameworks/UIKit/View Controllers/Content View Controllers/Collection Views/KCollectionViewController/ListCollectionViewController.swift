//
//  ListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A base collection view controller for paginated, identity-backed lists.
class ListCollectionViewController: KCollectionViewController {
	// MARK: - Pagination
	/// The URL of the next page of results, or `nil` when the list is exhausted.
	var nextPageURL: String?

	/// A Boolean value that indicates whether a fetch request is in progress.
	var isRequestInProgress: Bool = false

	// MARK: - Refresh control
	/// The storage for ``prefersRefreshControlDisabled``.
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// MARK: - Activity indicator
	/// The storage for ``prefersActivityIndicatorHidden``.
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Subclass hooks
	/// The image displayed in the empty-data view.
	var emptyStateImage: UIImage { UIImage() }

	/// The title displayed in the empty-data view.
	var emptyStateTitle: String { "" }

	/// The detail text displayed in the empty-data view.
	var emptyStateDetail: String { "" }

	/// A Boolean value that indicates whether the list already has data loaded.
	var hasLoadedInitialData: Bool { false }

	/// Fetches the next page of items.
	func fetchItems() async {}

	// MARK: - View lifecycle
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		if self.hasLoadedInitialData {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchItems()
			}
		}
	}

	// MARK: - Refresh
	override func handleRefreshControl() {
		self.nextPageURL = nil

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchItems()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	// MARK: - Empty state
	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: self.emptyStateImage)
		self.emptyBackgroundView.configureLabels(title: self.emptyStateTitle, detail: self.emptyStateDetail)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades the empty-data view in or out based on the current item count.
	///
	/// Call this method after updating the data source to reflect the new state.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Ends the current fetch cycle.
	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()

		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
		#endif
	}

	// MARK: - Pagination
	/// Requests the next page when `indexPath` crosses the pagination threshold.
	///
	/// - Parameters:
	///   - indexPath: The index path about to be displayed.
	///   - totalItems: The number of items currently loaded.
	func paginateIfNeeded(at indexPath: IndexPath, totalItems: Int) {
		guard totalItems > 0, self.nextPageURL != nil else { return }

		let lastIndex = totalItems - 1
		var threshold = lastIndex / 8
		threshold = min(threshold, 15)
		threshold = lastIndex - threshold
		threshold = max(threshold, 1)

		if indexPath.item >= threshold {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchItems()
			}
		}
	}
}
