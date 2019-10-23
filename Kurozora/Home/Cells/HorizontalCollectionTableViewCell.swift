//
//  HorizontalCollectionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class HorizontalCollectionTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView! {
		didSet {
			NotificationCenter.default.addObserver(self, selector: #selector(invalidateCollectionViewLayout), name: .KEDidInvalidateContentSize, object: nil)
		}
	}

	// MARK: - Properties
	var currentlyPlayingIndexPath: IndexPath? = nil
	var cellStyle: HorizontalCollectionCellStyle!
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
	var contentOffset: CGFloat! {
		get {
			return collectionView.contentOffset.x
		}
		set {
			collectionView.setContentOffset(CGPoint(x: newValue >= 0 ? newValue : 0, y: 0), animated: false)
		}
	}

	// MARK: - Functions
	@objc func invalidateCollectionViewLayout() {
		collectionView.performBatchUpdates({}, completion: nil)
	}

	@available(iOS 13.0, macCatalyst 13.0, *)
	func makeContextMenu(for show: ShowDetailsElement?) -> UIMenu {
		let title = show?.title ?? ""

		let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
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
		return UIMenu(title: "", children: [share])
	}
}

// MARK: - UICollectionViewDataSource
extension HorizontalCollectionTableViewCell: UICollectionViewDataSource {
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
			self.parentViewController?.registerForPreviewing(with: exploreCell, sourceView: exploreCell)
		}
		#endif

		return exploreCell
	}
}

// MARK: - UICollectionViewDelegate
extension HorizontalCollectionTableViewCell: UICollectionViewDelegate {
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

	@available(iOS 13.0, macCatalyst 13.0, *)
	func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		if let homeTableViewController = self.parentViewController as? HomeCollectionViewController {
			animator.addCompletion {
				homeTableViewController.performSegue(withIdentifier: "ShowDetailsSegue", sender: self)
			}
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HorizontalCollectionTableViewCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var size = collectionView.size

		switch cellStyle {
		case .banner:
			size = CGSize(width: self.frame.width - 60, height: self.frame.height - 10)
		case .medium:
			size = CGSize(width: 284, height: (self.frame.height / 2) - 15)
		case .small:
			return CGSize(width: 284, height: (self.frame.height / 2) - 15)
		case .video:
			size = CGSize(width: 284, height: self.frame.height - 10)
		default: break
		}

		return size
	}
}

// MARK: - ExploreBaseCollectionViewCellDelegate
extension HorizontalCollectionTableViewCell: ExploreBaseCollectionViewCellDelegate {
	func playVideoForCell(with indexPath: IndexPath) {
		self.currentlyPlayingIndexPath = indexPath
		self.collectionView.reloadItems(at: [indexPath])
	}
}
