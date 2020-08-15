//
//  StudioAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

extension Studio {
	/**
		A root object that stores information about a single studio, such as the studios's name, logo, and date founded.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The name of the studio.
		public let name: String

		/// The logo of the studio.
		public let logo: String?

		/// The about text of the studio.
		public let about: String?

		/// The date the studio was founded.
		public let founded: String?

		/// The link to the website of the studio.
		public let websiteURL: String?
	}
}
