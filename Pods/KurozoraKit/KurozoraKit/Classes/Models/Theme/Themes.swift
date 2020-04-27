//
//  Themes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of themes.
*/
public class Themes: JSONDecodable {
	// MARK: - Properties
	/// The collection of themes.
	public let themes: [ThemeElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		var themes = [ThemeElement]()

		let themesArray = json["themes"].arrayValue
		for themeItem in themesArray {
			if let themeElement = try? ThemeElement(json: themeItem) {
				themes.append(themeElement)
			}
		}

		self.themes = themes
	}
}
