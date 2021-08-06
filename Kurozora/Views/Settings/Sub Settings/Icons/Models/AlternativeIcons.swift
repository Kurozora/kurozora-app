//
//  AlternativeIcons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of alternative icons, such as the different collections of icons.
*/
class AlternativeIcons: JSONDecodable {
	// MARK: - Properties
	/// The collection of default icons.
	let defaultIcons: [AlternativeIconsElement]?
	/// The collection of premium icons.
	let premiumIcons: [AlternativeIconsElement]?
	/// The collection of limited time icons.
	let limitedIcons: [AlternativeIconsElement]?

	// MARK: - Initializers
	required init(json: JSON) throws {
		let defaultIconsArray = json["Default"].arrayValue
		let premiumIconsArray = json["Premium"].arrayValue
		let limitedIconsArray = json["Limited"].arrayValue

		var defaultIcons = [AlternativeIconsElement]()
		var premiumIcons = [AlternativeIconsElement]()
		var limitedIcons = [AlternativeIconsElement]()

		for defaultIconItem in defaultIconsArray {
			if let alternativeIconElement = try? AlternativeIconsElement(json: defaultIconItem) {
				defaultIcons.append(alternativeIconElement)
			}
		}

		for premiumIconItem in premiumIconsArray {
			if let alternativeIconElement = try? AlternativeIconsElement(json: premiumIconItem) {
				premiumIcons.append(alternativeIconElement)
			}
		}

		for limitedIconItem in limitedIconsArray {
			if let alternativeIconElement = try? AlternativeIconsElement(json: limitedIconItem) {
				limitedIcons.append(alternativeIconElement)
			}
		}

		self.defaultIcons = defaultIcons
		self.premiumIcons = premiumIcons
		self.limitedIcons = limitedIcons
	}
}

/**
	A mutable object that stores information about a single alternative icon, such as the icon's name, and image string.
*/
class AlternativeIconsElement: JSONDecodable {
	// MARK: - Properties
	/// The name of the alternative icon.
	let name: String?
	/// The image string of the alternative icon.
	let image: String?

	// MARK: - Initializers
	required init(json: JSON) throws {
		self.name = json["name"].stringValue
		self.image = json["image"].stringValue
	}
}
