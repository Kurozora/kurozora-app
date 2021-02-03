//
//  KTableViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	The KTableViewDataSource protocol defines methods that guide you with managing the cells registered with the table view. The methods of this protocol are all optional.

	- Tag: KTableViewDataSource
*/
@objc protocol KTableViewDataSource: AnyObject {
	@objc optional func registerCells(for tableView: UITableView) -> [UITableViewCell.Type]
	@objc optional func registerNibs(for tableView: UITableView) -> [UITableViewHeaderFooterView.Type]
}
