//
//  MediaCollection.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/04/2024.
//

/// The set of available media collections.
///
/// - `artwork`: the collection is of the `artwork` type.
/// - `banner`: the collection is of the `banner` type.
/// - `logo`: the collection is of the `logo` type.
/// - `poster`: the collection is of the `poster` type.
/// - `profile`: the collection is of the `profile` type.
/// - `screenshot`: the collection is of the `screenshot` type.
/// - `symbol`: the collection is of the `symbol` type.
///
/// - Tag: MediaCollection
public enum MediaCollection: String {
	// MARK: - Cases
	/// Indicates the collection is of the `artwork` type.
	///
	/// - Tag: MediaCollection-artwork
	case artwork

	/// Indicates the collection is of the `banner` type.
	///
	/// - Tag: MediaCollection-banner
	case banner

	/// Indicates the collection is of the `logo` type.
	///
	/// - Tag: MediaCollection-logo
	case logo

	/// Indicates the collection is of the `poster` type.
	///
	/// - Tag: MediaCollection-poster
	case poster

	/// Indicates the collection is of the `profile` type.
	///
	/// - Tag: MediaCollection-profile
	case profile

	/// Indicates the collection is of the `screenshot` type.
	///
	/// - Tag: MediaCollection-screenshot
	case screenshot

	/// Indicates the collection is of the `symbol` type.
	///
	/// - Tag: MediaCollection-symbol
	case symbol

	// MARK: - Properties
	/// The string value of a media collection.
	///
	/// - Tag: MediaCollection-stringValue
	public var stringValue: String {
		switch self {
		case .artwork:
			return "Artwork"
		case .banner:
			return "Banner"
		case .logo:
			return "Logo"
		case .poster:
			return "Poster"
		case .profile:
			return "Profile"
		case .screenshot:
			return "Screenshot"
		case .symbol:
			return "Symbol"
		}
	}
}
