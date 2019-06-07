//
//  AlternativeIcons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class AlternativeIcons: JSONDecodable {
	let defaultIcons: [AlternativeIconsElement]?
	let premiumIcons: [AlternativeIconsElement]?
	let limitedIcons: [AlternativeIconsElement]?

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
		print("dionnnnnsssssserrrrrr")
	}
}

class AlternativeIconsElement: JSONDecodable {
	let name: String?
	let image: String?

	required init(json: JSON) throws {
		self.name = json["name"].stringValue
		self.image = json["image"].stringValue
	}
}
