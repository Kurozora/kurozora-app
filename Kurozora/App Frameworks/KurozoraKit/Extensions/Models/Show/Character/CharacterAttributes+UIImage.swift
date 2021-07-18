//
//  CharacterAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension Character.Attributes {
	/**
		Returns a `UIImage` with the image url of the character.

		If the character has no image set, then an image with the initials of the character's name is returned.
		If no name is available then a placeholder character image is returned.

		- Returns: a `UIImage` with the image url of the character.
	*/
	var personalImage: UIImage? {
		let imageView = UIImageView()
		imageView.setImage(with: self.imageURL ?? "", placeholder: self.placeholderImage)
		return imageView.image?.withRenderingMode(.alwaysOriginal)
	}

	/**
		 Returns a placeholder `UIImage` for the character using the character's initials if available, otherwise a placeholder character image is returned.

		 - Returns: a placeholder `UIImage` for the character using the character's initials if available, otherwise a placeholder character image is returned.
	 */
	var placeholderImage: UIImage {
		let fullNameInitials = self.name.initials
		return fullNameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: R.image.placeholders.userProfile()!)
	}
}
