//
//  Notification+KurozoraKit.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension Notification.Name {
	// MARK: - User state
	/// Tells that the user's sign in status has changed.
	public static var KUserIsSignedInDidChange: NSNotification.Name {
		return Notification.Name(#function)
	}
}
