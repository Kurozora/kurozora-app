//
//  NotificationsTableViewController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension NotificationsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard !self.isEditing else {
			self.didUpdateBatchSelection()
			return
		}

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
		case .userMention:
			if let feedMessageID = userNotification.attributes.payload.feedMessageID {
				WorkflowController.shared.openFeedMessage(for: feedMessageID, in: self)
			} else if let link = userNotification.attributes.payload.link, let feedMessageID = Self.feedMessageID(fromLink: link) {
				WorkflowController.shared.openFeedMessage(for: feedMessageID, in: self)
			}
		default: break
		}
	}

	/// Extracts the trailing feed message identifier from a mention payload link.
	///
	/// - Parameter link: The URL string from a mention notification's payload.
	///
	/// - Returns: The feed message identifier, or `nil` if the link does not point to a feed message.
	private static func feedMessageID(fromLink link: String) -> KurozoraItemID? {
		guard let url = URL(string: link) else { return nil }
		let components = url.pathComponents

		guard let messagesIndex = components.firstIndex(of: "messages"),
			  components.index(after: messagesIndex) < components.endIndex else {
			return nil
		}

		let rawID = components[components.index(after: messagesIndex)]
		guard !rawID.isEmpty else { return nil }

		return KurozoraItemID(rawID)
	}

	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard self.isEditing else { return }
		self.didUpdateBatchSelection()
	}

	override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return User.isSignedIn
	}

	override func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
		self.setEditing(true, animated: true)
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		guard !self.isEditing else { return }
		(tableView.cellForRow(at: indexPath) as? BaseNotificationCell)?.applyHighlightedAppearance(highlighted: true)
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		guard !self.isEditing else { return }
		(tableView.cellForRow(at: indexPath) as? BaseNotificationCell)?.applyHighlightedAppearance(highlighted: false)
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch self.dataSource.sectionIdentifier(for: section) {
		case .grouped(let groupNotification):
			let titleHeaderTableReusableView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleHeaderTableReusableView.reuseIdentifier) as? TitleHeaderTableReusableView
			titleHeaderTableReusableView?.configure(withTitle: groupNotification.sectionTitle, buttonIsHidden: true, section: section)
			return titleHeaderTableReusableView
		case .main, .none:
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard !self.isEditing else { return nil }
		guard let userNotification = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

		let notificationReadStatus = userNotification.attributes.readStatus
		let readStatus: ReadStatus = notificationReadStatus == .unread ? .read : .unread
		let isRead = readStatus == .read

		let readUnreadAction = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
			Task {
				await userNotification.update(at: indexPath, withReadStatus: readStatus)
				completionHandler(true)
			}
		}
		readUnreadAction.backgroundColor = KThemePicker.tintColor.colorValue
		readUnreadAction.title = isRead ? L10n.markAsRead : L10n.markAsUnread
		readUnreadAction.image = isRead ? UIImage(systemName: "circlebadge") : UIImage(systemName: "circlebadge.fill")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [readUnreadAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard !self.isEditing else { return nil }
		guard let userNotification = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

		let deleteAction = UIContextualAction(style: .destructive, title: L10n.remove) { _, _, completionHandler in
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

	// MARK: - Context menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard !self.isEditing else { return nil }

		let tableViewCell = tableView.cellForRow(at: indexPath)
		let userNotification = self.dataSource.itemIdentifier(for: indexPath)
		return userNotification?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: tableViewCell?.contentView, barButtonItem: nil)
	}

	override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let indexPath = configuration.identifier as? IndexPath else { return nil }
		guard let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear
		return UITargetedPreview(view: tableViewCell, parameters: parameters)
	}

	override func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let indexPath = configuration.identifier as? IndexPath else { return nil }
		guard let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear
		return UITargetedPreview(view: tableViewCell, parameters: parameters)
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
