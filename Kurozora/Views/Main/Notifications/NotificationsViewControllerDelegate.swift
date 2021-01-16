//
//  NotificationsViewControllerDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol NotificationsViewControllerDelegate: class {
	func notificationsViewControllerHasUnreadNotifications(count: Int)
	func notificationsViewControllerClearedAllNotifications()
}
