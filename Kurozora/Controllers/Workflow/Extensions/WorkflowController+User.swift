//
//  WorkflowController+User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation
import Kingfisher

// MARK: - User
extension WorkflowController {
	func getUserDetails() {
		let dispatchQueue = DispatchQueue(label: "CacheUserProfileImage", qos: .background)
		dispatchQueue.async {
			KService.shared.getUserProfile(User.currentID) { user in
				if let profileImage = user?.profile?.profileImage, let url = URL(string: profileImage) {
					let downloader = ImageDownloader.default
					downloader.downloadImage(with: url) { result in
						switch result {
						case .success(let value):
							ImageCache.default.store(value.image, forKey: "currentUserProfileImage")
						case .failure(let error):
							print("Error caching image: \(error)")
						}
					}
				}
			}
		}
	}
}
