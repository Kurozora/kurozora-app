//
//  SKProduct+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
	/// Returns the formatted price and price locale. i.e. `€4,99`
	var priceLocaleFormatted: String {
		let numberFormatter = NumberFormatter()
		numberFormatter.formatterBehavior = .behavior10_4
		numberFormatter.numberStyle = .currency
		numberFormatter.locale = self.priceLocale

		let formattedPrice = numberFormatter.string(from: self.price)?.replacingOccurrences(of: " ", with: "")
		return formattedPrice ?? self.price.stringValue
	}
}

@available(iOS 11.2, *)
extension SKProduct.PeriodUnit {
	/// Returns the string value of a `PeriodUnit`.
	var stringValue: String {
		switch self {
		case .day:
			return "day"
		case .week:
			return "Week"
		case .month:
			return "Month"
		case .year:
			return "Year"
		default:
			return "Unknown"
		}
	}
}

@available(iOS 11.2, *)
extension SKProductSubscriptionPeriod {
	/// Returns a `PeriodUnit stringValue` in pluralized form if required.
	var unitString: String {
		let unitString = self.unit.stringValue
		switch self.numberOfUnits {
		case 0...1:
			return unitString
		default:
			return unitString + "s"
		}
	}

	/// Returns the full string of a subscription period which includes `numberOfUnits` and `unitString`.
	var fullString: String {
		if numberOfUnits == 1, unitString == "Year" {
			return "12 Months"
		}
		return "\(numberOfUnits) \(unitString)"
	}
}
