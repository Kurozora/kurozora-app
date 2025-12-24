//
//  KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// The KCollectionViewDelegateLayout protocol defines methods that guide you with managing the (compositional) layout of sections, groups and items in a collection view. The methods of this protocol are all optional.
@objc protocol KCollectionViewDelegateLayout: AnyObject {
	@objc optional func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int
	@objc optional func contentInset(forBackgroundInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets
	@objc optional func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets
	@objc optional func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets
	@objc optional func createLayout() -> UICollectionViewLayout?
}

// MARK: - KCollectionViewController
extension KCollectionViewController: KCollectionViewDelegateLayout {
	/// Tells your KCollectionViewDelegateLayout the number of columns that should be present in the specified section.
	///
	/// One example of calculating the number of required columns is by deviding the max width of the cell with the total width of the collection view.
	/// - Parameters:
	///    - section: An index number identifying a section in collectionView. This index value is 0-based.
	///    - width: The actual width of the collection view.
	///
	/// - Returns: The number of columns inside the section.
	func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		return 0
	}

	/// Tells your KCollectionViewDelegateLayout the margins to apply to the background decoration in the specified section.
	///
	/// If you do not implement this method, the layout uses the default value of `NSDirectionalEdgeInsets.zero` instead. Your implementation of this method can return a fixed set of margin sizes or return different margin sizes for each section.
	///
	/// Background decoration insets are margins applied only to the decoration in the section. They represent the distance between the top and the bottom of the decoration and the section it is in. They also indicate the spacing on either side of the items. They do not affect the size of the section and the items themselves.
	///
	/// - Parameters:
	///    - section: The index number of the section whose decoration spacing is needed.
	///    - layoutEnvironment: The layout environment of the specified item.
	///
	/// - Returns: The margins to apply to background decoration in the section.
	func contentInset(forBackgroundInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return .zero
	}

	/// Tells your KCollectionViewDelegateLayout the margins to apply to the items in the specified section.
	///
	/// If you do not implement this method, the layout uses the default value of `NSDirectionalEdgeInsets.zero` instead. Your implementation of this method can return a fixed set of margin sizes or return different margin sizes for each section.
	///
	/// Item insets are margins applied only to the items in the section. They represent the distance between the top and the bottom of the item and the section it is in. They also indicate the spacing on either side of the items (inter-item spacing). They do not affect the size of the section themselves.
	///
	/// - Parameter:
	///    - section: The index number of the section whose inter-item spacing is needed.
	///    - layoutEnvironment: The layout environment of the specified item.
	///
	/// - Returns: The margins to apply to items in the section.
	func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return .zero
	}

	/// Tells your KCollectionViewDelegateLayout the margins to apply to the specified section.
	///
	/// If you do not implement this method, the layout uses the default value of `NSDirectionalEdgeInsets.zero` instead. Your implementation of this method can return a fixed set of margin sizes or return different margin sizes for each section.
	///
	/// Section insets are margins applied only to the items in the section. They represent the distance between the header view and the first line of items and between the last line of items and the footer view. They also indicate the spacing on either side of a single line of items. They do not affect the size of the headers or footers themselves.
	///
	/// - Parameters:
	///    - section: The index number of the section whose insets are needed.
	///    - layoutEnvironment: The layout environment of the specified item.
	///
	/// - Returns: The margins to apply to items in the section.
	func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return .zero
	}

	/// Tells your KCollectionViewDelegateLayout to create a compositional layout for the collection view.
	///
	/// - Returns: The layout that should be used for the collection view.
	func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
			layoutGroup.interItemSpacing = .fixed(10.0)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			layoutSection.interGroupSpacing = 10.0
			return layoutSection
		}
	}
}
