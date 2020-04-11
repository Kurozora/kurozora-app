//
//  BadgeElement.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a single badge, such as the badge's name, description, and text color.
*/
public class BadgeElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the badge.
	public let id: Int?

	/// The name of the badge.
	public let text: String?

	/// The description of the badge.
	public let description: String?

	/// The text color of th badge.
	public let textColor: String?

	/// The background color of the badge.
	public let backgroundColor: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.text = json["text"].stringValue
		self.description = json["description"].stringValue
		self.textColor = json["textColor"].stringValue
		self.backgroundColor = json["backgroundColor"].stringValue
	}
}
