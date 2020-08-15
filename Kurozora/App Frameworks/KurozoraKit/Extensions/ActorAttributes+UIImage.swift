//
//  ActorAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension Actor.Attributes {
	/**
		Returns a `UIImage` with the image url of the actor.

		If the actor has no image set, then an image with the initials of the actor's fullname is returned.
		If no fullname is available then a placeholder actor image is returned.
	*/
	var personalImage: UIImage? {
		let imageView = UIImageView()
		let fullNameInitials = self.fullName.initials
		let placeholderImage = fullNameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: R.image.placeholders.userProfile()!)
		imageView.setImage(with: self.imageURL ?? "", placeholder: placeholderImage)
		return imageView.image?.withRenderingMode(.alwaysOriginal)
	}
}
