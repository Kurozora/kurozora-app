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

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			switch KNotification.CustomType(rawValue: self.attributes.type) {
			case .follower:
				if let userID = self.attributes.payload.userID {
					return ProfileTableViewController.`init`(with: userID)
				}
			case .session:
				return R.storyboard.accountSettings.manageActiveSessionsController()
			default: break
			}

			return nil
		}, actionProvider: { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Update read status action
		let readStatus: ReadStatus = self.attributes.readStatus == .unread ? .read : .unread
		let title = readStatus == .read ? "Mark as Read" : "Mark as Unread"
		let image = readStatus == .read ? UIImage(systemName: "circlebadge") : UIImage(systemName: "circlebadge.fill")
		let updateReadStatusAction = UIAction(title: title, image: image) { _ in
			if let indexPath = userInfo?["indexPath"] as? IndexPath {
				self.update(at: indexPath, withReadStatus: readStatus)
			}
		}
		menuElements.append(updateReadStatusAction)

		// Delete action
		let deleteAction = UIAction(title: "Remove Notification", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { _ in
			if let indexPath = userInfo?["indexPath"] as? IndexPath {
				self.remove(at: indexPath)
			}
		}
		menuElements.append(UIMenu(title: "", options: .displayInline, children: [deleteAction]))

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/**
		Update the read/unread status of the user's notification.

		- Parameter indexPath: The index path of the notification.
		- Parameter readStatus: The `ReadStatus` value indicating whether to mark the notification as read or unread.
	*/
	func update(at indexPath: IndexPath, withReadStatus readStatus: ReadStatus) {
		KService.updateNotification(self.id, withReadStatus: readStatus) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let readStatus):
				self.attributes.readStatus = readStatus

				NotificationCenter.default.post(name: .KUNDidUpdate, object: nil, userInfo: ["indexaPth": [indexPath]])
			case .failure: break
			}
		}
	}

	/**
		Remove the notification from the user's notification list.

		- Parameter indexPath: The index path of the notification.
	*/
	func remove(at indexPath: IndexPath) {
		KService.deleteNotification(self.id) { result in
			switch result {
			case .success:
				NotificationCenter.default.post(name: .KUNDidDelete, object: nil, userInfo: ["indexPath": indexPath])
			case .failure:
				break
			}
		}
	}
}

extension Array where Element == UserNotification {
	/**
		Batch update the read/unread status of the user's notifications.

		- Parameter indexPaths: The index paths of the notifications.
		- Parameter readStatus: The `ReadStatus` value indicating whether to mark the notification as read or unread.
	*/
	func batchUpdate(at indexPaths: [IndexPath]? = nil, for notificationIDs: String, withReadStatus readStatus: ReadStatus) {
		KService.updateNotification(notificationIDs, withReadStatus: readStatus) { result in
			switch result {
			case .success:
				if let indexPaths = indexPaths {
					for indexPath in indexPaths {
						self[indexPath.row].attributes.readStatus = readStatus
					}
				} else {
					for notification in self {
						notification.attributes.readStatus = readStatus
					}
				}

				NotificationCenter.default.post(name: .KUNDidUpdate, object: nil, userInfo: ["indexPaths": indexPaths as Any])
			case .failure: break
			}
		}
	}
}
