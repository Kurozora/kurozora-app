//
//  CastTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import BottomPopup
import EmptyDataSet_Swift

class CastCollectionViewController: BottomPopupViewController, EmptyDataSetDelegate, EmptyDataSetSource {
	@IBOutlet var grabberView: UIView! {
		didSet {
			grabberView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
    @IBOutlet var collectionView: UICollectionView!

    var actors: [ActorsElement]?

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Setup collection view
        collectionView.dataSource = self
        collectionView.delegate = self

		// Setup empty collection view
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No actors found!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
        }
    }

    // Bottom popup delegate methods
    override func getPopupHeight() -> CGFloat {
        let height: CGFloat = UIScreen.main.bounds.size.height / 1.5
        return height
    }
}

// MARK: - UICollectionViewDataSource
extension CastCollectionViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let actorsCount = actors?.count else { return 0 }
		return actorsCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let castCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCastCell", for: indexPath) as! ShowCharacterCollectionCell
		castCell.actorElement = actors?[indexPath.row]
		castCell.delegate = self
		return castCell
	}
}

// MARK: - UICollectionViewDelegate
extension CastCollectionViewController: UICollectionViewDelegate {

}

// MARK: - ShowCharacterCellDelegate
extension CastCollectionViewController: ShowCharacterCellDelegate {
	func presentPhoto(withString string: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(string: string, from: imageView)
	}

	func presentPhoto(withUrl url: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(url: url, from: imageView)
	}
}

