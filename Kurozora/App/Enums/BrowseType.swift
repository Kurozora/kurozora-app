//
//  BrowseType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

enum BrowseType: Int {
	// MARK: - Cases
	case topAnime = 0
	case topAiring
	case topUpcoming
	case topTVSeries
	case topMovies
	case topOVA
	case topSpecials
	case justAdded
	case mostPopular
	case advancedSearch

	// MARK: - Properties
	/// An array containing all browse types.
	static let all: [BrowseType] = [.topAnime, .topAiring, .topUpcoming, .topTVSeries, .topMovies, .topOVA, .topSpecials, .justAdded, .mostPopular, .advancedSearch]

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
			return L10n.topAnime
		case .topAiring:
			return L10n.topAiring
		case .topUpcoming:
			return L10n.topUpcoming
		case .topTVSeries:
			return L10n.topTVSeries
		case .topMovies:
			return L10n.topMovies
		case .topOVA:
			return L10n.topOVA
		case .topSpecials:
			return L10n.topSpecials
		case .justAdded:
			return L10n.justAdded
		case .mostPopular:
			return L10n.mostPopular
		case .advancedSearch:
			return L10n.advancedSearch
		}
	}
}
