//
//  LibraryListCollectionViewController+Navigation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LibraryListCollectionViewController {
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
	}
}

// MARK: - UICollectionViewDragDelegate
extension LibraryListCollectionViewController: UICollectionViewDragDelegate {
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let libraryBaseCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LibraryBaseCollectionViewCell else { return [] }
		var userActivity: NSUserActivity
		var localObject: Any?

		switch UserSettings.libraryKind {
		case .shows:
			guard let selectedShow = self.shows[safe: indexPath.row] else { return [] }
			userActivity = selectedShow.openDetailUserActivity
			localObject = selectedShow
		case .literatures:
			guard let selectedLiterature = self.literatures[safe: indexPath.row] else { return [] }
			userActivity = selectedLiterature.openDetailUserActivity
			localObject = selectedLiterature
		case .games:
			guard let selectedGame = self.games[safe: indexPath.row] else { return [] }
			userActivity = selectedGame.openDetailUserActivity
			localObject = selectedGame
		}

		let itemProvider = NSItemProvider(object: (libraryBaseCollectionViewCell as? LibraryDetailedCollectionViewCell)?.episodeImageView?.image ?? libraryBaseCollectionViewCell.posterImageView.image ?? .Placeholders.showPoster)
		itemProvider.suggestedName = libraryBaseCollectionViewCell.primaryLabel.text
		itemProvider.registerObject(userActivity, visibility: .all)

		let dragItem = UIDragItem(itemProvider: itemProvider)
		dragItem.localObject = localObject

		return [dragItem]
	}
}

// MARK: - UIScrollViewDelegate
extension LibraryListCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if let parent = self.parent?.parent as? LibraryViewController {
			parent.scrollView.contentSize = scrollView.contentSize
			parent.scrollView.contentInset = scrollView.contentInset
			parent.scrollView.contentOffset = scrollView.contentOffset
			parent.scrollView.decelerationRate = scrollView.decelerationRate
			parent.scrollView.panGestureRecognizer.state = scrollView.panGestureRecognizer.state
			parent.scrollView.directionalPressGestureRecognizer.state = scrollView.directionalPressGestureRecognizer.state
		}
	}
}
