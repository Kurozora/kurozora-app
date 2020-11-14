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
