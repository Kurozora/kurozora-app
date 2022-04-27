//
//  KTableViewController+KTableViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension KTableViewController: KTableViewDataSource {
	/// Asks your data source object for the cells registered with the collection view.
	///
	/// If you do not implement this method, the table view uses a default value of an empty array.
	///
	/// - Parameter tableView: The table view requesting this information.
	///
	/// - Returns: The table view cells registered with `tableView`.
	///
	/// - Tag: KTableViewController-registerCellsForTableView
	func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return []
	}

	/// Asks your data source object for the reusable views registered with the `tableView`.
	///
	/// If you do not implement this method, the collection view uses a default value of an empty array.
	///
	/// - Parameter tableView: The collection view requesting this information.
	///
	/// - Returns: The collection view reusable views registered with `tableView`.
	///
	/// - Tag: KTableViewDataSource-registerNibsForTableView
	func registerNibs(for tableView: UITableView) -> [UITableViewHeaderFooterView.Type] {
		return []
	}
}
