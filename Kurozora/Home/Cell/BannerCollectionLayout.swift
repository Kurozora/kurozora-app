//
//  BannerCollectionLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

private let maxScaleOffset: CGFloat = 170
private let minScale: CGFloat = 0.9
private let minAlpha: CGFloat = 0.3

class BannerCollectionLayout: UICollectionViewFlowLayout {
	var scaled: Bool = true

	fileprivate var lastCollectionViewSize: CGSize = CGSize.zero

	override func prepare() {
		scrollDirection = .horizontal
	}
	
	override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
		super.invalidateLayout(with: context)

		guard let collectionView = collectionView else { return }

		if collectionView.bounds.size != lastCollectionViewSize {
			configureInset()
			lastCollectionViewSize = collectionView.bounds.size
		}
	}

	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard let attribute = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
			return nil
		}
		if !scaled {
			return attribute
		}
		centerScaledAttribute(attribute: attribute)
		return attribute
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attributes = super.layoutAttributesForElements(in: rect) else {
			return nil
		}
		if !scaled {
			return attributes
		}
		guard case let newAttributesArray as [UICollectionViewLayoutAttributes] = NSArray(array: attributes, copyItems: true) else {
			return nil
		}
		newAttributesArray.forEach { attribute in
			centerScaledAttribute(attribute: attribute)
		}
		return newAttributesArray
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
											 withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView else {
			return proposedContentOffset
		}

		let proposedRect = CGRect(x: proposedContentOffset.x,
								  y: 0,
								  width: collectionView.bounds.width,
								  height: maxScaleOffset)
		guard let layoutAttributes = layoutAttributesForElements(in: proposedRect) else {
			return proposedContentOffset
		}

		var shouldBeChosenAttributes: UICollectionViewLayoutAttributes?
		var shouldBeChosenIndex: Int = -1

		let proposedCenterX = proposedRect.midX

		for (i, attributes) in layoutAttributes.enumerated() {
			guard attributes .representedElementCategory == .cell else {
				continue
			}
			guard let currentChosenAttributes = shouldBeChosenAttributes else {
				shouldBeChosenAttributes = attributes
				shouldBeChosenIndex = i
				continue
			}
			if (abs(attributes.frame.midX - proposedCenterX) < abs(currentChosenAttributes.frame.midX - proposedCenterX)) {
				shouldBeChosenAttributes = attributes
				shouldBeChosenIndex = i
			}
		}
		// Adjust the case where a quick but small scroll occurs.
		if (abs(collectionView.contentOffset.x - proposedContentOffset.x) < itemSize.width) {
			if velocity.x < -0.3 {
				shouldBeChosenIndex = shouldBeChosenIndex > 0 ? shouldBeChosenIndex - 1 : shouldBeChosenIndex
			} else if velocity.x > 0.3 {
				shouldBeChosenIndex = shouldBeChosenIndex < layoutAttributes.count - 1 ?
					shouldBeChosenIndex + 1 : shouldBeChosenIndex
			}
			shouldBeChosenAttributes = layoutAttributes[shouldBeChosenIndex]
		}
		guard let finalAttributes = shouldBeChosenAttributes else {
			return proposedContentOffset
		}
		return CGPoint(x: finalAttributes.frame.midX - collectionView.bounds.size.width / 2,
					   y: proposedContentOffset.y)
	}
}

// MARK: helpers
extension BannerCollectionLayout {
	fileprivate func centerScaledAttribute(attribute: UICollectionViewLayoutAttributes) {
		guard let collectionView = collectionView else {
			return
		}
		let visibleRect = CGRect(x: collectionView.contentOffset.x,
								 y: collectionView.contentOffset.y,
								 width: collectionView.bounds.size.width,
								 height: maxScaleOffset)
		let visibleCenterX = visibleRect.midX
		let distanceFromCenter = visibleCenterX - attribute.center.x
		let distance = min(abs(distanceFromCenter), maxScaleOffset)
		let scale = distance * (minScale - 1) / maxScaleOffset + 1
		attribute.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
		attribute.alpha = distance * (minAlpha - 1) / maxScaleOffset + 1
	}

	fileprivate func configureInset() -> Void {
		guard let collectionView = collectionView else {
			return
		}
		collectionView.contentInset  = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
		collectionView.contentOffset = CGPoint(x: -8, y: 0)
	}
}
