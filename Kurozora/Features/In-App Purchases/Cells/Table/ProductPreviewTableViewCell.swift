//
//  ProductPreviewTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

/**
	- Tag: ProductPreviewTableViewCell
*/
class ProductPreviewTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView?
	@IBOutlet weak var previewImageView: UIImageView?

	// MARK: - Properties
	var previewImages: [UIImage?] = [] {
		didSet {
			let isSinglePreviewImage = previewImages.count <= 1
			collectionView?.isHidden = isSinglePreviewImage
			previewImageView?.isHidden = !isSinglePreviewImage

			if isSinglePreviewImage {
				if let previewImage = previewImages.first {
					previewImageView?.image = previewImage
				}
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ProductPreviewTableViewCell: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return previewImages.count <= 1 ? 0 : previewImages.count
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
