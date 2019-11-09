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

extension UIViewController {
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
	public func presentPhotoViewControllerWith(url image: String?, from startingImageView: UIImageView) {
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
	public func presentPhotoViewControllerWith(image: UIImage?, from startingImageView: UIImageView) {
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
	public func presentPhotoViewControllerWith(string image: String?, from startingImageView: UIImageView) {
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
	public func presentVideoViewControllerWith(string videoUrl: String) {
		let videoURL = URL(string: videoUrl)
		let player = AVPlayer(url: videoURL!)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		self.present(playerViewController, animated: true) {
			playerViewController.player!.play()
		}
	}
//    public func presentAnimeModal(anime: Anime) -> ZFModalTransitionAnimator {
//
//        let tabBarController = KAnimeKit.rootTabBarController()
//        tabBarController.initWithAnime(anime)
//
//        let animator = ZFModalTransitionAnimator(modalViewController: tabBarController)
//        animator?.dragable = true
//        animator.direction = .bottom
//
//        tabBarController.animator = animator
//        tabBarController.transitioningDelegate = animator
//        tabBarController.modalPresentationStyle = UIModalPresentationStyle.custom
//
//        presentViewController(tabBarController, animated: true, completion: nil)
//
//        return animator!
//    }
//    
//    func presentSearchViewController(searchScope: SearchScope) {
//        let (navigation, controller) = KAnimeKit.searchViewController()
//        controller.initWithSearchScope(searchScope)
//        present(navigation, animated: true, completion: nil)
//    }
//    
}
