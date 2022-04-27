//
//  StoreKit+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import StoreKit

extension Product {
	/// Returns a localized string of the price devided by the availability period in months.
	var displayPricePerMonth: String {
		switch self.type {
		case .autoRenewable, .nonRenewable:
			guard let subscription = self.subscription else { return self.displayPrice }
			let unit = subscription.subscriptionPeriod.unit

			switch unit {
			case .day:
				return self.displayPrice
			case .week:
				return self.displayPrice
			case .month:
				return self.formattedToLocale(price: self.pricePerMonth)
			case .year:
				return self.formattedToLocale(price: self.pricePerMonth)
			@unknown default:
				return self.displayPrice
			}
		default: return self.displayPrice
		}
	}

	/// Returns the price devided by the availability period in months.
	var pricePerMonth: Decimal {
		switch self.type {
		case .autoRenewable, .nonRenewable:
			guard let subscription = self.subscription else { return self.price }
			let unit = subscription.subscriptionPeriod.unit

			switch unit {
			case .day:
				return self.price
			case .week:
				return self.price
			case .month:
				let pricePerMonth: NSDecimalNumber = NSDecimalNumber(decimal: self.price / Decimal(subscription.subscriptionPeriod.value))
				let behavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
				return pricePerMonth.rounding(accordingToBehavior: behavior) as Decimal
			case .year:
				let pricePerMonth: NSDecimalNumber = NSDecimalNumber(decimal: self.price / Decimal(subscription.subscriptionPeriod.value * 12))
				let behavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
				return pricePerMonth.rounding(accordingToBehavior: behavior) as Decimal
			@unknown default:
				return self.price
			}
		default: return self.price
		}
	}

	// MARK: - Functions
	/// Format the given `Decimal` to a localized string.
	///
	/// - Parameter price: The price that should be converted to a localized string.
	///
	/// - Returns: The localized string of the price or the price only as a string.
	fileprivate func formattedToLocale(price: Decimal) -> String {
		let currencySymbol = String(displayPrice.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789.,")) == nil }).trimmingCharacters(in: .whitespacesAndNewlines)
		return currencySymbol + "\(price)"
	}

	/// Returns a string of the percentage saved compared to the given price.
	///
	/// For example with a product that costs 1.99:
	/// ```
	/// product.priceSaved(comparedTo: 3.99)
	/// // Returns "50%"
	/// ```
	///
	/// - Parameter price: The price by which the comparision is done.
	///
	/// - Returns: a string of the percentage saved compared to the given price.
	func priceSaved(comparedTo price: Decimal) -> String {
		let percentageSaved = NSDecimalNumber(decimal: 100 - (100 / price * self.pricePerMonth))
		let behavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
		return percentageSaved.rounding(accordingToBehavior: behavior).stringValue + "%"
	}
}

// MARK: - SubscriptionPeriod
extension Product.SubscriptionPeriod {
	// MARK: - Properties
	/// Returns the unit as a string in pluralized form if required.
	var unitString: String {
		let plural = 1 < value
		switch unit {
		case .day:
			return plural ? "\(value) days" : "day"
		case .week:
			return plural ? "\(value) weeks" : "week"
		case .month:
			return plural ? "\(value) months" : "month"
		case .year:
			return plural ? "\(value) years" : "year"
		@unknown default:
			return "period"
		}
	}

	/// Returns the localized unit of the subscription.
	var displayUnit: String {
		let plural = 1 < value
		switch unit {
		case .year:
			return plural ? unitString : "12 months"
		default:
			return plural ? unitString : "a \(unitString)"
		}
	}

	/// Returns the localized unit of the subscription in a shorter format.
	var shortDisplayUnit: String {
		let plural = 1 < value
		switch unit {
		case .year:
			return plural ? "\(value)y" : "y"
		case .month:
			return plural ? "\(value)m" : "m"
		case .week:
			return plural ? "\(value)w" : "w"
		case .day:
			return plural ? "\(value)d" : "d"
		default:
			return unitString
		}
	}
}
