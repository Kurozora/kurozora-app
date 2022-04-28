//
//  NotificationsTableViewController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension NotificationsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let baseNotificationCell = tableView.cellForRow(at: indexPath) as? BaseNotificationCell

		switch self.grouping {
		case .automatic, .byType:
			self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].update(at: indexPath, withReadStatus: .read)
		case .off:
			self.userNotifications[indexPath.row].update(at: indexPath, withReadStatus: .read)
		}

		switch baseNotificationCell?.notificationType ?? .other {
		case .session:
			WorkflowController.shared.openSessionsManager(in: self)
		case .follower:
			guard let userID = baseNotificationCell?.userNotification?.attributes.payload.userID else { return }
			WorkflowController.shared.openUserProfile(for: userID, in: self)
		case .subscriptionStatus:
			UIApplication.shared.kOpen(nil, deepLink: .subscriptionManagement)
		case .newFeedMessageReply, .newFeedMessageReShare:
			guard let feedMessageID = baseNotificationCell?.userNotification?.attributes.payload.feedMessageID else { return }
			WorkflowController.shared.openFeedMessage(for: feedMessageID, in: self)
		default: break
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let baseNotificationCell = tableView.cellForRow(at: indexPath) as? BaseNotificationCell {
			baseNotificationCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			(baseNotificationCell as? BasicNotificationCell)?.chevronImageView.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue
			(baseNotificationCell as? IconNotificationCell)?.titleLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue

			baseNotificationCell.contentLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			baseNotificationCell.notificationTypeLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			baseNotificationCell.dateLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let baseNotificationCell = tableView.cellForRow(at: indexPath) as? BaseNotificationCell {
			baseNotificationCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			(baseNotificationCell as? BasicNotificationCell)?.chevronImageView.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue
			(baseNotificationCell as? IconNotificationCell)?.titleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			baseNotificationCell.contentLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			baseNotificationCell.notificationTypeLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			baseNotificationCell.dateLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	// MARK: - Responding to Row Actions
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		var readStatus: ReadStatus = .unread
		switch self.grouping {
		case .automatic, .byType:
			let notificationReadStatus = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].attributes.readStatus
			if notificationReadStatus == .unread {
				readStatus = .read
			}
		case .off:
			let notificationReadStatus = self.userNotifications[indexPath.row].attributes.readStatus
			if notificationReadStatus == .unread {
				readStatus = .read
			}
		}

		let isRead = readStatus == .read
		let readUnreadAction = UIContextualAction(style: .normal, title: "") { [weak self] _, _, completionHandler in
			guard let self = self else { return }

			switch self.grouping {
			case .automatic, .byType:
				self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].update(at: indexPath, withReadStatus: readStatus)
			case .off:
				self.userNotifications[indexPath.row].update(at: indexPath, withReadStatus: readStatus)
			}
			completionHandler(true)
		}
		readUnreadAction.backgroundColor = KThemePicker.tintColor.colorValue
		readUnreadAction.title = isRead ? "Mark as Read" : "Mark as Unread"
		readUnreadAction.image = isRead ? UIImage(systemName: "circlebadge") : UIImage(systemName: "circlebadge.fill")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [readUnreadAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completionHandler in
			guard let self = self else { return }

			switch self.grouping {
			case .automatic, .byType:
				self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].remove(at: indexPath)
			case .off:
				self.userNotifications[indexPath.row].remove(at: indexPath)
			}
			completionHandler(true)
		}
		deleteAction.backgroundColor = .kLightRed
		deleteAction.image = UIImage(systemName: "minus.circle")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.grouping {
		case .automatic, .byType:
			return self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .off:
			return self.userNotifications[indexPath.row].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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

	override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		if let previewViewController = animator.previewViewController, let indexPath = configuration.identifier as? IndexPath {
			animator.addCompletion {
				switch self.grouping {
				case .automatic, .byType:
					self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].update(at: indexPath, withReadStatus: .read)
				case .off:
					self.userNotifications[indexPath.row].update(at: indexPath, withReadStatus: .read)
				}
				self.show(previewViewController, sender: self)
			}
		}
	}
}
