//
//  Themes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class Themes: JSONDecodable {
	public let success: Bool?
	public let themes: [ThemesElement]?

	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		var themes = [ThemesElement]()

		let themesArray = json["themes"].arrayValue
		for themeItem in themesArray {
			if let themeElement = try? ThemesElement(json: themeItem) {
				themes.append(themeElement)
			}
		}

		self.themes = themes
	}
}

public class ThemesElement: JSONDecodable {
	public let id: Int?
	public let name: String?
	public let backgroundColor: String?
	public let downloadCount: Int?
	public let downloadLink: String?
	public let currentUser: UserProfile?

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.backgroundColor = json["color"].stringValue
		self.downloadCount = json["download_count"].intValue
		self.downloadLink = json["download_link"].stringValue
		self.currentUser = try? UserProfile(json: json["current_user"])
	}
}
