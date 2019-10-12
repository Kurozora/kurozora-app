//
//  HorizontalExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class HorizontalExploreCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	// MARK: - Properties
	var currentlyPlayingIndexPath: IndexPath? = nil

	var cellStyle: ExploreCellStyle! {
		didSet {
			collectionView.dataSource = self
			collectionView.delegate = self
		}
	}
	var shows: [ShowDetailsElement]? = nil {
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

	// MARK: - Functions
	@available(iOS 13.0, macCatalyst 13.0, *)
	func makeContextMenu(for show: ShowDetailsElement?) -> UIMenu {
		let title = show?.title ?? ""

		let share = UIAction(title: "Share \(title)", image: UIImage(systemName: "square.and.pencil")) { _ in
			guard let showID = show?.id else { return }
			var shareText: [String] = ["https://kurozora.app/anime/\(showID)\nYou should watch this anime via @KurozoraApp"]

			if !title.isEmpty {
				shareText = ["https://kurozora.app/anime/\(showID)\nYou should watch \"\(title)\" via @KurozoraApp"]
			}

			let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

			if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.parentViewController?.present(activityVC, animated: true, completion: nil)
			}
		}

		// Create our menu with both the edit menu and the share action
		return UIMenu(title: "Main Menu", children: [share])
	}
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
		let exploreCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellStyle.reuseIdentifier, for: indexPath) as! ExploreBaseCollectionViewCell
//		exploreCell.homeCollectionViewController = homeCollectionViewController
		exploreCell.indexPath = indexPath
		exploreCell.delegate = self
		(exploreCell as? ExploreVideoCollectionViewCell)?.shouldPlay = self.currentlyPlayingIndexPath == indexPath

		if shows != nil {
			exploreCell.showDetailsElement = shows?[indexPath.row]
		} else {
			exploreCell.genreElement = genres?[indexPath.row]
		}

		#if !targetEnvironment(macCatalyst)
		if traitCollection.forceTouchCapability == .available {
			homeCollectionViewController?.registerForPreviewing(with: exploreCell, sourceView: exploreCell)
		}
		#endif

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

	@available(iOS 13.0, macCatalyst 13.0, *)
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if shows != nil {
			return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
				return self.makeContextMenu(for: self.shows?[indexPath.row])
			})
		}

		return nil
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
			switch cellStyle {
			case .large:
				return collectionView.frame.size
			case .medium:
				return collectionView.frame.size
			case .small:
				return collectionView.frame.size
			case .video:
				return collectionView.frame.size
			}
		}

		return .zero
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return UIDevice.isPad ? 20 : 20
	}
}

extension HorizontalExploreCollectionViewCell: ExploreCollectionViewCellDelegate {
	func playVideoForCell(with indexPath: IndexPath) {
		self.currentlyPlayingIndexPath = indexPath
		self.collectionView.reloadItems(at: [indexPath])
	}
}
