//
//  SeasonOfYear.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

enum SeasonOfYear: Int, CaseIterable {
	// MARK: - Cases
	case winter = 0
	case spring = 1
	case summer = 2
	case fall = 3

	// MARK: - Properties
	/// The name value of a season.
	var name: String {
		switch self {
		case .winter:
			return "Winter"
		case .spring:
			return "Spring"
		case .summer:
			return "Summer"
		case .fall:
			return "Fall"
		}
	}

	/// The image value of a season.
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
}
