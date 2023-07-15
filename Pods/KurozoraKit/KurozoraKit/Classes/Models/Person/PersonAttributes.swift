//
//  PersonAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Person {
	/// A root object that stores information about a single person, such as the person's name, role, and image.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The slug of the person.
		public let slug: String

		/// The link to a profile image of the person.
		public let profile: Media?

		/// The full name of the person.
		public let fullName: String

		/// The full given name of the person. Usually in Japanese.
		public let fullGivenName: String?

		/// The other names the person is also known by.
		public let alternativeNames: [String]?

		/// The age of the person.
		public let age: String?

		/// The birthdate of the person.
		public let birthdate: Date?

		/// The deceased date of the person.
		public let deceasedDate: Date?

		/// The biogrpahy of the person.
		public let about: String?

		/// The short description of the person.
		public let shortDescription: String?

		/// The link to the website of the person.
		public let websiteURLs: [String]?

		/// The astrological sign of the person.
		public let astrologicalSign: String?
	}
}
