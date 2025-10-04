//
//  PersonAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Person.Attributes {
	// MARK: - Properties
	/// Returns a `UIImage` with the image url of the person.
	///
	/// If the person has no image set, then an image with the initials of the person's fullname is returned.
	/// If no fullname is available then a placeholder person image is returned.
	///
	/// - Returns: a `UIImage` with the image url of the person.
	var personalImage: UIImageView {
		let imageView = UIImageView()
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.placeholderImage)
		return imageView
	}

	/// Returns a placeholder `UIImage` for the person using the person's initials if available, otherwise a placeholder person image is returned.
	///
	/// - Returns: a placeholder `UIImage` for the person using the person's initials if available, otherwise a placeholder person image is returned.
	var placeholderImage: UIImage {
		let fullNameInitials = self.fullName.initials
		return fullNameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: R.image.placeholders.userProfile()!)
	}

	// MARK: - Functions
	/// Set the image of the person.
	///
	/// If the person has no image set, then an image with the initials of the person's fullname is returned.
	/// If no fullname is available then a placeholder person image is returned.
	///
	/// - Parameter imageView: The image view on which to set the personal image.
	func personalImage(imageView: UIImageView) {
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.placeholderImage)
	}
}
