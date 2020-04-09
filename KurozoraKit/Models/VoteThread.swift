//
//  VoteThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class VoteThread: JSONDecodable {
	// MARK: - Properties
	internal let success: Bool?
	public let voteStatus: VoteStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.voteStatus = VoteStatus(rawValue: json["action"].intValue)
	}
}
