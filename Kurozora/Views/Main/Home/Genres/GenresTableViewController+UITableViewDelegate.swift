//
//  GenresTableViewController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

// MARK: - UITableViewDelegate
extension GenresTableViewController {
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let genreTableViewCell = tableView.cellForRow(at: indexPath) as? GenreTableViewCell {
			genreTableViewCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			genreTableViewCell.nameLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue

		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let genreTableViewCell = tableView.cellForRow(at: indexPath) as? GenreTableViewCell {
			genreTableViewCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			genreTableViewCell.nameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if let genreTableViewCell = tableView.cellForRow(at: indexPath) as? GenreTableViewCell {
			return genreTableViewCell.genre.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}

		return nil
	}

	override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		if let previewViewController = animator.previewViewController {
			animator.addCompletion {
				self.show(previewViewController, sender: self)
			}
		}
	}
}
