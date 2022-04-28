//
//  ManageActiveSessionsController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.section == self.sessions.count - 20 && self.nextPageURL != nil {
			self.fetchSessions()
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let otherSessionsCell = tableView.cellForRow(at: indexPath) as? OtherSessionsCell {
			otherSessionsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			otherSessionsCell.ipAddressValueLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			otherSessionsCell.deviceTypeValueLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			otherSessionsCell.dateValueLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let otherSessionsCell = tableView.cellForRow(at: indexPath) as? OtherSessionsCell {
			otherSessionsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			otherSessionsCell.ipAddressValueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			otherSessionsCell.deviceTypeValueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			otherSessionsCell.dateValueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	// MARK: - Responding to Row Actions
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let signOutOfSessionAction = UIContextualAction(style: .destructive, title: "Sign Out") { [weak self] (_, _, completionHandler) in
			guard let self = self else { return }
			self.sessions[indexPath.section - 1].signOutOfSession(at: indexPath)
			completionHandler(true)
		}
		signOutOfSessionAction.backgroundColor = .kLightRed
		signOutOfSessionAction.image = UIImage(systemName: "minus.circle")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [signOutOfSessionAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if indexPath.section != 0 {
			return self.sessions[indexPath.section - 1].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
}
