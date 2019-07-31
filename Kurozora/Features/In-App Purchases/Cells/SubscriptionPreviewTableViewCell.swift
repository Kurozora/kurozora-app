//
//  SubscriptionPreviewTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SubscriptionPreviewTableViewCell: UITableViewCell {
	@IBOutlet weak var collectionView: UICollectionView! {
		didSet {
			collectionView.dataSource = self
			collectionView.delegate = self
		}
	}
	var previewItems = ["aozora", "default_banner", "placeholder_banner"]
}

// MARK: - UICollectionViewDataSource
extension SubscriptionPreviewTableViewCell: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return previewItems.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let subscriptionPreviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubscriptionPreviewCollectionViewCell", for: indexPath) as! SubscriptionPreviewCollectionViewCell
		subscriptionPreviewCollectionViewCell.previewItem = previewItems[indexPath.item]
		return subscriptionPreviewCollectionViewCell
	}
}

// MARK: - UICollectionViewDelegate
extension SubscriptionPreviewTableViewCell: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDelegateFlowLayout
extension SubscriptionPreviewTableViewCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if UIDevice.isPad() {
			if UIDevice.isLandscape() {
				return CGSize(width: collectionView.width / 3, height: collectionView.height)
			}
			return CGSize(width: collectionView.width / 2, height: collectionView.height)
		}

		if UIDevice.isLandscape() {
			return CGSize(width: collectionView.width / 2, height: collectionView.height)
		}
		return CGSize(width: collectionView.width, height: collectionView.height)
	}
}
