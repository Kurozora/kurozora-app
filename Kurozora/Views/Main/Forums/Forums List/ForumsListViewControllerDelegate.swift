//
//  ForumsListViewControllerDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ForumsListViewControllerDelegate: AnyObject {
	func updateForumOrderButton(with orderType: ForumOrder)
}
