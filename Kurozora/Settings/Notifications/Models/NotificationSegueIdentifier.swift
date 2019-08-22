//
//  NotificationSegueIdentifier.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of notification segue identifiers.

	```
	case notificationsGrouping = "notificationsGroupingSegue"
	case bannerStyle = "bannerStyleSegue"
	```
*/
enum NotificationSegueIdentifier: String {
	/// Indicates the view should segue to the notifications grouping options view.
	case notificationsGrouping = "notificationsGroupingSegue"

	/// Indicates the view should segue to the banner style options view.
	case bannerStyle = "bannerStyleSegue"
}
