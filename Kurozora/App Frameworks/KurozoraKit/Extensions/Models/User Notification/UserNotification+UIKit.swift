//
//  UserNotification+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension UserNotification {
	/// Create a context menu configuration for the user's notification.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the user's notification.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [weak self] in
			guard let self = self else { return nil }

			switch self.attributes.type {
			case .session:
				return ManageActiveSessionsController()
			case .follower:
				if let userID = self.attributes.payload.userID {
					return ProfileTableViewController()(with: userID)
				}
			case .feedMessageReply, .feedMessageReShare:
				if let feedMessageID = self.attributes.payload.feedMessageID {
					return FMDetailsTableViewController()(with: feedMessageID)
				}
			default: break
			}

			return nil
		}, actionProvider: { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		})
	}

	/// Create a context menu for the user's notification.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the user's notification.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Update read status action
		let readStatus: ReadStatus = self.attributes.readStatus == .unread ? .read : .unread
		let title = readStatus == .read ? "Mark as Read" : "Mark as Unread"
		let image = readStatus == .read ? UIImage(systemName: "circlebadge") : UIImage(systemName: "circlebadge.fill")
		let updateReadStatusAction = UIAction(title: title, image: image) { [weak self] _ in
			guard let self = self else { return }
			if let indexPath = userInfo?["indexPath"] as? IndexPath {
				Task {
					await self.update(at: indexPath, withReadStatus: readStatus)
				}
			}
		}
		menuElements.append(updateReadStatusAction)

		// Delete action
		let deleteAction = UIAction(title: "Remove Notification", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { [weak self] _ in
			guard let self = self else { return }
			if let indexPath = userInfo?["indexPath"] as? IndexPath {
				Task {
					await self.remove(at: indexPath)
				}
			}
		}
		menuElements.append(UIMenu(title: "", options: .displayInline, children: [deleteAction]))

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/// Update the read/unread status of the user's notification.
	///
	/// - Parameters:
	///    - indexPath: The index path of the notification.
	///    - readStatus: The `ReadStatus` value indicating whether to mark the notification as read or unread.
	func update(at indexPath: IndexPath, withReadStatus readStatus: ReadStatus) async {
		do {
			let userNotificationUpdateResponse = try await KService.updateNotification(self.id.rawValue, withReadStatus: readStatus).value
			self.attributes.readStatus = userNotificationUpdateResponse.data.readStatus

			NotificationCenter.default.post(name: .KUNDidUpdate, object: self, userInfo: nil)
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Remove the notification from the user's notification list.
	///
	/// - Parameter indexPath: The index path of the notification.
	func remove(at indexPath: IndexPath) async {
		do {
			let notificationIdentity = UserNotificationIdentity(id: self.id)
			_ = try await KService.deleteNotification(notificationIdentity).value

			NotificationCenter.default.post(name: .KUNDidDelete, object: self, userInfo: nil)
		} catch {
			print(error.localizedDescription)
		}
	}
}
