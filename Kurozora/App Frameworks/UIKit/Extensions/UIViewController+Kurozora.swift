//
//  UIViewController+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import AVKit

// MARK: - View
extension UIViewController {
	// MARK: - Functions
	/**
		Notifies the view controller that its view is about to be reloaded.

		This method is called when there has been a change in the user's sign in status. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the data presented by the view or style of the view being presented. If you override this method, you must call super at some point in your implementation.

		- Tag: UIViewController-viewWillReload
	*/
	@objc func viewWillReload() { }

	/**
		Notifies the view controller that the app's theme is about to be reloaded.

		This method is called when there has been a change in the selected app theme. You can override this method to perform custom tasks associated with re-styling unthemeable views. For example, you might use this method to change the color of the view being presented. If you override this method, you must call super at some point in your implementation.

		- Tag: UIViewController-themeWillReload
	*/
	@objc func themeWillReload() { }
}

// MARK: - Present
extension UIViewController {
	// MARK: - Functions
	/**
		Present an `AVPlayerViewController` for the given video URL.

		- Parameter videoURLString: The URL string of the video.
	*/
	func presentVideoViewController(videoURLString: String) {
		let videoURL = URL(string: videoURLString)
		let player = AVPlayer(url: videoURL!)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		self.present(playerViewController, animated: true) {
			playerViewController.player!.play()
		}
	}

	/**
		Present a `UIAlertController` of alert style with a default action button.

		- Parameter title: The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
		- Parameter message: Descriptive text that provides additional details about the reason for the alert.
		- Parameter defaultActionButtonTitle: The text to use for the default button's title. The value you specify should be localized for the user’s current language.
		- Parameter handler: A block to execute when the user selects the default action. This block has no return value and takes the selected action object as its only parameter.
		- Parameter actions: Other actions to add to the alert controller.

		- Returns: the presented alert controller.
	*/
	@discardableResult
	func presentAlertController(title: String?, message: String?, defaultActionButtonTitle: String = "OK", handler: ((UIAlertAction) -> Void)? = nil, actions: [UIAlertAction] = []) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		#if !targetEnvironment(macCatalyst)
		// Add other actions if available.
		for action in actions {
			alertController.addAction(action)
		}
		#endif

		// Add the default action to the alert controller
		let defaultAction = UIAlertAction(title: defaultActionButtonTitle, style: .cancel, handler: handler)
		alertController.addAction(defaultAction)

		#if targetEnvironment(macCatalyst)
		// Add other actions if available.
		for action in actions {
			alertController.addAction(action)
		}
		#endif

		self.present(alertController, animated: true, completion: nil)
		return alertController
	}

	/**
		Present a `UIAlertController` of alert style with an activity indicator.

		- Parameter title: The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
		- Parameter message: Descriptive text that provides additional details about the reason for the alert.

		- Returns: the presented alert controller.
	*/
	@discardableResult
	func presentActivityAlertController(title: String?, message: String?) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		// Prepare the activity indicator
		let activityIndicator = UIActivityIndicatorView(frame: alertController.view.bounds)
		activityIndicator.style = .large
		activityIndicator.isUserInteractionEnabled = false
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false

		// Add the activity indicator to the alert controller
		alertController.view.addSubview(activityIndicator)

		let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: alertController.view, attribute: .centerX, multiplier: 1, constant: 0)
		let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: alertController.view, attribute: .centerY, multiplier: 1.6, constant: 0)

		NSLayoutConstraint.activate([ xConstraint, yConstraint])
		activityIndicator.isUserInteractionEnabled = false
		activityIndicator.startAnimating()

		if let alertControllerView = alertController.view {
			let height = NSLayoutConstraint(item: alertControllerView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
			alertController.view.addConstraint(height)
		}

		activityIndicator.startAnimating()

		self.present(alertController, animated: true, completion: nil)
		return alertController
	}
}
