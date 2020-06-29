//
//  CastRole.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/06/2020.
//

import Foundation

/**
	The set of available enums for cast role.

	- Tag: CastRole
*/
public enum CastRole: Int, CaseIterable {
	// MARK: - Cases
	/// The cast is the protagonist of the show.
	case Protagonist = 0

	/// The cast is the deuteragonist of the show.
	case Deuteragonist = 1

	/// The cast is the tritagonist of the show.
	case Tritagonist = 2

	/// The cast is the supporting character of the show.
	case SupportingCharacter = 3

	/// The cast is the antagonist of the show.
	case Antagonist = 4

	/// The cast is the antihero of the show.
	case Antihero = 5

	/// The cast is the archenemy of the show.
	case Archenemy = 6

	/// The cast is the focal character of the show.
	case FocalCharacter = 7

	/// The cast is the foil of the show.
	case Foil = 8

	/// The cast is the narrator of the show.
	case Narrator = 9

	/// The cast is the title character of the show.
	case TitleCharacter = 10

	// MARK: - Properties
	/// The string value of a cast role type.
	public var stringValue: String {
		switch self {
		case .Protagonist:
			return "Protagonist"
		case .Deuteragonist:
			return "Deuteragonist"
		case .Tritagonist:
			return "Tritagonist"
		case .SupportingCharacter:
			return "Supporting Character"
		case .Antagonist:
			return "Antagonist"
		case .Antihero:
			return "Antihero"
		case .Archenemy:
			return "Archenemy"
		case .FocalCharacter:
			return "Focal Character"
		case .Foil:
			return "Foil"
		case .Narrator:
			return "Narrator"
		case .TitleCharacter:
			return "Title Character"
		}
	}
}
