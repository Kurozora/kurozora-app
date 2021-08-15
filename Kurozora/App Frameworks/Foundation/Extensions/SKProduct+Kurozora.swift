//
//  SKProduct+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - SKProduct
extension SKProduct {
	// MARK: - Properties
	/**
		Returns the localized price of the product.

		For example 4.99 with NL local:
		```
		priceLocaleFormatted // "€4,99"
		```
		and with US lcoale:
		```
		priceLocaleFormatted // "$4.99"
		```
	*/
	var priceLocaleFormatted: String {
		// Remove "no-break space" before returning.
		return self.localizedPrice?.replacingOccurrences(of: " ", with: "") ?? price.stringValue
	}

	/**
		Returns a decimal number of the price devided by the availability period in months.

		For example if you have a product that costs `23.88` for a period of 12 months:
		```
		pricePerMonth // "1.99"
		```
	*/
	fileprivate var pricePerMonth: NSDecimalNumber {
		var numberOfUnits = subscriptionPeriod?.numberOfUnits.double ?? 0.00
		let unitString = subscriptionPeriod?.unitString
		let behavior = NSDecimalNumberHandler(roundingMode: .down, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)

		if numberOfUnits == 1, unitString == "Year" {
			numberOfUnits = 12.0
		}

		let pricePerMonth = price.dividing(by: NSDecimalNumber(decimal: Decimal(numberOfUnits)), withBehavior: behavior)
		return pricePerMonth
	}

	/**
		Returns a localized string of the price devided by the availability period in months.

		For example if you have a product that costs `23.88` for a period of 12 months, with NL locale:
		```
		pricePerMonthLocalized // "€1,99"
		```
		and with the US locale:
		```
		pricePerMonthLocalized // "$1.99"
		```
	*/
	var pricePerMonthLocalized: String {
		return formattedToLocal(price: pricePerMonth)
	}

	// MARK: - Functions
	/**
		Format the given `NSDecimalNumber` to a localized string.

		If the formatting fails due to an unknown locale, this method returns the price itself as a string.
		For example if given with the NL locale:
		```
		formattedToLocal(price: 4.99)
		// Returns "€4,99"
		```
		or with an unknown locale:
		```
		formattedToLocal(price: 4.99)
		// Returns "4.99"
		```

		- Parameter price: The price that should be converted to a localized string.

		- Returns: The localized string of the price or the price only as a string.
	*/
	fileprivate func formattedToLocal(price: NSDecimalNumber) -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .currency
		numberFormatter.locale = self.priceLocale

		// Remove "no-break space" before returning.
		let formattedPrice = numberFormatter.string(from: price)?.replacingOccurrences(of: " ", with: "")
		return formattedPrice ?? price.stringValue
	}

	/**
		Returns a string of the percentage saved compared to the given price.

		For example with a product that costs 1.99:
		```
		product.priceSaved(comparedTo: 3.99)
		// Returns "50%"
		```

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

// MARK: - PeriodUnit
extension SKProduct.PeriodUnit {
	// MARK: - Protperies
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

// MARK: - SKProductSubscriptionPeriod
extension SKProductSubscriptionPeriod {
	// MARK: - Properties
	/// Returns a `PeriodUnit stringValue` in pluralized form if required.
	fileprivate var unitString: String {
		let unitString = self.unit.stringValue
		switch self.numberOfUnits {
		case 0...1:
			return unitString
		default:
			return unitString + "s"
		}
	}

	/**
		Returns the full string of a subscription period which includes `numberOfUnits` and `unitString`.

		Only exception is for `1 Year`, where instead `"12 Months"` is returned.
	*/
	var fullString: String {
		if numberOfUnits == 1, self.unitString == "Year" {
			return "12 Months"
		}
		return "\(numberOfUnits) \(self.unitString)"
	}
}
