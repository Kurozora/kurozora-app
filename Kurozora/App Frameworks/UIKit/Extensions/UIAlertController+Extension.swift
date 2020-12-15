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
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { actionSheetAlertController in
			for (var title, value) in items {
				if let selection = currentSelection, value == selection {
					title += " ✓"
				}

				let action = UIAlertAction(title: title, style: .default) {_ in
					action(title, value)
				}
				actionSheetAlertController.addAction(action)
			}
		}
		return actionSheetAlertController
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
	static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A, image: UIImage)], currentSelection: A? = nil, action: @escaping (_ title: String, _ value: A, _ image: UIImage) -> Void) -> UIAlertController {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { actionSheetAlertController in
			for (var title, value, image) in items {
				if let selection = currentSelection, value == selection {
					title += " ✓"
				}

				let action = UIAlertAction(title: title, style: .default) {_ in
					action(title, value, image)
				}
				action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				action.setValue(image, forKey: "image")
				actionSheetAlertController.addAction(action)
			}
		}
		return actionSheetAlertController
	}

	/**
		Return an action sheet with the default style and a default action button.

		- Parameter title: The title of the action sheet. Use this string to get the user’s attention and communicate the reason for the action sheet.
		- Parameter message: Descriptive text that provides additional details about the reason for the action sheet.
		- Parameter defaultActionButtonTitle: The text to use for the default button's title. The value you specify should be localized for the user’s current language.
		- Parameter handler: A block to execute when the user selects the default action. This block has no return value and takes the selected action object as its only parameter.
		- Parameter actions: Actions specified by the user to be added to the action sheet.
		- Parameter actionSheetAlertController: The instantiated alert controller instance.

		- Returns: an action sheet with the default style and a default action button.
	*/
	static func actionSheet(title: String?, message: String?, defaultActionButtonTitle: String = "Cancel", handler: ((UIAlertAction) -> Void)? = nil, actions: ((_ actionSheetAlertController: UIAlertController) -> Void)) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		alertController.view.tintColor = .label

		// Add user specified actions
		actions(alertController)

		// Add the default action to the alert controller
		let defaultAction = UIAlertAction(title: defaultActionButtonTitle, style: .cancel, handler: handler)
		alertController.addAction(defaultAction)

		return alertController
	}
}
