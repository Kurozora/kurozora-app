//
//  Themes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Themes: JSONDecodable {
	let success: Bool?
	let themes: [ThemesElement]?

	required init(json: JSON) throws {
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

class ThemesElement: JSONDecodable {
	let id: Int?
	let name: String?
	let downloadLink: String?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.downloadLink = json["download_link"].stringValue
	}
}
