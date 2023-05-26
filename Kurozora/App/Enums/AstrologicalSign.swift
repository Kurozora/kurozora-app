//
//  AstrologicalSign.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum AstrologicalSign: Int, CaseIterable {
	// MARK: - Cases
	case aries = 0
	case taurus = 1
	case gemini = 2
	case cancer = 3
	case leo = 4
	case virgo = 5
	case libra = 6
	case scorpio = 7
	case sagittarius = 8
	case capricorn = 9
	case aquarius = 10
	case pisces = 11

	// MARK: - Propreties
	/// The title of an astrological sign.
	var title: String {
		switch self {
		case .aries:
			return "Aries"
		case .taurus:
			return "Taurus"
		case .gemini:
			return "Gemini"
		case .cancer:
			return "Cancer"
		case .leo:
			return "Leo"
		case .virgo:
			return "Virgo"
		case .libra:
			return "Libra"
		case .scorpio:
			return "Scorpio"
		case .sagittarius:
			return "Sagittarius"
		case .capricorn:
			return "Capricorn"
		case .aquarius:
			return "Aquarius"
		case .pisces:
			return "Pisces"
		}
	}

	/// The corresponding emoji of an astrological sign.
	var emoji: String {
		switch self {
		case .aries:
			return "♈️"
		case .taurus:
			return "♉️"
		case .gemini:
			return "♊️"
		case .cancer:
			return "♋️"
		case .leo:
			return "♌️"
		case .virgo:
			return "♍️"
		case .libra:
			return "♎️"
		case .scorpio:
			return "♏️"
		case .sagittarius:
			return "♐️"
		case .capricorn:
			return "♑️"
		case .aquarius:
			return "♒️"
		case .pisces:
			return "♓️"
		}
	}
}
