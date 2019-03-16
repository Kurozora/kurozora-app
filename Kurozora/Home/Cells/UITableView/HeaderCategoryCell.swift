//
//  HeaderCategoryCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		stopHeaderColelctionTimer()
	}

	@objc func scrollToNextCell() {
		let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)

		guard let indexPathItem = visibleIndexPath?.item, let indexPathSection = visibleIndexPath?.section else { return }
		let indexPath = IndexPath(item: indexPathItem + 1, section: indexPathSection)
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
	}

	func startHeaderCollectionTimer() {
//		headerTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)
	}

	func stopHeaderColelctionTimer() {
		if headerTimer != nil {
			headerTimer?.invalidate()
			headerTimer = nil
		}
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if !onceOnly {
			let size = collectionView.contentSize
			let topLeftCoordinatesWhenCentered = CGPoint(x: (size.width - collectionView.frame.width) * 0.5, y: (size.height - collectionView.frame.height) * 0.5)
			collectionView.setContentOffset(topLeftCoordinatesWhenCentered, animated: false)

			onceOnly = true
		}
	}
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let bannersCount = banners?.count else { return 0 }
		return bannersCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! ExploreCell
		guard let bannersCount = banners?.count else { return headerCell }
		let indexPathRow = indexPath.row % bannersCount

		headerCell.showElement = banners?[indexPathRow]

		return headerCell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,	layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return itemSize
	}
}
