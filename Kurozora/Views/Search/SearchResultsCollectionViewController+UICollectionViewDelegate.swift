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
			case .show, .myLibrary:
				if let show = (searchBaseResultsCell as? SearchShowResultsCell)?.show {
					let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: show.id)
					showDetailsCollectionViewController.edgesForExtendedLayout = .all
					SearchHistory.saveContentsOf(show)
					self.presentingViewController?.show(showDetailsCollectionViewController, sender: nil)
				}
			case .thread:
				if let forumsThread = (searchBaseResultsCell as? SearchForumsResultsCell)?.forumsThread {
					let threadTableViewController = ThreadTableViewController.`init`(with: forumsThread.id)
					self.presentingViewController?.show(threadTableViewController, sender: nil)
				}
			case .user:
				if let user = (searchBaseResultsCell as? SearchUserResultsCell)?.user {
					let profileTableViewController = ProfileTableViewController.`init`(with: user.id)
					self.presentingViewController?.show(profileTableViewController, sender: nil)
				}
			}
		} else {
			if let show = (searchBaseResultsCell as? SearchSuggestionResultCell)?.show {
				let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: show.id)
				showDetailsCollectionViewController.edgesForExtendedLayout = .all
				self.presentingViewController?.show(showDetailsCollectionViewController, sender: nil)
			}
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let searchBaseResultsCell = collectionView.cellForItem(at: indexPath)
		if searchResults != nil {
			switch currentScope {
			case .show, .myLibrary:
				if let searchShowResultsCell = searchBaseResultsCell as? SearchShowResultsCell {
					SearchHistory.saveContentsOf(searchShowResultsCell.show)
					return searchShowResultsCell.show?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
				}
			case .thread:
				if let searchForumsResultsCell = searchBaseResultsCell as? SearchForumsResultsCell {
					return searchForumsResultsCell.forumsThread.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
				self.presentingViewController?.show(previewViewController, sender: self)
			}
		}
	}
}