//
//  HeaderButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A themed control that executes your custom code in response to user interactions.

	`HeaderButton` provides themed buttons that match with the currently enabled theme. This style is usually used in [UIColelctionView](apple-reference-documentation://hsLSvaK1nM) and [UITableView](apple-reference-documentation://hs8FRRfKne) section headers.
*/
class HeaderButton: KButton {
	override func sharedInit() {
		super.sharedInit()

		self.titleLabel?.font = .preferredFont(forTextStyle: .body)
	}
}
