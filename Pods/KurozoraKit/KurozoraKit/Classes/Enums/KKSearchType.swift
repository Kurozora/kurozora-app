//
//  KKSearchType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/05/2022.
//

/// The list of available search types.
///
/// - `characters`: the fetched resource should be of the `characters` type.
/// - `episodes`: the fetched resource should be of the `episodes` type.
/// - `games`: the fetched resource should be of the `games` type.
/// - `literature`: the fetched resource should be of the `literature` type.
/// - `people`: the fetched resource should be of the `people` type.
/// - `shows`: the fetched resource should be of the `shows` type.
/// - `songs`: the fetched resource should be of the `songs` type.
/// - `studios`: the fetched resource should be of the `studios` type.
/// - `users`: the fetched resource should be of the `users` type.
///
/// - Tag: KKSearchType
public enum KKSearchType: String {
	/// Indicates the fetched resource should be of the `characters` type.
	///
	/// - Tag: KKSearchType-characters
	case characters

	/// Indicates the fetched resource should be of the `episodes` type.
	///
	/// - Tag: KKSearchType-episodes
	case episodes

//	/// Indicates the fetched resource should be of the `games` type.
//	///
//	/// - Tag: KKSearchType-games
//	case games

//	/// Indicates the fetched resource should be of the `literature` type.
//	///
//	/// - Tag: KKSearchType-literature
//	case literature

	/// Indicates the fetched resource should be of the `people` type.
	///
	/// - Tag: KKSearchType-people
	case people

	/// Indicates the fetched resource should be of the `shows` type.
	///
	/// - Tag: KKSearchType-shows
	case shows

	/// Indicates the fetched resource should be of the `songs` type.
	///
	/// - Tag: KKSearchType-songs
	case songs

	/// Indicates the fetched resource should be of the `studios` type.
	///
	/// - Tag: KKSearchType-studios
	case studios

	/// Indicates the fetched resource should be of the `users` type.
	///
	/// - Tag: KKSearchType-users
	case users
}
