//
//  ReCapCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReCapCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let model = self.cachedItem(at: indexPath) else { return }
		self.showDetails(of: model)
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let model = self.cachedItem(at: indexPath) else { return nil }
		let sourceView = collectionView.cellForItem(at: indexPath)?.contentView
		return self.contextMenuConfiguration(for: model, sourceView: sourceView, userInfo: ["indexPath": indexPath])
	}

	/// Returns the context menu of the given model.
	///
	/// - Parameters:
	///    - model: The model the menu acts on.
	///    - sourceView: The view the menu is presented from.
	///    - userInfo: Additional information about the menu.
	///
	/// - Returns: The context menu of the model.
	func contextMenuConfiguration(for model: KurozoraItem, sourceView: UIView?, userInfo: [AnyHashable: Any]? = nil) -> UIContextMenuConfiguration? {
		switch model {
		case let show as Show:
			return show.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		case let literature as Literature:
			return literature.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		case let game as Game:
			return game.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		case let studio as Studio:
			return studio.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		case let character as Character:
			return character.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		case let person as Person:
			return person.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		case let genre as Genre:
			return genre.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		case let theme as Theme:
			return theme.contextMenuConfiguration(in: self, userInfo: userInfo, sourceView: sourceView, barButtonItem: nil)
		default:
			return nil
		}
	}

	/// Shows the context menus of the given models in the given handler.
	///
	/// - Parameters:
	///    - contextMenuHandler: The handler of a card's context menus.
	///    - models: The models of the card's titles.
	func configure(_ contextMenuHandler: ReCapContextMenuHandler, for models: [KurozoraItem]) {
		contextMenuHandler.configurationProvider = { [weak self] index, sourceView in
			guard let self, let model = models[safe: index] else { return nil }
			return self.contextMenuConfiguration(for: model, sourceView: sourceView)
		}
		contextMenuHandler.previewCommitHandler = { [weak self] previewViewController in
			guard let self else { return }
			self.show(previewViewController, sender: self)
		}
	}
}
