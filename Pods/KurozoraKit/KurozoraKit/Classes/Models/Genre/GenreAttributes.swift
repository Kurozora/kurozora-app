//
//  GenreAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Genre {
	/// A root object that stores information about a single genre, such as the genre's name, color, and symbol.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The slug of the resource.
		public let slug: String

		/// The name of the genre.
		public let name: String

		/// The description of the genre.
		public let description: String?

		/// The first background color of the genre.
		public let backgroundColor1: String

		/// The second background color of the genre.
		public let backgroundColor2: String

		/// The first text color of the genre.
		public let textColor1: String

		/// The second text color of the genre.
		public let textColor2: String

		/// The media object of the symbol of the genre.
		public let symbol: Media?

		/// Whether the genre is Not Safe For Work.
		public let isNSFW: Bool
	}
}
