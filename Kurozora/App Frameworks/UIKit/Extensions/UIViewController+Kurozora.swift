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
	*/
	@objc func viewWillReload() {
	}
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

	/**
		Present a `UIAlertController` with an activity indicator.

		- Parameter title: The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
		- Parameter message: Descriptive text that provides additional details about the reason for the alert.

		- Returns: the presented alert controller.
	*/
	@discardableResult
	func presentActivityAlertController(title: String?, message: String?) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		// Add the activity indicator to the alert controller
		let activityIndicator = UIActivityIndicatorView(frame: alertController.view.bounds)
		activityIndicator.style = .large
		activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		alertController.view.addSubview(activityIndicator)
		activityIndicator.isUserInteractionEnabled = false
		activityIndicator.startAnimating()

		self.present(alertController, animated: true, completion: nil)
		return alertController
	}
}
