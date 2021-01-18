//
//  ForumsViewControllerDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ForumsViewControllerDelegate: class {
	/**
		Tells your `ForumsViewControllerDelegate` to order the forums with the specified order type.

		- Parameter forumOrder: The order type by which the forums should be ordered.
	*/
	func orderForums(by forumOrder: ForumOrder)

	/**
		Tells your `ForumsViewControllerDelegate` the current order value used to order the items in the forums.

		- Returns: The current order value used to order the items in the forums.
	*/
	func orderValue() -> ForumOrder
}
