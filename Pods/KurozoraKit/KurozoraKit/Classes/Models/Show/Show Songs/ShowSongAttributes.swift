//
//  ShowSongAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

extension ShowSong {
	/**
		A root object that stores information about a single show, such as the show song's type, position, and episode debute.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The type of the show.
		public let type: SongType

		/// The adaptation source of the show.
		public let position: Int

		/// The number of episodes in the show.
		public let episodes: String
	}
}
