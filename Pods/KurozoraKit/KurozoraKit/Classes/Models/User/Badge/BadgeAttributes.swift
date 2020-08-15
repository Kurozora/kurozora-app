//
//  BadgeAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Badge {
	/**
		A root object that stores information about a single badge, such as the badge's name, description, and color.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The name of the badge.
		public let name: String

		/// The description of the badge.
		public let description: String

		/// The text color of th badge.
		public let textColor: String

		/// The background color of the badge.
		public let backgroundColor: String
	}
}
