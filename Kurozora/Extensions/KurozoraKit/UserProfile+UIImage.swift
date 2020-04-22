//
//  UserProfile+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension UserProfile {
	/**
		Returns a `UIImage` with the current signed in user's profile image.

		If the user has no profile image set, then an image with the initials of the user's username is returned.
		If no user is signed in then a placeholder profile image is returned.
	*/
	var profileImage: UIImage? {
		let profileImageView = UIImageView()
		if let usernameInitials = username?.initials {
			let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.profile_image()!)
			profileImageView.setImage(with: profileImageURL ?? "", placeholder: placeholderImage)
		}
		return profileImageView.image?.withRenderingMode(.alwaysOriginal)
	}
}
