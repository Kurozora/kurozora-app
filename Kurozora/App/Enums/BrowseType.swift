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
			return Trans.topAnime
		case .topAiring:
			return Trans.topAiring
		case .topUpcoming:
			return Trans.topUpcoming
		case .topTVSeries:
			return Trans.topTVSeries
		case .topMovies:
			return Trans.topMovies
		case .topOVA:
			return Trans.topOVA
		case .topSpecials:
			return Trans.topSpecials
		case .justAdded:
			return Trans.justAdded
		case .mostPopular:
			return Trans.mostPopular
		case .advancedSearch:
			return Trans.advancedSearch
		}
	}
}
