//
//  SongAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

extension Song {
	/// A root object that stores information about a single song, such as the song's title, artist, and video url.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The Amazon Music id of the song.
		public let amazonID: String?

		/// The Apple Music id of the song.
		public let amID: Int?

		/// The Deezer id of the song.
		public let deezerID: Int?

		/// The MyAnimeList id of the song.
		public let malID: Int?

		/// The Spotify id of the song.
		public let spotifyID: String?

		/// The YoutTube id of the song.
		public let youtubeID: String?

		/// The link to a artwork image of the song.
		public let artwork: Media?

		/// The title of the song.
		public let title: String

		/// The artist of the song.
		public let artist: String

		/// The stats of the song.
		public let stats: MediaStat?
	}
}
