//
//  AstrologicalSign.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020.
//

import Foundation

/**
	The set of available enums for character astrological signs.

	- Tag: AstrologicalSign
*/
public enum AstrologicalSign: Int, CaseIterable {
	// MARK: - Cases
	/// The character has the Aries sign.
	case aries = 0

	/// The character has the Taurus sign.
	case taurus = 1

	/// The character has the Gemini sign.
	case gemini = 2

	/// The character has the Cancer sign.
	case cancer = 3

	/// The character has the Leo sign.
	case leo = 4

	/// The character has the Virgo sign.
	case virgo = 5

	/// The character has the Libra sign.
	case libra = 6

	/// The character has the Scorpio sign.
	case scorpio = 7

	/// The character has the Sagittarius sign.
	case sagittarius = 8

	/// The character has the Capricorn sign.
	case capricorn = 9

	/// The character has the Aquarius sign.
	case aquarius = 10

	/// The character has the Pisces sign.
	case pisces = 11

	// MARK: - Properties
	/// The string value fo an astrological sign.
	public var stringValue: String {
		switch self {
		case .aries:
			return "Aries ♈️"
		case .taurus:
			return "Taurus ♉️"
		case .gemini:
			return "Gemini ♊️"
		case .cancer:
			return "Cancer ♋️"
		case .leo:
			return "Leo ♌️"
		case .virgo:
			return "Virgo ♍️"
		case .libra:
			return "Libra ♎️"
		case .scorpio:
			return "Scorpio ♏️"
		case .sagittarius:
			return "Sagittarius ♐️"
		case .capricorn:
			return "Capricorn ♑️"
		case .aquarius:
			return "Aquarius ♒️"
		case .pisces:
			return "Pisces ♓️"
		}
	}
}
