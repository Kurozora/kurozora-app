//
//  BadgeElement.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class BadgeElement: JSONDecodable {
	public let id: Int?
	public let text: String?
	public let description: String?
	public let textColor: String?
	public let backgroundColor: String?

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.text = json["text"].stringValue
		self.description = json["description"].stringValue
		self.textColor = json["textColor"].stringValue
		self.backgroundColor = json["backgroundColor"].stringValue
	}
}
