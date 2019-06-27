//
//  UIAlertController+Extension.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIAlertController {
	static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A)], currentSelection: A? = nil, action: @escaping (String, A) -> Void) -> UIAlertController {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		for (var title, value) in items {
			if let selection = currentSelection, value == selection {
				// NOTE: that checkmark and space have a neutral text flow direction so this is correct for RTL
				title = title + " ✔︎"
			}

			let action = UIAlertAction(title: title, style: .default) {_ in
				action(title, value)
			}
			alertController.addAction(action)
		}

		alertController.view.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
		return alertController
	}

	static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A, images: UIImage)], currentSelection: A? = nil, action: @escaping (String, A) -> Void) -> UIAlertController {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		for (var title, value, image) in items {
			if let selection = currentSelection, value == selection {
				// NOTE: that checkmark and space have a neutral text flow direction so this is correct for RTL
				title = title + " ✔︎"
			}

			let action = UIAlertAction(title: title, style: .default) {_ in
				action(title, value)
			}
			action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.setValue(image, forKey: "image")
			alertController.addAction(action)
		}

		alertController.view.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
		return alertController
	}
}
