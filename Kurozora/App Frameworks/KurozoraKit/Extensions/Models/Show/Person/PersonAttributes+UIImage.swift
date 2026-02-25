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
	/// If the person has no image set, then an image with the initials of the person's full name is returned.
	/// If no full name is available then a placeholder person image is returned.
	///
	/// - Returns: a `UIImage` with the image url of the person.
	var profileImage: UIImageView {
		let imageView = UIImageView()
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
		return imageView
	}

	/// Returns a placeholder `UIImage` for the person using the person's initials if available, otherwise a placeholder person image is returned.
	///
	/// - Returns: a placeholder `UIImage` for the person using the person's initials if available, otherwise a placeholder person image is returned.
	var profilePlaceholderImage: UIImage {
		let fullNameInitials = self.fullName.initials
		return fullNameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: UIImage.Placeholders.userProfile)
	}

	// MARK: - Functions
	/// Set the image of the person.
	///
	/// If the person has no image set, then an image with the initials of the person's full name is returned.
	/// If no full name is available then a placeholder person image is returned.
	///
	/// - Parameter imageView: The image view on which to set the profile image.
	func profileImage(imageView: UIImageView) {
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
	}
}
