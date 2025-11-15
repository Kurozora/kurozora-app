//
//  FMDetailsTableViewControllerDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/11/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

protocol FMDetailsTableViewControllerDelegate: AnyObject {
	func fmDetailsTableViewController(delete messageID: KurozoraItemID)
}
