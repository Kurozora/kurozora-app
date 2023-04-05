//
//  ThemeAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Theme {
	/// A root object that stores information about a single theme, such as the theme's name, color, and symbol.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The slug of the resource.
		public let slug: String

		/// The name of the theme.
		public let name: String

		/// The description of the theme.
		public let description: String?

		/// The first background color of the theme.
		public let backgroundColor1: String

		/// The second background color of the theme.
		public let backgroundColor2: String

		/// The first text color of the theme.
		public let textColor1: String

		/// The second text color of the theme.
		public let textColor2: String

		/// The media object of the symbol of the theme.
		public let symbol: Media?

		/// Whether the theme is Not Safe For Work.
		public let isNSFW: Bool
	}
}
