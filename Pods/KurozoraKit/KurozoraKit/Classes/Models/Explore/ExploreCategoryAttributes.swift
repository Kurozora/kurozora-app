//
//  ExploreCategoryAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension ExploreCategory {
	/// A root object that stores information about a single explore category, such as the category's title, size, and type.
	public struct Attributes: Codable, Sendable {
		// MARK: - Properties
		/// The slug of the resource.
		public let slug: String

		/// The title of the explore category.
		public let title: String

		/// The description of the explore category.
		public let description: String?

		/// The position of the explore category.
		public let position: Int

		/// The type of the explore category.
		public let type: String

		/// The size of the explore category.
		public let size: String
	}
}

// MARK: - Helpers
extension ExploreCategory.Attributes {
	/// The size of the explore category.
	public var exploreCategorySize: ExploreCategorySize {
		return ExploreCategorySize(rawValue: self.size) ?? .small
	}

	/// The type of the explore category.
	public var exploreCategoryType: ExploreCategoryType {
		return ExploreCategoryType(rawValue: self.type) ?? .shows
	}
}
