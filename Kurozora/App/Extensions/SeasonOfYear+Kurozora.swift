//
//  SeasonOfYear+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SeasonOfYear {
	// MARK: - Properties
	/// The localized name of the season.
	var name: String {
		switch self {
		case .winter:
			return L10n.winter
		case .spring:
			return L10n.spring
		case .summer:
			return L10n.summer
		case .fall:
			return L10n.fall
		}
	}

	/// The image representing the season.
	var image: UIImage? {
		switch self {
		case .winter:
			return UIImage(systemName: "snowflake")
		case .spring:
			return UIImage(systemName: "leaf.fill")
		case .summer:
			return UIImage(systemName: "sun.max.fill")
		case .fall:
			return UIImage(systemName: "wind")
		}
	}

	// MARK: - Initializers
	/// Creates the season corresponding to the given date.
	///
	/// - Parameter date: The date to derive the season from.
	init(from date: Date) {
		let month = Calendar.current.component(.month, from: date)

		switch month {
		case 1...3:
			self = .winter
		case 4...6:
			self = .spring
		case 7...9:
			self = .summer
		default:
			self = .fall
		}
	}

	/// Creates the season corresponding to the given URL path component.
	///
	/// - Parameter pathComponent: The path component to match, such as `"winter"`, `"spring"`, `"summer"`, or `"fall"`.
	init?(pathComponent: String) {
		switch pathComponent.lowercased() {
		case "winter":
			self = .winter
		case "spring":
			self = .spring
		case "summer":
			self = .summer
		case "fall":
			self = .fall
		default:
			return nil
		}
	}

	// MARK: - Functions
	/// Returns the year and season corresponding to the given date.
	///
	/// - Parameter date: The date to derive the year and season from.
	///
	/// - Returns: A tuple containing the year and season.
	static func yearAndSeason(from date: Date) -> (year: Int, season: SeasonOfYear) {
		return (Calendar.current.component(.year, from: date), SeasonOfYear(from: date))
	}
}
