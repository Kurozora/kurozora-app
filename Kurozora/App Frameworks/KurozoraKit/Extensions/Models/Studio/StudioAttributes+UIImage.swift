//
//  StudioAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Studio.Attributes {
	// MARK: - Properties
	/// Returns a `UIImageView` object containing the studio's profile image.
	///
	/// If the studio has no logo image set, then a placeholder image is applied.
	///
	/// - Returns: a `UIImageView` object containing the studio's profile image.
	var profileImageView: UIImageView {
		let profileImageView = UIImageView()
		profileImageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
		return profileImageView
	}

	/// Returns a `UIImageView` object containing the studio's banner image.
	///
	/// If the studio has no banner image set, then a placeholder image is returned.
	///
	/// - Returns: a `UIImageView` object containing the studio's banner image.
	var bannerImageView: UIImageView? {
		let bannerImageView = UIImageView()
		bannerImageView.setImage(with: self.banner?.url ?? "", placeholder: self.bannerPlaceholderImage)
		return bannerImageView
	}

	/// Returns a `UIImageView` object containing the studio's logo image.
	///
	/// If the studio has no logo image set, then a placeholder image is returned.
	///
	/// - Returns: a `UIImageView` object containing the studio's logo image.
	var logoImageView: UIImageView? {
		let logoImageView = UIImageView()
		logoImageView.setImage(with: self.logo?.url ?? "", placeholder: self.logoPlaceholderImage)
		return logoImageView
	}

	/// Returns a placeholder `UIImage` for the studio's profile using the studio's initials if available, otherwise a placeholder studio image is returned.
	///
	/// - Returns: a placeholder `UIImage` for the studio's profile using the studio's initials if available, otherwise a placeholder profile image is returned.
	var profilePlaceholderImage: UIImage {
		let studioameInitials = self.name.initials
		return studioameInitials.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300), placeholder: R.image.placeholders.studioProfile()!)
	}

	/// Returns a placeholder `UIImage` for the studio's banner.
	///
	/// - Returns: a placeholder `UIImage` studio's banner.
	var bannerPlaceholderImage: UIImage {
		return R.image.placeholders.studioProfile()!
	}

	/// Returns a placeholder `UIImage` for the studio's logo.
	///
	/// - Returns: a placeholder `UIImage` studio's logo.
	var logoPlaceholderImage: UIImage {
		return R.image.placeholders.studioProfile()!
	}

	// MARK: - Functions
	/// Set the current signed in studio's profile image.
	///
	/// If the studio has no profile image set, then a placeholder image is applied.
	///
	/// - Parameter imageView: The image view on which to set the profile image.
	func profileImage(imageView: UIImageView) {
		imageView.setImage(with: self.profile?.url ?? "", placeholder: self.profilePlaceholderImage)
	}

	/// Set the current signed in studio's banner image.
	///
	/// If the studio has no banner image set, then a placeholder image is applied.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
		let imageURL = self.banner?.url ?? self.profile?.url ?? self.logo?.url ?? ""
		imageView.setImage(with: imageURL, placeholder: self.bannerPlaceholderImage)
	}

	/// Set the current signed in studio's banner image.
	///
	/// If the studio has no banner image set, then a placeholder image is applied.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func logoImage(imageView: UIImageView) {
		imageView.setImage(with: self.logo?.url ?? "", placeholder: self.logoPlaceholderImage)
	}
}
