//
//  KTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	The visual representation of a single row in a table view.

	A `KTableViewCell` object is a specialized type of view that manages the content of a single table row.
	You use cells primarily to organize and present your app’s custom content, but `KTableViewCell` provides some specific customizations to support reloading behaviors, including:
	- A [reloadView()](x-source-tag://KTableViewCell-reloadView) method for reloading the data inside the cell.
*/
class KTableViewCell: UITableViewCell {
	/**
		Reloads the view in the table view cell.

		The default implementation of this method does nothing. You need to override this method and provide the data that needs to be reloaded.
		You also need to decide when and how you should reload the view by calling this method somewhere in your table view cell implementation.

		- Tag: KTableViewCell-reloadView
	*/
	func reloadView() {
	}
}
