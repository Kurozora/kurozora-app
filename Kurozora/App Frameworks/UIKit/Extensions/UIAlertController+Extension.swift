//
//  UIAlertController+Extension.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIAlertController {
	/// Return a selectable action sheet from given items.
	///
	/// - Parameters:
	///    - items: The array of items  that includes `title` and `value`  from which the action sheet should be created.
	///    - currentSelection: The item that is currently selected.
	///    - action: The action bound to an item.
	///    - title: The title of an action.
	///    - value: The value of an action.
	///
	/// - Returns: a selectable action sheet from given items.
	static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A)], currentSelection: A? = nil, action: @escaping (_ title: String, _ value: A) -> Void) -> UIAlertController {
		return UIAlertController.actionSheet(title: nil, message: nil) { actionSheetAlertController in
			for (var title, value) in items {
				if let selection = currentSelection, value == selection {
					title += " ✓"
				}

				let action = UIAlertAction(title: title, style: .default) { _ in
					action(title, value)
				}
				actionSheetAlertController.addAction(action)
			}
		}
	}

	/// Return a selectable action sheet from given items with an icon.
	///
	/// - Parameters:
	///    - items: The array of items that includes `title`, `value` and `image` from which the action sheet should be created.
	///    - currentSelection: The item that is currently selected.
	///    - action: The action bound to an item.
	///    - title: The title of an action.
	///    - value: The value of an action.
	///
	/// - Returns: a selectable action sheet from given items with an icon.
	static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A, image: UIImage)], currentSelection: A? = nil, action: @escaping (_ title: String, _ value: A, _ image: UIImage) -> Void) -> UIAlertController {
		return UIAlertController.actionSheet(title: nil, message: nil) { actionSheetAlertController in
			for (var title, value, image) in items {
				if let selection = currentSelection, value == selection {
					title += " ✓"
				}

				let action = UIAlertAction(title: title, style: .default) { _ in
					action(title, value, image)
				}
				action.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				action.setValue(image, forKey: "image")
				actionSheetAlertController.addAction(action)
			}
		}
	}

	/// Return an action sheet with the default style and a default action button.
	///
	/// - Parameters:
	///    - title: The title of the action sheet. Use this string to get the user’s attention and communicate the reason for the action sheet.
	///    - message: Descriptive text that provides additional details about the reason for the action sheet.
	///    - defaultActionButtonTitle: The text to use for the default button's title. The value you specify should be localized for the user’s current language.
	///    - handler: A block to execute when the user selects the default action. This block has no return value and takes the selected action object as its only parameter.
	///    - actions: Actions specified by the user to be added to the action sheet.
	///    - actionSheetAlertController: The instantiated alert controller instance.
	///
	/// - Returns: an action sheet with the default style and a default action button.
	static func actionSheet(title: String?, message: String?, defaultActionButtonTitle: String = Trans.cancel, handler: ((UIAlertAction) -> Void)? = nil, actions: (_ actionSheetAlertController: UIAlertController) -> Void) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		alertController.view.tintColor = .label

		// Add user specified actions
		actions(alertController)

		// Add the default action to the alert controller
		let defaultAction = UIAlertAction(title: defaultActionButtonTitle, style: .cancel, handler: handler)
		alertController.addAction(defaultAction)

		return alertController
	}

	/// Return an alert with the default style and a default action button.
	///
	/// - Parameters:
	///    - title: The title of the action sheet. Use this string to get the user’s attention and communicate the reason for the alert.
	///    - message: Descriptive text that provides additional details about the reason for the alert.
	///    - defaultActionButtonTitle: The text to use for the default button's title. The value you specify should be localized for the user’s current language.
	///    - handler: A block to execute when the user selects the default action. This block has no return value and takes the selected action object as its only parameter.
	///    - actions: Actions specified by the user to be added to the alert.
	///    - actionSheetAlertController: The instantiated alert controller instance.
	///
	/// - Returns: an alert with the default style and a default action button.
	static func alert(title: String?, message: String?, defaultActionButtonTitle: String = Trans.cancel, handler: ((UIAlertAction) -> Void)? = nil, actions: (_ actionSheetAlertController: UIAlertController) -> Void) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		// Add user specified actions
		actions(alertController)

		// Add the default action to the alert controller
		let defaultAction = UIAlertAction(title: defaultActionButtonTitle, style: .cancel, handler: handler)
		alertController.addAction(defaultAction)

		return alertController
	}

	/// Add an action to Alert.
	///
	/// - Parameters:
	///   - title: action title.
	///   - style: action style (default is UIAlertActionStyle.default).
	///   - isEnabled: isEnabled status for action (default is true).
	///   - handler: optional action handler to be called when button is tapped (default is nil).
	///
	/// - Returns: action created by this method.
	@discardableResult
	func addAction(title: String, style: UIAlertAction.Style = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
		let action = UIAlertAction(title: title, style: style, handler: handler)
		action.isEnabled = isEnabled
		self.addAction(action)
		return action
	}
}
