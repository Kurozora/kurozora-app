//
//  CharacterAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Character.Attributes {
	// MARK: - Properties
	/// Returns a `UIImage` with the image url of the character.
	///
	/// If the character has no profile image set, then a placeholder image is applied.
	///
	/// - Returns: a `UIImage` with the image url of the character.
	var profileImage: UIImageView {
		let imageView = UIImageView()
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
		return imageView
	}

	/// Returns a placeholder `UIImage` for the character using the character's initials if available, otherwise a placeholder character image is returned.
	///
	/// - Returns: a placeholder `UIImage` for the character using the character's initials if available, otherwise a placeholder character image is returned.
	var profilePlaceholderImage: UIImage {
		let fullNameInitials = self.name.initials
		return fullNameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: UIImage.Placeholders.userProfile)
	}

	// MARK: - Functions
	/// Set the profile image of the character.
	///
	/// If the character has no profile image set, then a placeholder image is used.
	///
	/// - Parameter imageView: The image view on which to set the profile image.
	func profileImage(imageView: UIImageView) {
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
	}
}
