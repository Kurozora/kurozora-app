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

	// MARK: - Properties
	/// The title of an astrological sign.
	var title: String {
		switch self {
		case .aries:
			return L10n.aries
		case .taurus:
			return L10n.taurus
		case .gemini:
			return L10n.gemini
		case .cancer:
			return L10n.cancer
		case .leo:
			return L10n.leo
		case .virgo:
			return L10n.virgo
		case .libra:
			return L10n.libra
		case .scorpio:
			return L10n.scorpio
		case .sagittarius:
			return L10n.sagittarius
		case .capricorn:
			return L10n.capricorn
		case .aquarius:
			return L10n.aquarius
		case .pisces:
			return L10n.pisces
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
