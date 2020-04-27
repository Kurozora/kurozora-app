//
//  UserNotificationElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single notification, such as the notification's type, read status, and containing data.
*/
public class UserNotificationElement: JSONDecodable {
	// MARK: - Properties
	/// The id of a notification.
	public let id: String?

	/// The type of a notification.
	public let type: String?

	/// The read status of a notification.
	public var readStatus: ReadStatus?

	/// The data of the notification.
	public let data: UserNotificationData?

	/// The message of the notification.
	public let message: String?

	/// The creation date of the notification.
	public let creationDate: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].stringValue
		self.type = json["type"].stringValue
		self.readStatus = ReadStatus(from: json["read"].boolValue)
		self.data = try? UserNotificationData(json: json["data"])
		self.message = json["string"].stringValue
		self.creationDate = json["creation_date"].stringValue
	}
}
