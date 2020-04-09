//
//  ThreadReply.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class ThreadReply: JSONDecodable {
	// MARK: - Properties
	internal let success: Bool?
	public let id: Int?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.id = json["reply_id"].intValue
	}
}
