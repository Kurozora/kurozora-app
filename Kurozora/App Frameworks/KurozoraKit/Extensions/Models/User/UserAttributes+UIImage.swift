//
//  UserAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension User.Attributes {
	// MARK: - Properties
	/// Returns a `UIImageView` object containing the user's profile image.
	///
	/// If the user has no profile image set, then an image with the initials of the user's username is returned.
	/// If no user is signed in then a placeholder profile image is returned.
	///
	/// - Returns: a `UIImageView` object containing the user's profile image.
	var profileImageView: UIImageView {
		let profileImageView = UIImageView()
		profileImageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
		return profileImageView
	}

	/// Returns a placeholder `UIImage` for the user's profile using the user's initials if available, otherwise a placeholder user image is returned.
	///
	/// - Returns: a placeholder `UIImage` for the user's profile using the user's initials if available, otherwise a placeholder profile image is returned.
	var profilePlaceholderImage: UIImage {
		let userameInitials = self.username.initials
		return userameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: R.image.placeholders.userProfile()!)
	}

	/// Returns a placeholder `UIImage` for the user's banner using `UIColor.kurozora` color.
	///
	/// - Returns: a placeholder `UIImage` user's banner using `UIColor.kurozora` color.
	var bannerPlaceholderImage: UIImage {
		return UIImage(color: .kurozora, size: CGSize(width: 50, height: 50))
	}

	// MARK: - Functions
	/// Set the current signed in user's profile image.
	///
	/// If the user has no profile image set, then an image with the initials of the user's username is returned.
	/// If no user is signed in then a placeholder profile image is returned.
	///
	/// - Parameter imageView: The image view on which to set the profile image.
	func profileImage(imageView: UIImageView) {
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
	}

	/// Set the current signed in user's banner image.
	///
	/// If the user has no banner image set, then an image with the initials of the user's username is returned.
	/// If no user is signed in then a placeholder banner image is returned.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
		imageView.setImage(with: self.banner?.url ?? "", placeholder: self.bannerPlaceholderImage)
	}
}
