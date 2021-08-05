//
//  SeasonAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Season {
	/**
		A root object that stores information about a single season, such as the season's title, number, and episodes count.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The link to a poster of the season.
		public let poster: Media?

		/// The number of the season.
		public let number: Int

		/// The title of the season.
		public let title: String

		/// The synopsis of the season.
		public let synopsis: String?

		/// The episode count of the season.
		public let episodeCount: Int

		/// The premiere date of the season.
		public let firstAired: Date?
	}
}
