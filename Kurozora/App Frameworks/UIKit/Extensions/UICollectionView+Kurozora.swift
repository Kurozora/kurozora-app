//
//  UICollectionView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension UICollectionView {
	/// Number of all items in all sections of collectionView.
	///
	/// - Returns: the count of all rows in the collectionView.
	var numberOfItems: Int {
		var section = 0
		var itemsCount = 0
		while section < self.numberOfSections {
			itemsCount += self.numberOfItems(inSection: section)
			section += 1
		}
		return itemsCount
	}

	/// Safely scrolls the collection view contents until the specified item is visible.
	///
	/// - Parameters:
	///    - indexPath: The index path of the item to scroll into view.
	///    - scrollPosition: An option that specifies where the item should be positioned when scrolling finishes. For a list of possible values, see [`UICollectionView.ScrollPosition`](https://developer.apple.com/documentation/uikit/uicollectionview/scrollposition).
	///    - animated: Specify [`true`](https://developer.apple.com/documentation/swift/true) to animate the scrolling behavior or [`false`](https://developer.apple.com/documentation/swift/false) to adjust the scroll view’s visible content immediately.
	func safeScrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
		guard indexPath.item >= 0,
		      indexPath.section >= 0,
		      indexPath.section < numberOfSections,
		      indexPath.item < self.numberOfItems(inSection: indexPath.section)
		else {
			return
		}
		self.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
	}

	/// Reload data with a completion handler.
	///
	/// - Parameter completion: completion handler to run after reloadData finishes.
	func reloadData(_ completion: @escaping () -> Void) {
		UIView.animate(withDuration: 0, animations: {
			self.reloadData()
		}, completion: { _ in
			completion()
		})
	}

	/// Dequeue reusable UICollectionReusableView using class name.
	///
	/// - Parameters:
	///   - kind: the kind of supplementary view to retrieve. This value is defined by the layout object.
	///   - name: UICollectionReusableView type.
	///   - indexPath: location of cell in collectionView.
	///
	/// - Returns: UICollectionReusableView object with associated class name.
	func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, withClass name: T.Type, for indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
			fatalError(
				"Couldn't find UICollectionReusableView for \(String(describing: name)), make sure the view is registered with collection view")
		}
		return cell
	}

	/// Dequeue reusable UICollectionViewCell using class name.
	///
	/// - Parameters:
	///   - name: UICollectionViewCell type.
	///   - indexPath: location of cell in collectionView.
	///
	/// - Returns: UICollectionViewCell object with associated class name.
	func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
			fatalError(
				"Couldn't find UICollectionViewCell for \(String(describing: name)), make sure the cell is registered with collection view")
		}
		return cell
	}
}
