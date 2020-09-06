//
//  CellActionButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A themed control that executes your custom code in response to user interactions.

	`CellActionButton` provides themed buttons that match with the currently enabled theme. This style is usually used in [UIColelctionView](apple-reference-documentation://hsLSvaK1nM) and [UITableView](apple-reference-documentation://hs8FRRfKne) cells.
*/
class CellActionButton: KButton {
	override func sharedInit() {
		super.sharedInit()

		self.titleLabel?.font = .systemFont(ofSize: self.titleLabel?.font.pointSize ?? 18, weight: .regular)

		self.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		self.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
	}
}
