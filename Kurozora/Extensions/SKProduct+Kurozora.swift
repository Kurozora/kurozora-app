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
		return formattedToLocal(price: self.price)
	}

	fileprivate func formattedToLocal(price: NSDecimalNumber) -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.formatterBehavior = .behavior10_4
		numberFormatter.numberStyle = .currency
		numberFormatter.locale = self.priceLocale

		let formattedPrice = numberFormatter.string(from: price)?.replacingOccurrences(of: " ", with: "")
		return formattedPrice ?? price.stringValue
	}

	/// Returns a decimal number of the price devided by the availability period in months.
	var pricePerMonth: NSDecimalNumber {
		var numberOfUnits = subscriptionPeriod?.numberOfUnits.double ?? 0.00
		let unitString = subscriptionPeriod?.unitString
		let behavior = NSDecimalNumberHandler(roundingMode: .down, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

		if numberOfUnits == 1, unitString == "Year" {
			numberOfUnits = 12.0
		}

		let pricePerMonth = price.dividing(by: NSDecimalNumber(decimal: Decimal(numberOfUnits)), withBehavior: behavior)
		return pricePerMonth
	}

	/// Returns a string of the price devided by the availability period in months.
	var pricePerMonthString: String {
		return formattedToLocal(price: pricePerMonth)
	}

	/**
		Returns a string of the percentage saved compared to the given price.

		- Parameter price: The price by which the comparision is done.

		- Returns: a string of the percentage saved compared to the given price.
	*/
	func priceSaved(comparedTo price: NSDecimalNumber) -> String {
		let percentageSaved = 100 - (100 / price.decimalValue * pricePerMonth.decimalValue)
		let behavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
		let decimalNumber = NSDecimalNumber(decimal: percentageSaved)
		return decimalNumber.rounding(accordingToBehavior: behavior).stringValue + "%"
	}
}

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
