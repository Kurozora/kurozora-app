//
//  UIViewController+KurozoraKit.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/11/2020.
//

internal extension UIViewController {
	/**
		Present a `UIAlertController` with a default action button.

		- Parameter title: The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
		- Parameter message: Descriptive text that provides additional details about the reason for the alert.
		- Parameter defaultActionButtonTitle: The text to use for the default button's title. The value you specify should be localized for the user’s current language.
		- Parameter handler: A block to execute when the user selects the default action. This block has no return value and takes the selected action object as its only parameter.

		- Returns: the presented alert controller.
	*/
	@discardableResult
	func presentAlertController(title: String?, message: String?, defaultActionButtonTitle: String = "OK", handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		// Add the default action to the alert controller
		let defaultAction = UIAlertAction(title: defaultActionButtonTitle, style: .default, handler: handler)
		alertController.addAction(defaultAction)

		self.present(alertController, animated: true, completion: nil)
		return alertController
	}
}
