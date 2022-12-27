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
		guard let userNotification = self.dataSource.itemIdentifier(for: indexPath) else { return }

		if userNotification.attributes.readStatus == .unread {
			Task {
				await userNotification.update(at: indexPath, withReadStatus: .read)
			}
		}

		switch userNotification.attributes.type {
		case .session:
			WorkflowController.shared.openSessionsManager(in: self)
		case .follower:
			guard let userID = userNotification.attributes.payload.userID else { return }
			WorkflowController.shared.openUserProfile(for: userID, in: self)
		case .subscriptionStatus:
			UIApplication.shared.kOpen(nil, deepLink: .subscriptionManagement)
		case .feedMessageReply, .feedMessageReShare:
			guard let feedMessageID = userNotification.attributes.payload.feedMessageID else { return }
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

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleHeaderTableReusableView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleHeaderTableReusableView.reuseIdentifier) as? TitleHeaderTableReusableView
		titleHeaderTableReusableView?.delegate = self

		switch self.grouping {
		case .automatic, .byType:
			let groupNotification = self.groupedNotifications[section]
			let allNotificationsRead = groupNotification.sectionNotifications.contains(where: { $0.attributes.readStatus == .read })
			let title = groupNotification.sectionTitle
			let buttonTitle = allNotificationsRead ? "Mark as unread" : "Mark as read"

			titleHeaderTableReusableView?.configure(withTitle: title, buttonTitle: buttonTitle, section: section)
			return titleHeaderTableReusableView
		case .off: break
		}

		return nil
	}

	// MARK: - Responding to Row Actions
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let userNotification = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
		let notificationReadStatus = userNotification.attributes.readStatus
		var readStatus: ReadStatus = .unread

		if notificationReadStatus == .unread {
			readStatus = .read
		}

		let isRead = readStatus == .read
		let readUnreadAction = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
			Task {
				await userNotification.update(at: indexPath, withReadStatus: readStatus)
				completionHandler(true)
			}
		}
		readUnreadAction.backgroundColor = KThemePicker.tintColor.colorValue
		readUnreadAction.title = isRead ? "Mark as Read" : "Mark as Unread"
		readUnreadAction.image = isRead ? UIImage(systemName: "circlebadge") : UIImage(systemName: "circlebadge.fill")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [readUnreadAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let userNotification = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

		let deleteAction = UIContextualAction(style: .destructive, title: Trans.remove) { _, _, completionHandler in
			Task {
				await userNotification.remove(at: indexPath)
				completionHandler(true)
			}
		}
		deleteAction.backgroundColor = .kLightRed
		deleteAction.image = UIImage(systemName: "minus.circle")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let userNotification = self.dataSource.itemIdentifier(for: indexPath)
		return userNotification?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
		guard let previewViewController = animator.previewViewController, let indexPath = configuration.identifier as? IndexPath else { return }
		let userNotification = self.dataSource.itemIdentifier(for: indexPath)

		animator.addCompletion { [weak self] in
			guard let self = self else { return }

			Task {
				await userNotification?.update(at: indexPath, withReadStatus: .read)
				self.show(previewViewController, sender: self)
			}
		}
	}
}
