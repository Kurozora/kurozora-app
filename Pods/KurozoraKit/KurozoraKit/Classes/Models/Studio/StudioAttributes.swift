//
//  StudioAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

extension Studio {
	/// A root object that stores information about a single studio, such as the studios's name, logo, and date founded.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The slug of the studio.
		public let slug: String

		/// The profile image of the studio.
		public let profile: Media?

		/// The banner image of the studio.
		public let banner: Media?

		/// The logo of the studio.
		public let logo: Media?

		/// The name of the studio.
		public let name: String

		/// The Japanese name of the studio.
		public let japaneseName: String?

		/// The alternative names of the studio.
		public let alternativeNames: [String]?

		/// The predecessor names of the studio.
		public let predecessors: [String]

		/// The successor of the studio.
		public let successor: String?

		/// The about text of the studio.
		public let about: String?

		/// The address of the studio.
		public let address: String?

		/// The tv rating of the studio.
		public let tvRating: TVRating

		/// The stats of the studio.
		public let stats: MediaStat?

		/// The link to the website of the studio.
		public let socialURLs: [String]?

		/// The link to the website of the studio.
		public let websiteURLs: [String]?

		/// Whether the studio is the producer of an anime.
		public let isProducer: Bool?

		/// Whether the studio is the studio of an anime.
		public let isStudio: Bool?

		/// Whether the studio is the licensor of an anime.
		public let isLicensor: Bool?

		/// Whether the studio is NSFW.
		public let isNSFW: Bool

		/// The date the studio was founded.
		public let foundedAt: Date?

		/// The date the studio was defunct.
		public let defunctAt: Date?

		/// The library attributes of the song.
		public var library: LibraryAttributes?
	}
}
