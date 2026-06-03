//
//  Int+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension Int {
	/// A locale-aware, compact string for large numbers.
	///
	/// Uses the system compact notation so scaling follows the current locale —
	/// `12K` in English, `1.2万` in Japanese, `12 тыс.` in Russian.
	///
	/// - Parameter precision: The maximum number of fractional digits to keep (default is 3).
	///
	/// - Returns: The number formatted with compact notation in the current locale.
	func kkFormatted(precision: Int = 3) -> String {
		return self.formatted(
			.number
			.notation(.compactName)
			.precision(.fractionLength(0...precision))
		)
	}
}
