//
//  UIAlertController+Extension.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIAlertController {
	/**
		Return a selectable action sheet from given items.

		- Parameter items: The array of items  that includes `title` and `value`  from which the action sheet should be created.
		- Parameter currentSelection: The item that is currently selected.
		- Parameter action: The action bound to an item.
		- Parameter title: The title of an action.
		- Parameter value: The value of an action.

		- Returns: a selectable action sheet from given items.
	*/
	static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A)], currentSelection: A? = nil, action: @escaping (_ title: String, _ value: A) -> Void) -> UIAlertController {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		for (var title, value) in items {
			if let selection = currentSelection, value == selection {
				// NOTE: - Checkmark and space have a neutral text flow direction so this is correct for RTL
				title += " ✓"
			}

			let action = UIAlertAction(title: title, style: .default) {_ in
				action(title, value)
			}
			alertController.addAction(action)
		}

		alertController.view.tintColor = .kurozora
		return alertController
	}

	/**
		Return a selectable action sheet from given items with an icon.

		- Parameter items: The array of items that includes `title`, `value` and `image` from which the action sheet should be created.
		- Parameter currentSelection: The item that is currently selected.
		- Parameter action: The action bound to an item.
		- Parameter title: The title of an action.
		- Parameter value: The value of an action.

		- Returns: a selectable action sheet from given items with an icon.
	*/
	static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A, image: UIImage)], currentSelection: A? = nil, action: @escaping (_ title: String, _ value: A) -> Void) -> UIAlertController {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		for (var title, value, image) in items {
			if let selection = currentSelection, value == selection {
				// NOTE: - Checkmark and space have a neutral text flow direction so this is correct for RTL
				title += " ✓"
			}

			let action = UIAlertAction(title: title, style: .default) {_ in
				action(title, value)
			}
			action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.setValue(image, forKey: "image")
			alertController.addAction(action)
		}

		alertController.view.tintColor = .kurozora
		return alertController
	}
}
