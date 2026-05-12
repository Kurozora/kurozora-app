//
//  ProfileTableViewController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.heightCache[indexPath] ?? 200
	}

	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let cell = tableView.cellForRow(at: indexPath)

		if cell is ProfileBlockedByBannerTableViewCell || cell is ProfileBlockedOptInTableViewCell {
			return nil
		}

		return indexPath
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let feedMessage = self.feedMessages[safe: indexPath.row] else { return }
		self.show(.feedMessageDetailsSegue, sender: feedMessage)
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		self.heightCache[indexPath] = cell.bounds.height

		let feedMessages = self.feedMessages.count - 1
		var itemsCount = feedMessages / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = feedMessages - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount, self.nextPageCursor != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchFeedMessages()
			}
		}
	}

	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let cell = tableView.cellForRow(at: indexPath)
		return !(cell is ProfileBlockedByBannerTableViewCell || cell is ProfileBlockedOptInTableViewCell)
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let baseFeedMessageCell = tableView.cellForRow(at: indexPath) as? BaseFeedMessageCell {
			baseFeedMessageCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			baseFeedMessageCell.displayNameLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			baseFeedMessageCell.usernameLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			baseFeedMessageCell.postTextView.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let baseFeedMessageCell = tableView.cellForRow(at: indexPath) as? BaseFeedMessageCell {
			baseFeedMessageCell.contentView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

			baseFeedMessageCell.displayNameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			baseFeedMessageCell.usernameLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			baseFeedMessageCell.postTextView.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let tableViewCell = tableView.cellForRow(at: indexPath)

		if tableViewCell is ProfileBlockedByBannerTableViewCell || tableViewCell is ProfileBlockedOptInTableViewCell {
			return nil
		}

		guard let feedMessage = self.feedMessages[safe: indexPath.row] else { return nil }
		return feedMessage.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: tableViewCell?.contentView, barButtonItem: nil)
	}

	override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}
}
