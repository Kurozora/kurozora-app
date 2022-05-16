//
//  AppThemeAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension AppTheme {
	/// A root object that stores information about a single app theme, such as the app theme's name, download count, and download link.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The link to a screenshot of the app theme.
		public let screenshots: [Media]

		/// The name of the app theme.
		public let name: String

		/// The current version of the app theme.
		public let version: String

		/// The download count of the app theme.
		public let downloadCount: Int

		/// The download link of the app theme.
		public let downloadLink: String

//		/// The current user's information regarding the app theme.
//		public let currentUser: UserProfile?
	}
}
