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
	/// Returns a placeholder `UIImage` for the person using the person's initials if available, otherwise a placeholder person image is returned.
	var profilePlaceholderImage: UIImage {
		let fullNameInitials = self.fullName.initials
		return fullNameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: UIImage.Placeholders.userProfile)
	}

	/// Returns a stored focal point of the person's profile image.
	private var profileFocalPoint: CGPoint? {
		guard let focalX = self.profile?.focalX, let focalY = self.profile?.focalY else {
			return nil
		}
		return CGPoint(x: focalX, y: focalY)
	}

	// MARK: - Functions
	/// Set the image of the person.
	///
	/// If the person has no image set, then an image with the initials of the person's full name is returned.
	/// If no full name is available then a placeholder person image is returned.
	///
	/// - Parameter imageView: The image view on which to set the profile image.
	func profileImage(imageView: UIImageView) {
		let urlString = self.profile?.url ?? ""

		if let mediaURL = URL(string: urlString) {
			let context = FaceDetectionContext(mediaURL: mediaURL, kind: .person)
			imageView.setImage(with: urlString, placeholder: self.profilePlaceholderImage, faceDetectionContext: context)
		} else {
			imageView.setImage(with: urlString, placeholder: self.profilePlaceholderImage)
		}

		if let circularImageView = imageView as? CircularImageView {
			circularImageView.focalPoint = self.profileFocalPoint
		}
	}
}
