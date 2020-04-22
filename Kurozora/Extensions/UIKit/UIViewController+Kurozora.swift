//
//  UIViewController+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import AVKit
import AXPhotoViewer
import SPStorkController

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
		Modally present the given view controller.

		Presents the given controller in the default transition style on iOS 13+ and as SPStorkController on older iOS versions.

		- Parameter controller: The view controller to present
	*/
	func present(_ controller: UIViewController) {
		if #available(iOS 13.0, macCatalyst 13, *) {
			self.present(controller, animated: true, completion: nil)
		} else {
			let transitioningDelegate = SPStorkTransitioningDelegate()
			transitioningDelegate.showIndicator = false
			controller.transitioningDelegate = transitioningDelegate
			controller.modalPresentationStyle = .custom
			self.present(controller, animated: true, completion: nil)
		}
    }

	/**
		Present an image in a lightbox.

		- Parameter image: The url of the image to pass onto the view.
		- Parameter startingImageView: The image view containing the image to be presented in a lightbox.
	*/
	func presentPhotoViewControllerWith(url image: String?, from startingImageView: UIImageView) {
		guard let image = image else { return }
		guard let imageUrl = URL(string: image) else { return }

		let photoUrl = [AXPhoto(url: imageUrl)]

		// Set datasource
		let dataSource = AXPhotosDataSource(photos: photoUrl)

		// Transition info
		let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: startingImageView) { (_, _) -> UIImageView? in
			// this closure can be used to adjust your UI before returning an `endingImageView`.
			return startingImageView
		}

		// Create an instance of AXPhotosViewController
		let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)

		// Present the video
		self.present(photosViewController, animated: true, completion: nil)
	}

	/**
		Present an image in a lightbox.

		- Parameter image: The UIImage of the image view to pass onto the view.
		- Parameter startingImageView: The image view containing the image to be presented in a lightbox.
	*/
	func presentPhotoViewControllerWith(image: UIImage?, from startingImageView: UIImageView) {
		guard let image = image else { return }

		let photoUrl = [AXPhoto(image: image)]

		// Set datasource
		let dataSource = AXPhotosDataSource(photos: photoUrl)

		// Transition info
		let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: startingImageView) { (_, _) -> UIImageView? in
			// this closure can be used to adjust your UI before returning an `endingImageView`.
			return startingImageView
		}

		// Create an instance of AXPhotosViewController
		let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)

		// Present the video
		self.present(photosViewController, animated: true, completion: nil)
	}

	/**
		Present an image in a lightbox.

		- Parameter image: The string of the image to pass onto the view.
		- Parameter startingImageView: The image view containing the image to be presented in a lightbox.
	*/
	func presentPhotoViewControllerWith(string image: String?, from startingImageView: UIImageView) {
		guard let image = image else { return }

		let photoUrl = [AXPhoto(image: UIImage(named: image))]

		// Set datasource
		let dataSource = AXPhotosDataSource(photos: photoUrl)

		// Transition info
		let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: startingImageView) { (_, _) -> UIImageView? in
			// this closure can be used to adjust your UI before returning an `endingImageView`.
			return startingImageView
		}

		// Create an instance of AXPhotosViewController
		let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)

		// Present the video
		self.present(photosViewController, animated: true, completion: nil)
	}

	/**
		Present a YouTube video in a view controller.

		- Parameter youtubeID: The id of the YouTube video that should be presented.
	*/
	func presentVideoViewControllerWith(string videoUrl: String) {
		let videoURL = URL(string: videoUrl)
		let player = AVPlayer(url: videoURL!)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		self.present(playerViewController, animated: true) {
			playerViewController.player!.play()
		}
	}
}
