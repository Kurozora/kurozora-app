//
//  FeedType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of feeds the user can choose from to view posts shared by other users.

	```
	case Feed = 0
	case Popular = 1
	case Global = 2
	```
*/
enum FeedType: Int {
	/// Refers to the posts shared by the users followed by the current user.
	case Feed = 0

	/// Refers to the posts that have gained a lot of traction and popularity in the community.
	case Popular

	/// Refers to the posts that aren't necessarily popular, but still deserve exposure.
	case Global
}
