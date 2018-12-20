//
//  HeaderCategoryCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let bannersCount = banners?.count, bannersCount != 0 {
			return bannersCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
		guard let bannersCount = banners?.count else { return headerCell }
		let indexPathRow = indexPath.row % bannersCount
        
        if let backgroundThumbnail = banners?[indexPathRow]["background_thumbnail"].stringValue, backgroundThumbnail != "" {
            let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
            let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
            headerCell.backgroundImageView.kf.indicatorType = .activity
            headerCell.backgroundImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_banner"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        } else {
            headerCell.backgroundImageView.image = UIImage(named: "placeholder_banner")
        }
        
        if let title = banners?[indexPathRow]["title"].stringValue {
            headerCell.titleLabel.text = title
        }
        
        if let genre = banners?[indexPathRow]["genre"].stringValue {
            headerCell.genreLabel.text = genre
        }
        
        return headerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bannerId = banners?[indexPath.item]["id"].intValue {
            self.performSegue(withIdentifier: "ShowDetailsSegue", sender: bannerId)
        }
    }

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if !onceOnly {
			if let bannersCount = banners?.count, bannersCount != 0 {
				self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
				onceOnly = true
			}
		}
	}

	// MARK: - Flowlayout
	func collectionView(_ collectionView: UICollectionView,	layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return itemSize
	}
}

// Scaled Card
import UIKit

private let maxScaleOffset: CGFloat = 180
private let minScale: CGFloat = 0.9
private let minAlpha: CGFloat = 0.3

/// The layout that can place a card at the central of the screen.
class BannerCollectionLayout: UICollectionViewFlowLayout {
	public var scaled: Bool = false

	fileprivate var lastCollectionViewSize: CGSize = CGSize.zero

	public init(scaled: Bool) {
		self.scaled = scaled
		super.init()
		scrollDirection = .horizontal
		minimumLineSpacing = 8
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
		super.invalidateLayout(with: context)

		guard let collectionView = collectionView else { return }

		if collectionView.bounds.size != lastCollectionViewSize {
			configureInset()
			lastCollectionViewSize = collectionView.bounds.size
		}
	}

	public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard let attribute = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
			return nil
		}
		if !scaled {
			return attribute
		}
		centerScaledAttribute(attribute: attribute)
		return attribute
	}

	public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
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

	public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
											 withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView else {
			return proposedContentOffset
		}

		let proposedRect = CGRect(x: proposedContentOffset.x,
								  y: 0,
								  width: collectionView.bounds.width,
								  height: collectionView.bounds.height)
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
								 height: collectionView.bounds.size.height)
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
		let inset = collectionView.bounds.size.width / 2 - itemSize.width / 2
		collectionView.contentInset  = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
		collectionView.contentOffset = CGPoint(x: -inset, y: 0)
	}
}

