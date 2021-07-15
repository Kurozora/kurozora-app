//
//  SearchResultsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

// MARK: - UICollectionViewDelegate
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let searchBaseResultsCell = collectionView.cellForItem(at: indexPath)
		if searchResults != nil {
			switch currentScope {
			case .show, .library:
				if let show = (searchBaseResultsCell as? SearchShowResultsCell)?.show {
					let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: show.id)
					SearchHistory.saveContentsOf(show)
					self.show(showDetailsCollectionViewController, sender: nil)
				}
			case .user:
				if let user = (searchBaseResultsCell as? SearchUserResultsCell)?.user {
					let profileTableViewController = ProfileTableViewController.`init`(with: user.id)
					self.show(profileTableViewController, sender: nil)
				}
			}
		} else {
			if let show = (searchBaseResultsCell as? SearchSuggestionResultCell)?.show {
				let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: show.id)
				self.show(showDetailsCollectionViewController, sender: nil)
			}
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let numberOfItems = collectionView.numberOfItems()

		if indexPath.item == numberOfItems - 10 {
			if self.nextPageURL != nil {
				guard let text = kSearchController.searchBar.textField?.text else { return }
				guard let searchScope = SearchScope(rawValue: kSearchController.searchBar.selectedScopeButtonIndex) else { return }
				self.performSearch(withText: text, in: searchScope)
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let searchBaseResultsCell = collectionView.cellForItem(at: indexPath)
		if searchResults != nil {
			switch currentScope {
			case .show, .library:
				if let searchShowResultsCell = searchBaseResultsCell as? SearchShowResultsCell {
					SearchHistory.saveContentsOf(searchShowResultsCell.show)
					return searchShowResultsCell.show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
				}
			case .user:
				if let searchUserResultsCell = searchBaseResultsCell as? SearchUserResultsCell {
					return searchUserResultsCell.user?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
				}
			}
		} else {
			if let searchSuggestionResultCell = searchBaseResultsCell as? SearchSuggestionResultCell {
				return searchSuggestionResultCell.show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
			}
		}

		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let collectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: collectionViewCell, parameters: parameters)
		}
		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let collectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: collectionViewCell, parameters: parameters)
		}
		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		if let previewViewController = animator.previewViewController {
			animator.addCompletion {
				self.show(previewViewController, sender: self)
			}
		}
	}
}
