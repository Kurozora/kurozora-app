//
//  HorizontalExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class HorizontalExploreCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var collectionView: UICollectionView!

	var cellStyle: ExploreCellStyle! {
		didSet {
			collectionView.dataSource = self
			collectionView.delegate = self
		}
	}
	var shows: [ExploreElement]? = nil {
		didSet {
			collectionView.reloadData()
		}
	}
	var genres: [GenreElement]? = nil {
		didSet {
			shows = nil
			collectionView.reloadData()
		}
	}
	var homeCollectionViewController: HomeCollectionViewController?
	var section: Int?
}

// MARK: - UICollectionViewDataSource
extension HorizontalExploreCollectionViewCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if shows != nil {
			guard let showsCount = shows?.count else { return 0 }
			return showsCount
		}

		guard let genresCount = genres?.count else { return 0 }
		return genresCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let exploreCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellStyle.reuseIdentifier, for: indexPath) as! ExploreCollectionViewCell
		exploreCell.homeCollectionViewController = homeCollectionViewController
		exploreCell.section = section

		if shows != nil {
			exploreCell.showElement = shows?[indexPath.row]
		} else {
			exploreCell.genreElement = genres?[indexPath.row]
		}

		if traitCollection.forceTouchCapability == .available {
			homeCollectionViewController?.registerForPreviewing(with: exploreCell, sourceView: exploreCell.contentView)
		}

		return exploreCell
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
}

// MARK: - UICollectionViewDelegate
extension HorizontalExploreCollectionViewCell: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.8,
					   initialSpringVelocity: 0.2,
					   options: .beginFromCurrentState,
					   animations: {
						cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		}, completion: nil)
	}

	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.4,
					   initialSpringVelocity: 0.2,
					   options: .beginFromCurrentState,
					   animations: {
						cell?.transform = CGAffineTransform.identity
		}, completion: nil)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HorizontalExploreCollectionViewCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var cellCount = 0

		if let showsCount = shows?.count, showsCount != 0 {
			cellCount = showsCount
		} else if let genresCount = genres?.count, genresCount != 0 {
			cellCount = genresCount
		}

		if let cellStyle = cellStyle, cellCount > 0 {
			let interItemGap = (UIDevice.isPad()) ? 40 : 20
			let gaps = (cellCount == 1) ? CGFloat(interItemGap) : CGFloat(interItemGap * cellCount)

			if self.section == 4 {
				if UIDevice.isPad() {
					if UIDevice.isLandscape() {
						return CGSize(width: (collectionView.frame.width - gaps) / 3, height: collectionView.frame.height)
					}
					return CGSize(width: (collectionView.frame.width - gaps) / 2.3, height: collectionView.frame.height)
				}

				if UIDevice.isLandscape() {
					return CGSize(width: (collectionView.frame.height - gaps), height: collectionView.frame.height)
				}
				return CGSize(width: (collectionView.frame.width - gaps), height: collectionView.frame.height)
			}

			switch cellStyle {
			case .large:
				return collectionView.frame.size
			case .medium:
				return collectionView.frame.size
			case .small:
				return collectionView.frame.size
//				if UIDevice.isPad() {
//					if UIDevice.isLandscape() {
//						return CGSize(width: (collectionView.frame.width - gaps) / 18, height: collectionView.frame.height)
//					}
//					return CGSize(width: (collectionView.frame.width - gaps) / 5, height: collectionView.frame.height)
//				}
//
//				if UIDevice.isLandscape() {
//					return CGSize(width: (collectionView.frame.width - gaps) / 5, height: collectionView.frame.height)
//				}
//				return CGSize(width: (collectionView.frame.width - gaps) / 3, height: collectionView.frame.height)
			case .video:
				return collectionView.frame.size
//				if UIDevice.isPad() {
//					if UIDevice.isLandscape() {
//						return CGSize(width: (collectionView.frame.width - gaps) / 3, height: collectionView.frame.height)
//					}
//					return CGSize(width: (collectionView.frame.width - gaps) / 2.3, height: collectionView.frame.height)
//				}
//
//				if UIDevice.isLandscape() {
//					return CGSize(width: (collectionView.frame.height - gaps), height: collectionView.frame.height)
//				}
//				return CGSize(width: (collectionView.frame.width - gaps), height: collectionView.frame.height)
			}
		}

		return .zero
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return (UIDevice.isPad()) ? 40 : 20
	}
}
