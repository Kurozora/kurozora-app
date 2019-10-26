//
//  ShowSeasonsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ShowSeasonsCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	// MARK: - Properites
	var seasons: [SeasonsElement]? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {

	}
}

// MARK: - UICollectionViewDataSource
extension ShowSeasonsCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let seasonsCount = seasons?.count else { return 0 }
		return seasonsCount > 5 ? 5 : seasonsCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let seasonsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonsCollectionViewCell", for: indexPath) as? SeasonsCollectionViewCell else { return UICollectionViewCell() }
		return seasonsCollectionViewCell
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let seasonsCollectionViewCell = cell as? SeasonsCollectionViewCell {
			seasonsCollectionViewCell.seasonsElement = seasons?[indexPath.row]
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ShowSeasonsCell: UICollectionViewDelegate {

}

extension ShowSeasonsCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 374, height: 148)
	}
}
