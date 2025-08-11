//
//  Int+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

private struct StaticData {
	static let shortSuffixes = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qat", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg", "Uvg"]

	static let groupingSeparator: String = Locale.current.groupingSeparator ?? ","
	static let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
}

extension Int {
	/// String formatted values properly displaying huge numbers.
	///
	/// Units: Thousand (K), Million (M), Billion (B), Trillion (T), Quadrillion (Qa), Quintillion (Qi), Sextillion (Sx), Septillion (Sp), Octillion (Oc), Nonillion (No), Decillion (Dc), Undecillion (Ud), Duodecillion (Dd), Tredecillion (Td), Quattuordecillion (Qat), Quinquadecillion (Qid), Sexdecillion (Sxd), Septendecillion (Spd), Octodecillion (Ocd), Novendecillion (Nod), Vigintillion(Vg), Vunvigintillion (Uvg)
	///
	/// - Parameters:
	///    - precision: The number of decimal places to keep (default is 3).
	///
	/// - Returns: A formatted string representing the number with the specified precision and suffix.
	func kkFormatted(precision: Int = 3) -> String {
		// Clamp index to valid range
		let index = Swift.max(0, Swift.min(StaticData.shortSuffixes.count - 1,
							   Int(log(Double(self)) / log(1000))))

		let scaledNumber = Double(self) / pow(1000, Double(index))

		// Manual rounding
		let multiplier = pow(10.0, Double(precision))
		let roundedValue = (scaledNumber * multiplier).rounded() / multiplier

		// Convert to string with fixed precision
		var numberString = String(format: "%.\(precision)f", roundedValue)

		// Trim trailing zeros and decimal point
		if let dotIndex = numberString.firstIndex(of: ".") {
			var end = numberString.index(before: numberString.endIndex)
			while end > dotIndex && numberString[end] == "0" {
				end = numberString.index(before: end)
			}
			if numberString[end] == "." {
				end = numberString.index(before: end)
			}
			numberString = String(numberString[..<numberString.index(after: end)])
		}

		// Apply locale grouping
		if let dotIndex = numberString.firstIndex(of: ".") {
			let integerPart = String(numberString[..<dotIndex])
			let decimalPart = String(numberString[numberString.index(after: dotIndex)...])
			numberString = insertGrouping(intPart: integerPart) + StaticData.decimalSeparator + decimalPart
		} else {
			numberString = insertGrouping(intPart: numberString)
		}

		let suffix = StaticData.shortSuffixes[index]

		return numberString + suffix
	}

	// Helper for grouping thousands without NumberFormatter
	@inline(__always)
	private func insertGrouping(intPart: String) -> String {
		let chars = Array(intPart)
		var grouped: [Character] = []
		var count = 0
		for char in chars.reversed() {
			if count != 0 && count % 3 == 0 {
				grouped.append(Character(Locale.current.groupingSeparator ?? ","))
			}
			grouped.append(char)
			count += 1
		}
		return String(grouped.reversed())
	}
}
