//
//  MuseumCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension MuseumCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .museumEntry(let museumEntry, _):
			switch self.libraryKind {
			case .shows:
				self.show(.showDetailsSegue, sender: museumEntry)
			case .literatures:
				self.show(.literatureDetailsSegue, sender: museumEntry)
			case .games:
				self.show(.gameDetailsSegue, sender: museumEntry)
			}
		case .pending:
			break
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .pending(let year, _):
			self.scheduleYearLoad(for: year)
		case .museumEntry:
			break
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .pending(let year, _):
			guard !self.hasVisiblePendingItems(for: year) else { return }
			self.cancelYearLoad(for: year)
		case .museumEntry:
			break
		}
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView == self.collectionView else { return }
		self.syncActiveYear()
		self.showScrollingScale()
	}

	/// Whether any of the year's skeleton items are still visible.
	///
	/// - Parameter year: The year to check.
	///
	/// - Returns: `true` when a skeleton item of the year is on screen.
	func hasVisiblePendingItems(for year: Int) -> Bool {
		for indexPath in self.collectionView.indexPathsForVisibleItems {
			guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { continue }

			switch itemKind {
			case .pending(let pendingYear, _) where pendingYear == year:
				return true
			default:
				continue
			}
		}

		return false
	}
}
