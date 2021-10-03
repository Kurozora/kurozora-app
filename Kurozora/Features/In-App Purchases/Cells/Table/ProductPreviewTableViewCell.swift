//
//  ProductPreviewTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

/**
	- Tag: ProductPreviewTableViewCell
*/
class ProductPreviewTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var pageControl: UIPageControl! {
		didSet {
			pageControl.theme_currentPageIndicatorTintColor = KThemePicker.tintColor.rawValue
			pageControl.theme_pageIndicatorTintColor = ThemeColorPicker {
				return KThemePicker.tintColor.colorValue.withAlphaComponent(0.5)
			}
		}
	}

	// MARK: - Properties
	var previewImages: [UIImage?] = []

	// MARK: - IBActions
	@IBAction func pageControllerTapped(_ sender: UIPageControl) {
		self.collectionView.safeScrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
	}
}

// MARK: - UICollectionViewDataSource
extension ProductPreviewTableViewCell: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let numberOfItems = previewImages.count <= 1 ? 0 : previewImages.count
		pageControl.numberOfPages = numberOfItems
		pageControl.currentPage = 0
		return numberOfItems
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let purchasePreviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchasePreviewCollectionViewCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchasePreviewCollectionViewCell.identifier)")
		}
		if indexPath.section == 0 {
			purchasePreviewCollectionViewCell.previewImage = previewImages[indexPath.item]
		}
		return purchasePreviewCollectionViewCell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductPreviewTableViewCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if UIDevice.isPad {
			if UIDevice.isLandscape {
				return CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.height)
			}
			return CGSize(width: collectionView.bounds.width / 2, height: collectionView.bounds.height)
		}

		if UIDevice.isLandscape {
			return CGSize(width: collectionView.bounds.width / 2, height: collectionView.bounds.height)
		}
		return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
	}
}

// MARK: - UIScrollViewDelegate
extension ProductPreviewTableViewCell {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
	}

	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
	}
}
