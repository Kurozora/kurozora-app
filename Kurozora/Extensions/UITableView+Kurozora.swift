//
//  UITableView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UITableView {
	/// Set table header view & add Auto layout.
	func setTableHeaderView(headerView: UIView?) {
		guard let headerView = headerView else { return }
		headerView.translatesAutoresizingMaskIntoConstraints = false

		// Set first.
		self.tableHeaderView = headerView

		// Then setup AutoLayout.
		headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
		headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
	}

	/// Update header view's frame.
	func updateHeaderViewFrame() {
		guard let headerView = self.tableHeaderView else { return }

		// Update the size of the header based on its internal content.
		headerView.layoutIfNeeded()

		// Trigger table view to know that header should be updated.
		let header = self.tableHeaderView
		self.tableHeaderView = header
	}
}
