//
//  ThemeElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single theme, such as the theme's name, download count, and download link.
*/
public class ThemeElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the theme.
	public let id: Int?

	/// The name of the theme.
	public let name: String?

	/// The background color of the theme.
	public let backgroundColor: String?

	/// The download count of the theme.
	public let downloadCount: Int?

	/// The download link of the theme.
	public let downloadLink: String?

	/// The current user's information regarding the theme.
	public let currentUser: UserProfile?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.backgroundColor = json["color"].stringValue
		self.downloadCount = json["download_count"].intValue
		self.downloadLink = json["download_link"].stringValue
		self.currentUser = try? UserProfile(json: json["current_user"])
	}
}
