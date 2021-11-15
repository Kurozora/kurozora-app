//
//  UserAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension User.Attributes {
	/**
		Returns a `UIImage` with the current signed in user's profile image.

		If the user has no profile image set, then an image with the initials of the user's username is returned.
		If no user is signed in then a placeholder profile image is returned.
	*/
	var profileImage: UIImage? {
		let profileImageView = UIImageView()
		profileImageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
		return profileImageView.image?.withRenderingMode(.alwaysOriginal)
	}

	/**
		Returns a `UIImage` with the current signed in user's banner image.

		If the user has no banner image set, then an image with the initials of the user's username is returned.
		If no user is signed in then a placeholder banner image is returned.
	*/
	var bannerImage: UIImage? {
		let bannerImageView = UIImageView()
		bannerImageView.setImage(with: self.banner?.url ?? "", placeholder: self.bannerPlaceholderImage)
		return bannerImageView.image?.withRenderingMode(.alwaysOriginal)
	}

	/**
		Returns a placeholder `UIImage` for the user's profile using the user's initials if available, otherwise a placeholder user image is returned.

		- Returns: a placeholder `UIImage` for the user's profile using the user's initials if available, otherwise a placeholder profile image is returned.
	*/
	var profilePlaceholderImage: UIImage {
		let userameInitials = self.username.initials
		return userameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: R.image.placeholders.userProfile()!)
	}

	/**
		Returns a placeholder `UIImage` for the user's banner using a random solid color.

		- Returns: a placeholder `UIImage` user's banner using a random solid color.
	*/
	var bannerPlaceholderImage: UIImage {
		return UIImage(color: .random, size: CGSize(width: 50, height: 50))
	}
}
