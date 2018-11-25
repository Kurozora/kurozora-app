//
//  UIAlertController+Extension.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIAlertController {
	static func actionSheetWithItems<A : Equatable>(items : [(title : String, value : A)], currentSelection : A? = nil, action : @escaping (A) -> Void) -> UIAlertController {
		let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		for (var title, value) in items {
			if let selection = currentSelection, value == selection {
				// Note that checkmark and space have a neutral text flow direction so this is correct for RTL
				title = "✔︎ " + title
			}
			controller.addAction(
				UIAlertAction(title: title, style: .default) {_ in
					action(value)
				}
			)
		}
		return controller
	}
}
