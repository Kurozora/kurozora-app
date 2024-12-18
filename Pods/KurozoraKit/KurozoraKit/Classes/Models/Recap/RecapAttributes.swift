//
//  RecapAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/01/2024.
//

extension Recap {
	/// A root object that stores information about a single recap, such as the recap's year, and description.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The year of the recap.
		public let year: Int

		/// The month of the recap.
		public let month: Int

		/// The description of the recap.
		public let description: String?

		/// The first background color of the genre.
		public let backgroundColor1: String

		/// The second background color of the genre.
		public let backgroundColor2: String

		/// The media object of the symbol of the genre.
		public let artwork: Media?
	}
}
