//
//  LibraryListCollectionViewController+SyncStatus.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - Sync status
extension LibraryListCollectionViewController {
	/// The offset at which the sync status is fully shown.
	var shownSyncStatusOffsetY: CGFloat {
		return -self.collectionView.adjustedContentInset.top
	}

	/// The offset at which the sync status is hidden.
	var hiddenSyncStatusOffsetY: CGFloat {
		return self.shownSyncStatusOffsetY + self.syncStatusHeight
	}

	/// The height the sync status occupies.
	private var syncStatusHeight: CGFloat {
		let width = self.collectionView.bounds.width - self.collectionView.safeAreaInsets.left - self.collectionView.safeAreaInsets.right
		guard width > 0 else { return 0 }

		return self.syncStatusView.height(fittingWidth: width)
	}

	/// Adds the sync status above the list.
	func configureSyncStatusView() {
		self.collectionView.addSubview(self.syncStatusView)

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleSyncStatusDidChange), name: .KLibrarySyncProgressDidChange, object: nil)
		self.refreshSyncStatus()
	}

	/// Lays the sync status out above the list.
	func layoutSyncStatusView() {
		let height = self.syncStatusHeight
		self.syncStatusView.isHidden = self.totalLibraryItemsCount == 0 || height == 0

		let topInset = Self.baseTopInset + (self.syncStatusView.isHidden ? 0 : height)
		if abs(self.collectionView.contentInset.top - topInset) > 0.5 {
			self.collectionView.contentInset.top = topInset
			self.collectionView.verticalScrollIndicatorInsets.top = topInset
			self.didParkSyncStatus = false
		}

		guard !self.syncStatusView.isHidden else { return }

		self.syncStatusView.frame = CGRect(
			x: self.collectionView.safeAreaInsets.left,
			y: -height,
			width: self.collectionView.bounds.width - self.collectionView.safeAreaInsets.left - self.collectionView.safeAreaInsets.right,
			height: height
		)

		guard !self.didParkSyncStatus, self.canScrollSyncStatusOutOfView else { return }
		self.didParkSyncStatus = true
		self.collectionView.contentOffset.y = self.hiddenSyncStatusOffsetY
	}

	/// Whether the list is long enough to scroll the sync status out of view.
	private var canScrollSyncStatusOutOfView: Bool {
		let visibleHeight = self.collectionView.bounds.height - self.collectionView.adjustedContentInset.top - self.collectionView.adjustedContentInset.bottom
		return self.collectionView.contentSize.height > visibleHeight + self.syncStatusHeight
	}

	/// Refreshes the sync status.
	func refreshSyncStatus() {
		guard let userSlug = User.current?.attributes.slug else {
			self.syncStatusView.configure(stats: "", status: LibrarySyncProgress.lastSyncSentence(for: nil))
			return
		}

		let status = LibrarySyncProgress.shared.isSyncing
			? L10n.syncingNow
			: LibrarySyncProgress.lastSyncSentence(for: LocalSyncCursor.lastSyncedAt(forUserSlug: userSlug, in: PersistenceController.shared.viewContext))
		let counts = LibraryStore.shared.mediaTypeCounts(forUserSlug: userSlug, kind: self.libraryKind, status: self.libraryStatus)
		let orderedNames = self.orderedMediaTypeNames
		let stats = counts
			.sorted { lhs, rhs in
				let lhsIndex = orderedNames.firstIndex(of: lhs.key) ?? orderedNames.count
				let rhsIndex = orderedNames.firstIndex(of: rhs.key) ?? orderedNames.count
				return lhsIndex == rhsIndex ? lhs.key < rhs.key : lhsIndex < rhsIndex
			}
			.map { "\($0.value) \($0.key)" }
			.joined(separator: ", ")

		self.syncStatusView.configure(stats: stats, status: status)
		self.view.setNeedsLayout()
	}

	/// The media type names in the order their kind declares them.
	private var orderedMediaTypeNames: [String] {
		switch self.libraryKind {
		case .shows:
			return ShowType.allCases.map(\.name)
		case .literatures:
			return LiteratureType.allCases.map(\.name)
		case .games:
			return GameType.allCases.map(\.name)
		}
	}

	@objc private func handleSyncStatusDidChange() {
		Task { @MainActor [weak self] in
			self?.refreshSyncStatus()
		}
	}
}

// MARK: - UIScrollViewDelegate
extension LibraryListCollectionViewController {
	override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		guard !self.syncStatusView.isHidden else { return }

		let hiddenOffsetY = self.hiddenSyncStatusOffsetY
		let shownOffsetY = self.shownSyncStatusOffsetY
		let targetOffsetY = targetContentOffset.pointee.y

		guard targetOffsetY > shownOffsetY, targetOffsetY < hiddenOffsetY else { return }

		let midpointOffsetY = (shownOffsetY + hiddenOffsetY) / 2
		let showsStatus = velocity.y < 0 || (velocity.y == 0 && targetOffsetY < midpointOffsetY)
		targetContentOffset.pointee.y = showsStatus ? shownOffsetY : hiddenOffsetY
	}
}
