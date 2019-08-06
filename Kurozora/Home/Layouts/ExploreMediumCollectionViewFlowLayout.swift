//
//  ExploreMediumCollectionViewFlowLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ExploreMediumCollectionViewFlowLayout: KBaseCollectionViewFlowLayout {
	override var spacingWhenFocused: CGFloat {
		return spacing
	}

	// MARK: - Public Properties
	override var collectionViewContentSize: CGSize {
		let leftmostEdge = cachedItemsAttributes.values.map { $0.frame.minX }.min() ?? 0
		let rightmostEdge = cachedItemsAttributes.values.map { $0.frame.maxX }.max() ?? 0
		return CGSize(width: rightmostEdge - leftmostEdge, height: itemSize.height)
	}

	// MARK: - Private Properties
	private var cachedItemsAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
	override var itemSize: CGSize {
		get { return _itemSize }
		set { _itemSize = newValue }
	}
	private var _itemSize: CGSize {
		get {
			guard let collectionView = self.collectionView else { return .zero }
			let gaps = CGFloat(interItemGap * collectionView.numberOfItems(inSection: 0))

			if UIDevice.isPad() {
				if UIDevice.isLandscape() {
					return CGSize(width: (collectionView.frame.width - gaps) / 4, height: collectionView.frame.height)
				}
				return CGSize(width: (collectionView.frame.width - gaps) / 3, height: collectionView.frame.height)
			}

			if UIDevice.isLandscape() {
				return CGSize(width: (collectionView.frame.width - gaps) / 2.5, height: collectionView.frame.height)
			}
			return CGSize(width: (collectionView.frame.width - gaps), height: collectionView.frame.height)
		}
		set { itemSize = newValue }
	}

	private var continuousFocusedIndex: CGFloat {
		guard let collectionView = collectionView else { return 0 }
		let offset = collectionView.bounds.width / 2 + collectionView.contentOffset.x - itemSize.width / 2
		return offset / (itemSize.width + spacing)
	}

	// MARK: - Public Methods
	override open func prepare() {
		super.prepare()
		guard let collectionView = self.collectionView else { return }
		updateInsets()
		guard cachedItemsAttributes.isEmpty else { return }
		scrollDirection = .horizontal
		let itemsCount = collectionView.numberOfItems(inSection: 0)
		for item in 0..<itemsCount {
			let indexPath = IndexPath(item: item, section: 0)
			cachedItemsAttributes[indexPath] = createAttributesForItem(at: indexPath)
		}
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return cachedItemsAttributes
			.map { $0.value }
			.filter { $0.frame.intersects(rect) }
			.map { self.shiftedAttributes(from: $0) }
	}

	// MARK: - Invalidate layout
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		if newBounds.size != collectionView?.bounds.size {
			cachedItemsAttributes.removeAll()
		}
		return true
	}

	override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
		if context.invalidateDataSourceCounts {
			cachedItemsAttributes.removeAll()
		}
		super.invalidateLayout(with: context)
	}

	// MARK: - Items
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard let attributes = cachedItemsAttributes[indexPath] else { fatalError("No attributes cached") }
		return shiftedAttributes(from: attributes)
	}

	private func createAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
		guard let collectionView = collectionView else { return nil }
		attributes.frame.size = itemSize
		attributes.frame.origin.y = (collectionView.bounds.height - itemSize.height) / 2
		attributes.frame.origin.x = CGFloat(indexPath.item) * (itemSize.width + spacing)
		return attributes
	}

	private func shiftedAttributes(from attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		guard let attributes = attributes.copy() as? UICollectionViewLayoutAttributes else { fatalError("Couldn't copy attributes") }
		let roundedFocusedIndex = round(continuousFocusedIndex)
		guard attributes.indexPath.item != Int(roundedFocusedIndex) else { return attributes }
		let shiftArea = (roundedFocusedIndex - 0.5)...(roundedFocusedIndex + 0.5)
		let distanceToClosestIdentityPoint = min(abs(continuousFocusedIndex - shiftArea.lowerBound), abs(continuousFocusedIndex - shiftArea.upperBound))
		let normalizedShiftFactor = distanceToClosestIdentityPoint * 2
		let translation = (spacingWhenFocused - spacing) * normalizedShiftFactor
		let translationDirection: CGFloat = attributes.indexPath.item < Int(roundedFocusedIndex) ? -1 : 1
		attributes.transform = CGAffineTransform(translationX: translationDirection * translation, y: 0)
		return attributes
	}

	// MARK: - Private Methods
	private func updateInsets() {
		guard let collectionView = collectionView else { return }
		collectionView.contentInset.left = 20
		collectionView.contentInset.right = 20
	}
}
