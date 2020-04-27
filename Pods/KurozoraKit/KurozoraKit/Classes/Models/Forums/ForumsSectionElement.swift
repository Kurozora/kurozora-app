//
//  ForumsSectionElement.swift
//  Alamofire
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single feed section, such as the sections's name, and lock status.
*/
public class ForumsSectionElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the forums section.
	public let id: Int?

	/// The name of the forums section.
	public let name: String?

	/// The lock status of the forums section.
	public let lockStatus: LockStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.lockStatus = LockStatus(rawValue: json["locked"].intValue)
	}
}
