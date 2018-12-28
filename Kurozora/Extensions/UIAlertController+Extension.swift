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
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		for (var title, value) in items {
			if let selection = currentSelection, value == selection {
				// Note that checkmark and space have a neutral text flow direction so this is correct for RTL
				title = title + " ✔︎"
			}
			alertController.addAction(
				UIAlertAction(title: title, style: .default) {_ in
					action(value)
				}
			)
		}
		alertController.view.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
		return alertController
	}
}
