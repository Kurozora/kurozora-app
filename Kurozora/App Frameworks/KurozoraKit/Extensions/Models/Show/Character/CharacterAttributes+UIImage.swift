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
	var profileImage: UIImageView {
		let imageView = UIImageView()
		self.profileImage(imageView: imageView)
		return imageView
	}

	/// Returns a placeholder `UIImage` for the character using the character's initials if available, otherwise a placeholder character image is returned.
	var profilePlaceholderImage: UIImage {
		let fullNameInitials = self.name.initials
		return fullNameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: UIImage.Placeholders.userProfile)
	}

	/// Returns a stored focal point of the character's profile image.
	private var profileFocalPoint: CGPoint? {
		guard let focalX = self.profile?.focalX, let focalY = self.profile?.focalY else {
			return nil
		}
		return CGPoint(x: focalX, y: focalY)
	}

	// MARK: - Functions
	/// Set the profile image of the character.
	///
	/// If the character has no profile image set, then a placeholder image is used.
	///
	/// - Parameter imageView: The image view on which to set the profile image.
	func profileImage(imageView: UIImageView) {
		let urlString = self.profile?.url ?? ""

		if let mediaURL = URL(string: urlString) {
			let context = FaceDetectionContext(mediaURL: mediaURL, kind: .character)
			imageView.setImage(with: urlString, placeholder: self.profilePlaceholderImage, faceDetectionContext: context)
		} else {
			imageView.setImage(with: urlString, placeholder: self.profilePlaceholderImage)
		}

		if let circularImageView = imageView as? CircularImageView {
			circularImageView.focalPoint = self.profileFocalPoint
		}
	}
}
