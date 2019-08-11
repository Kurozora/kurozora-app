//
//  UIViewController+Image.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import AXPhotoViewer
import FLAnimatedImage
import AVKit
import AVFoundation

extension UIViewController {
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
		let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: startingImageView) { (photo, index) -> UIImageView? in
			// this closure can be used to adjust your UI before returning an `endingImageView`.
			return startingImageView
		}
        
        // Create an instance of AXPhotosViewController
		let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)
        
        // Present the video
        present(photosViewController, animated: true, completion: nil)
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
		let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: startingImageView) { (photo, index) -> UIImageView? in
			// this closure can be used to adjust your UI before returning an `endingImageView`.
			return startingImageView
		}

		// Create an instance of AXPhotosViewController
		let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)
        
        // Present the video
        present(photosViewController, animated: true, completion: nil)
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
		present(playerViewController, animated: true) {
			playerViewController.player!.play()
		}
	}
}
