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
		let usernameInitials = self.username.initials
		let placeholderImage = usernameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: R.image.placeholders.userProfile()!)
		profileImageView.setImage(with: self.profileImageURL ?? "", placeholder: placeholderImage)
		return profileImageView.image?.withRenderingMode(.alwaysOriginal)
	}
}
