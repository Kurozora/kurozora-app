//
//  SongType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2022.
//

///  List of available song types.
///
/// - Tag: SongType
public enum SongType: Int, CaseIterable, Codable {
	// MARK: - Cases
	/// Indicates that the song is of the `opening` type.
	case opening = 0

	/// Indicates that the song is of the `ending` type.
	case ending = 1

	/// Indicates that the song is of the `background` type.
	case background = 2

	// MARK: - Functions
	/// The string value of the song type.
	public var stringValue: String {
		switch self {
		case .opening:
			return "Opening"
		case .ending:
			return "Ending"
		case .background:
			return "Background"
		}
	}

	/// The abbreviated string of the song type.
	public var abbreviatedStringValue: String {
		switch self {
		case .opening:
			return "OP"
		case .ending:
			return "ED"
		case .background:
			return "BG"
		}
	}

	/// The background color of the song type.
	public var backgroundColorValue: UIColor {
		switch self {
		case .opening:
			return .systemBlue
		case .ending:
			return .systemRed
		case .background:
			return .systemYellow
		}
	}
}
