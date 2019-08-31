//
//  UserDefaults+Dates.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

extension UserDefaults {
	public class func shouldPerformAction(actionID: String, expirationDays: Double) -> Bool {
		if let lastAction = UserDefaults.standard.object(forKey: actionID) as? Date {
			let dayTimeInterval: Double = 24*60*60
			let timeIntervalSinceLastAction = -lastAction.timeIntervalSinceNow
			return timeIntervalSinceLastAction > (expirationDays * dayTimeInterval)
		} else {
			return true
		}
	}

	public class func completedAction(actionID: String) {
		UserDefaults.standard.set(Date(), forKey: actionID)
		UserDefaults.standard.synchronize()
	}
}
