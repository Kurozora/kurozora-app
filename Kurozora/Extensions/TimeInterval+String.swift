//
//  TimeInterval+String.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension TimeInterval {
	var toString: String {
		let timeIntervalInteger = Int(self)
		let seconds = timeIntervalInteger % 60
		let minutes = (timeIntervalInteger / 60) % 60
		let hours = (timeIntervalInteger / 3600) % 24
		let days = (timeIntervalInteger / 86400)

		return String(format: "%0.2dd, %0.2dh, %0.2dm, %0.2ds", days, hours, minutes, seconds)
	}
}
