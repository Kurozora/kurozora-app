//
//  UITableViewCell+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UITableViewCell {
	// MARK: - Properties
	/// Returns the indexPath of the cell.
	// TODO: Refactor
	@available(*, deprecated, message: "Use tableView.indexPath(for: cell) instead")
	var indexPath: IndexPath? {
		return nil
	}
}
