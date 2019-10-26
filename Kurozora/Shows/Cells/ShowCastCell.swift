//
//  ShowCastCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

protocol ShowCastCellDelegate: class {
	func presentPhoto(withString string: String, from imageView: UIImageView)
	func presentPhoto(withImage image: UIImage, from imageView: UIImageView)
	func presentPhoto(withUrl url: String, from imageView: UIImageView)
}

class ShowCastCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	// MARK: - Properites
	var actors: [ActorsElement]? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {

	}
}

// MARK: - UICollectionViewDataSource
extension ShowCastCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let actorsCount = actors?.count else { return 0 }
		return actorsCount > 5 ? 5 : actorsCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let showCastCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCastCollectionCell", for: indexPath) as? ShowCastCollectionCell else { return UICollectionViewCell() }
		return showCastCollectionCell
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let showCastCollectionCell = cell as? ShowCastCollectionCell {
			showCastCollectionCell.actorElement = actors?[indexPath.row]
			showCastCollectionCell.delegate = parentViewController as? ShowDetailViewController
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ShowCastCell: UICollectionViewDelegate {

}

extension ShowCastCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 374, height: 148)
	}
}
