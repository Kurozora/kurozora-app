//
//  CastTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class CastCollectionViewController: UICollectionViewController, EmptyDataSetDelegate, EmptyDataSetSource {
    var actors: [ActorsElement]?

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

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

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
	}

	// MARK: - IBActions
	@IBAction func dismissPressed(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UICollectionViewDataSource
extension CastCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let actorsCount = actors?.count else { return 0 }
		return actorsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let castCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCastCell", for: indexPath) as! ShowCharacterCollectionCell
		castCell.actorElement = actors?[indexPath.row]
		castCell.delegate = self
		return castCell
	}
}

// MARK: - UICollectionViewDelegate
extension CastCollectionViewController {

}

extension CastCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let gap: CGFloat = UIDevice.isPad() ? 40 : 20
		if UIDevice.isPad() {
			if UIDevice.isLandscape() {
				return CGSize(width: (collectionView.width - gap) / 4, height: (collectionView.height - gap) / 6)
			}

			return CGSize(width: (collectionView.width - gap) / 3, height: (collectionView.height - gap) / 8)
		}

		if UIDevice.hasTopNotch {
			if UIDevice.isLandscape() {
				return CGSize(width: (collectionView.width - gap) / 2, height: (collectionView.height - gap) / 2)
			}

			return CGSize(width: collectionView.width, height: (collectionView.height - gap) / 5)
		}

		if UIDevice.isLandscape() {
			return CGSize(width: (collectionView.width - gap) / 2, height: (collectionView.height - gap) / 1.8)
		}

		return CGSize(width: collectionView.width, height: (collectionView.height - gap) / 3.6)
	}
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

