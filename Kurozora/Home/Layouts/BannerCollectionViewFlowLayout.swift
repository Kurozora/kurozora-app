//
//  BannerCollectionViewFlowLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class BannerCollectionViewFlowLayout: UICollectionViewFlowLayout {
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
			let gaps = CGFloat(10 * collectionView.numberOfItems(inSection: 0))

			if UIDevice.isLandscape() {
				return CGSize(width: (collectionView.frame.width - gaps) / 2, height: collectionView.frame.height)
			}
			return CGSize(width: (collectionView.frame.width - gaps), height: collectionView.frame.height)
		}
		set { itemSize = newValue }
	}
	private let spacing: CGFloat = 5
	private let spacingWhenFocused: CGFloat = 15

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
		collectionView.decelerationRate = .fast
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

	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
		let collectionViewMidX: CGFloat = collectionView.bounds.size.width / 2
		guard let closestAttribute = findClosestAttributes(toXPosition: proposedContentOffset.x + collectionViewMidX) else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
		return CGPoint(x: closestAttribute.center.x - collectionViewMidX, y: proposedContentOffset.y)
	}

	// MARK: - Invalidate layout
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		if newBounds.size != collectionView?.bounds.size { cachedItemsAttributes.removeAll() }
		return true
	}

	override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
		if context.invalidateDataSourceCounts { cachedItemsAttributes.removeAll() }
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
	private func findClosestAttributes(toXPosition xPosition: CGFloat) -> UICollectionViewLayoutAttributes? {
		guard let collectionView = collectionView else { return nil }
		let searchRect = CGRect(
			x: xPosition - collectionView.bounds.width, y: collectionView.bounds.minY,
			width: collectionView.bounds.width * 2, height: collectionView.bounds.height
		)
		return layoutAttributesForElements(in: searchRect)?.min(by: { abs($0.center.x - xPosition) < abs($1.center.x - xPosition) })
	}

	private func updateInsets() {
		guard let collectionView = collectionView else { return }
		collectionView.contentInset.left = (collectionView.bounds.size.width - itemSize.width) / 2
		collectionView.contentInset.right = (collectionView.bounds.size.width - itemSize.width) / 2
	}

//	// MARK: - Properties
//
//	public var isPagingEnabled = true
//	public var leftContentOffset: CGFloat = 0
//	private var firstSetupDone = false
//	private var cellWidth: CGFloat = 0
//	private var contentSpacing: CGFloat = 0
//
//	// MARK: - Override
//
//	override public func prepare() {
//		super.prepare()
//
//		guard !firstSetupDone else {
//			return
//		}
//
//		scrollDirection = .horizontal
//		firstSetupDone = true
//	}
//
//	override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//		return true
//	}
//
//	public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//		// If the property `isPagingEnabled` is set to false, we don't enable paging and thus return the current contentoffset.
//		guard isPagingEnabled else {
//			let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
//			return latestOffset
//		}
//
//		// Page width used for estimating and calculating paging
//		let pageWidth = cellWidth + self.minimumInteritemSpacing
//
//		// Make an estimation of the current page position.
//		let approximatePage = self.collectionView!.contentOffset.x / pageWidth
//
//		// Determine the current page based on velocity.
//		let currentPage = (velocity.x < 0.0) ? floor(approximatePage) : ceil(approximatePage)
//
//		// Create custom flickVelocity.
//		let flickVelocity = velocity.x * 0.4
//
//		// Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
//		let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)
//
//		// Calculate newHorizontalOffset
//		let newHorizontalOffset = ((currentPage + flickedPages) * pageWidth) - self.collectionView!.contentInset.left
//
//		return CGPoint(x: newHorizontalOffset - (2 * leftContentOffset), y: proposedContentOffset.x)
//	}
//
//	override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//		let items = NSMutableArray (array: super.layoutAttributesForElements(in: rect)!, copyItems: true)
//
//		guard let firstCellAttribute = items.firstObject as? UICollectionViewLayoutAttributes else {
//			return nil
//		}
//
//		self.cellWidth = firstCellAttribute.size.width
//
//		guard let collectionViewBounds  = collectionView?.bounds else {
//			return nil
//		}
//
//		contentSpacing = (collectionViewBounds.width - cellWidth) / 2 - leftContentOffset
//		collectionView?.contentInset = UIEdgeInsets(top: collectionView?.contentInset.top ?? 0, left: contentSpacing - leftContentOffset, bottom: collectionView?.contentInset.bottom ?? 0 , right: 15)
//
//		items.enumerateObjects { (object, index, stop) in
//			let attribute = object as! UICollectionViewLayoutAttributes
//			self.cellWidth = attribute.size.width
//			self.updateCellAttributes(attribute: attribute)
//		}
//
//		return items as? [UICollectionViewLayoutAttributes]
//	}
//
//	// MARK: - Private functions
//
//	private func updateCellAttributes(attribute: UICollectionViewLayoutAttributes) {
//		var finalX: CGFloat = attribute.frame.midX - (collectionView?.contentOffset.x)!
//		let centerX = attribute.frame.midX - (collectionView?.contentOffset.x)!
//		if centerX < collectionView!.frame.midX - contentSpacing {
//			finalX = max(centerX, collectionView!.frame.minX)
//		}
//		else if centerX > collectionView!.frame.midX + contentSpacing {
//			finalX = min(centerX, collectionView!.frame.maxX)
//		}
//
//		let deltaY = abs(finalX - collectionView!.frame.midX) / attribute.frame.width
//		let scale = 1 - deltaY * 0.2
//		let alpha = 1 - deltaY
//
//		attribute.alpha = alpha
//		attribute.transform = CGAffineTransform(scaleX: 1, y: scale)
//	}
}
