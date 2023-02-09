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
		/// The Apple Music id of the song.
		public let amID: Int?

		/// The MyAnimeList id of the song.
		public let malID: Int?

		/// The video url of the song.
		public let videoUrl: String?

		/// The title of the song.
		public let title: String

		/// The artist of the song.
		public let artist: String
	}
}
