//
//  VoteThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a single thread/reply vote, such as the vote's status.
*/
public class VoteThread: JSONDecodable {
	// MARK: - Properties
	/// The vote status of a thread/reply.
	public let voteStatus: VoteStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.voteStatus = VoteStatus(rawValue: json["action"].intValue)
	}
}
