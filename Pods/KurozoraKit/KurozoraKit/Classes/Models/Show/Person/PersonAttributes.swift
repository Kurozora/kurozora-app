//
//  PersonAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Person {
	/**
		A root object that stores information about a single person, such as the person's name, role, and image.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The first name of the person.
		public let firstName: String

		/// The last name of the person.
		public let lastName: String?

		/// The given name of the person. Usually in Japanese.
		public let givenName: String?

		/// The family name of the person. Usually in Japanese.
		public let familyName: String?

		/// The nicknames the person is also known by.
		public let nicknames: [String]?

		/// The biogrpahy of the person.
		public let about: String?

		/// The link to an image of the person.
		public let imageURL: String?

		/// The link to the website of the person.
		public let websiteURLs: [String]?
	}
}
