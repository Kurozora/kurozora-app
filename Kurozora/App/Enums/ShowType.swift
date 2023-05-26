//
//  ShowType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum ShowType: Int, CaseIterable {
	// MARK: - Cases
	case Unknown = 1
	case TV = 2
	case OVA = 3
	case Movie = 4
	case Special = 5
	case ONA = 6
	case Music = 7

	// MARK: - Properties
	/// The name value of a show type.
	var name: String {
		switch self {
		case .Unknown:
			return "Unknown"
		case .TV:
			return "TV"
		case .OVA:
			return "OVA"
		case .Movie:
			return "Movie"
		case .Special:
			return "Special"
		case .ONA:
			return "ONA"
		case .Music:
			return "Music"
		}
	}
}
