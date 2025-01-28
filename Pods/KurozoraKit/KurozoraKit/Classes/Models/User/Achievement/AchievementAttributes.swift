//
//  AchievementAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Achievement {
	/// A root object that stores information about a single achievement, such as the achievement's name, description, and color.
	public struct Attributes: Codable, Sendable {
		// MARK: - Properties
		/// The name of the achievement.
		public let name: String

		/// The description of the achievement.
		public let description: String

		/// The text color of th achievement.
		public let textColor: String

		/// The background color of the achievement.
		public let backgroundColor: String

		/// The media object of the symbol of the achievement.
		public let symbol: Media?
	}
}
