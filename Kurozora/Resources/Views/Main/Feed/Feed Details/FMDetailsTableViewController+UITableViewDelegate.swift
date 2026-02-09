//
//  FMDetailsTableViewController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension FMDetailsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0: break
		default:
			guard let feedMessage = self.feedMessageReplies[safe: indexPath.row] else { return }
			self.show(SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage)
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let feedMessageReplies = self.feedMessageReplies.count - 1
		var itemsCount = feedMessageReplies / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
		itemsCount = feedMessageReplies - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

		if indexPath.item >= itemsCount, self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchFeedReplies()
			}
		}
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

		switch indexPath.section {
		case 0:
			return self.feedMessage.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: tableViewCell?.contentView, barButtonItem: nil)
		default:
			return self.feedMessageReplies[indexPath.row].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: tableViewCell?.contentView, barButtonItem: nil)
		}
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
}
