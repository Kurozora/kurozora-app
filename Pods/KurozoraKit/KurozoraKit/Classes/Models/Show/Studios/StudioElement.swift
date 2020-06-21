//
//  StudioElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single studio, such as the studios's name, logo, and date founded.
*/
public class StudioElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the studio.
	public let id: Int?

	/// The name of the studio.
	public let name: String?

	/// The logo of the studio.
	public let logo: String?

	/// The about text of the studio.
	public let about: String?

	/// The date the studio was founded.
	public let founded: String?

	/// The link to the website of the studio.
	public let websiteURL: String?

	// MARK: - Initializers
	/// Initializes an empty instance of `StudioElement`
	internal init() {
		self.id = nil
		self.name = nil
		self.logo = nil
		self.about = nil
		self.founded = nil
		self.websiteURL = nil
	}

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.logo = json["logo"].stringValue
		self.about = json["about"].stringValue
		self.founded = json["founded"].string
		self.websiteURL = json["website_url"].string
	}
}
