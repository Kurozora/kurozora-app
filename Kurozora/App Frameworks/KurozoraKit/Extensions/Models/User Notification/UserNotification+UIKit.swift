//
//  UserNotification+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension UserNotification {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [weak self] in
			guard let self = self else { return nil }

			switch self.attributes.type {
			case .session:
				return R.storyboard.accountSettings.manageActiveSessionsController()
			case .follower:
				if let userID = self.attributes.payload.userID {
					return ProfileTableViewController.`init`(with: userID)
				}
			case .feedMessageReply, .feedMessageReShare:
				if let feedMessageID = self.attributes.payload.feedMessageID {
					return FMDetailsTableViewController.`init`(with: feedMessageID)
				}
			default: break
			}

			return nil
		}, actionProvider: { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
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
			let userNotificationUpdateResponse = try await KService.updateNotification(self.id, withReadStatus: readStatus).value
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
			_ = try await KService.deleteNotification(self.id).value

			NotificationCenter.default.post(name: .KUNDidDelete, object: self, userInfo: nil)
		} catch {
			print(error.localizedDescription)
		}
	}
}
