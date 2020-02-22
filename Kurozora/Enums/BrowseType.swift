//
//  BrowseType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

enum BrowseType: Int {
	case topAnime = 0
	case topAiring
	case topUpcoming
	case topTVSeries
	case topMovies
	case topOVA
	case topSpecials
	case justAdded
	case mostPopular
	case filtering

	// MARK: - Properties
	/// An array containing all browse types.
	static let all: [BrowseType] = [.topAnime, .topAiring, .topUpcoming, .topTVSeries, .topMovies, .topOVA, .topSpecials, .justAdded, .mostPopular, .filtering]

	/// An array containing the string value of all browse types.
	static var allString: [String] {
		var allString: [String] = []
		for scope in all {
			allString.append(scope.stringValue)
		}
		return allString
	}

	/// The string value of a browse type.
	var stringValue: String {
		switch self {
		case .topAnime:
			return "Top Anime"
		case .topAiring:
			return "Top Airing"
		case .topUpcoming:
			return "Top Upcoming"
		case .topTVSeries:
			return "Top TV Series"
		case .topMovies:
			return "Top Movies"
		case .topOVA:
			return "Top OVA"
		case .topSpecials:
			return "Top Specials"
		case .justAdded:
			return "Just Added"
		case .mostPopular:
			return "Most Popular"
		case .filtering:
			return "Advanced Search"
		}
	}
}
