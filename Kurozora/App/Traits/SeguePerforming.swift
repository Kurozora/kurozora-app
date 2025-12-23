//
//  SeguePerforming.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// A protocol that defines a type capable of performing segues identified by an associated type.
protocol SeguePerforming where Self: UIViewController {
	/// Initiates the segue with the specified identifier from the current view controller’s storyboard file.
	///
	/// Normally, segues are initiated automatically and not using this method. However, you can use this method in cases where the segue could not be configured in your storyboard file. For example, you might call it from a custom action handler used in response to shake or accelerometer events.
	///
	/// The current view controller must have been loaded from a storyboard. If its [storyboard](https://developer.apple.com/documentation/uikit/uiviewcontroller/storyboard) property is `nil`, perhaps because you allocated and initialized the view controller yourself, this method throws an exception.
	///
	/// - Parameters:
	///    - identifier: The object that identifies the triggered segue.
	///    - sender: The object to use as the sender of the segue. If you do not specify a value, the view controller uses itself as the sender.
	func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?)

	/// Displays the view controller identified by the specified segue identifier.
	///
	/// - Parameters:
	///    - identifier: The object that identifies the triggered segue.
	///    - sender: The object to use as the sender of the segue.
	func show(_ identifier: SegueIdentifier, sender: Any?)

	/// Presents the view controller identified by the specified segue identifier modally.
	///
	/// - Parameters:
	///    - identifier: The object that identifies the triggered segue.
	///    - sender: The object to use as the sender of the segue.
	func present(_ identifier: SegueIdentifier, sender: Any?)
}

/// A protocol that defines a type capable of handling segues identified by an associated type.
protocol SegueHandler where Self: UIViewController {
	/// Creates the destination view controller for the specified segue identifier.
	///
	/// - Parameters:
	///    - identifier: The object that identifies the triggered segue.
	///
	/// - Returns: The destination view controller for the specified segue identifier.
	func makeDestination(for identifier: SegueIdentifier) -> UIViewController?

	/// Prepares the destination view controller before the segue is performed.
	///
	/// - Parameters:
	///    - identifier: The object that identifies the triggered segue.
	///    - destination: The destination view controller for the segue
	///    - sender: The object to use as the sender of the segue.
	func prepare(for identifier: SegueIdentifier, destination: UIViewController, sender: Any?)
}
