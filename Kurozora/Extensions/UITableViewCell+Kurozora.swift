//
//  UITableViewCell+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UITableViewCell {
	/// Returns an instance of the tableView containing the cell.
	var tableView: UITableView? {
		return (next as? UITableView) ?? (parentViewController as? UITableViewController)?.tableView
	}

	/// Returns the indexPath of the cell.
	var indexPath: IndexPath? {
		return tableView?.indexPath(for: self)
	}
}
