//
//  Month.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

enum Month: Int, CaseIterable {
	// MARK: - Cases
	case january = 1
	case february = 2
	case march = 3
	case april = 4
	case may = 5
	case june = 6
	case july = 7
	case august = 8
	case september = 9
	case october = 10
	case november = 11
	case december = 12

	// MARK: - Properties
	/// The name value of a month.
	var name: String {
		switch self {
		case .january:
			return "January"
		case .february:
			return "February"
		case .march:
			return "March"
		case .april:
			return "April"
		case .may:
			return "May"
		case .june:
			return "June"
		case .july:
			return "July"
		case .august:
			return "August"
		case .september:
			return "September"
		case .october:
			return "October"
		case .november:
			return "November"
		case .december:
			return "December"
		}
	}

	/// The next month.
	var next: Month {
		switch self {
		case .january:
			return .february
		case .february:
			return .march
		case .march:
			return .april
		case .april:
			return .may
		case .may:
			return .june
		case .june:
			return .july
		case .july:
			return .august
		case .august:
			return .september
		case .september:
			return .october
		case .october:
			return .november
		case .november:
			return .december
		case .december:
			return .january
		}
	}

	/// The previous month.
	var previous: Month {
		switch self {
		case .january:
			return .december
		case .february:
			return .january
		case .march:
			return .february
		case .april:
			return .march
		case .may:
			return .april
		case .june:
			return .may
		case .july:
			return .june
		case .august:
			return .july
		case .september:
			return .august
		case .october:
			return .september
		case .november:
			return .october
		case .december:
			return .november
		}
	}
}
