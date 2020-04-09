//
//  VoteStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	List of vote status.

	```
	case downVote = -1
	case noVote = 0
	case upVote = 1
	```
*/
public enum VoteStatus: Int {
	// MARK: - Cases
	case downVote = -1
	case noVote = 0
	case upVote = 1
}
