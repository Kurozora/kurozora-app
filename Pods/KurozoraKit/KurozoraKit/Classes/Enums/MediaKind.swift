//
//  MediaKind.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/04/2024.
//

/// The set of available media kinds.
///
/// - `episodes`: the media is of the `episodes` kind.
/// - `games`: the media is of the `games` kind.
/// - `literatures`: the media is of the `literatures` kind.
/// - `shows`: the media is of the `shows` kind.
///
/// - Tag: MediaKind
public enum MediaKind: String {
	// MARK: - Cases
	/// Indicates the media is of the `episodes` kind.
	///
	/// - Tag: MediaKind-episodes
	case episodes

	/// Indicates the media is of the `games` kind.
	///
	/// - Tag: MediaKind-games
	case games

	/// Indicates the media is of the `literatures` kind.
	///
	/// - Tag: MediaKind-literatures
	case literatures

	/// Indicates the media is of the `shows` kind.
	///
	/// - Tag: MediaKind-shows
	case shows

	// MARK: - Properties
	/// The string value of a media kind.
	///
	/// - Tag: MediaKind-stringValue
	public var stringValue: String {
		switch self {
		case .episodes:
			return "Episodes"
		case .games:
			return "Games"
		case .literatures:
			return "Literatures"
		case .shows:
			return "Shows"
		}
	}
}
