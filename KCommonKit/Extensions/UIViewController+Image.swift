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
		Present image in a lightbox

		- Parameter image: The url to pass onto the view
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
		Present image in a lightbox

		- Parameter image: The string to pass onto the view
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

	public func presentVideoViewControllerWith(string youtubeID: String) {
		guard var youtubeUrl = URL(string: "youtube://\(youtubeID)") else { return }

		if !UIApplication.shared.canOpenURL(youtubeUrl)  {
			youtubeUrl = URL(string:"http://www.youtube.com/watch?v=\(youtubeID)")!
		}

		UIApplication.shared.open(youtubeUrl, options: [:], completionHandler: nil)
	}
}
