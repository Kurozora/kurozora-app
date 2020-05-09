//
//  CastCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CastCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var characterImageView: UIImageView!
	@IBOutlet weak var characterShadowView: UIView!
	@IBOutlet weak var characterName: KCopyableLabel! {
		didSet {
			self.characterName.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var characterRole: KCopyableLabel! {
		didSet {
			self.characterRole.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var actorImageView: UIImageView!
	@IBOutlet weak var actorShadowView: UIView!
	@IBOutlet weak var actorName: KCopyableLabel! {
		didSet {
			self.actorName.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var actorJob: KCopyableLabel! {
		didSet {
			self.actorJob.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			self.separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	// MARK: - Properties
	var actorElement: ActorElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let actorElement = actorElement else { return }

		// Configure actor
		self.actorName.text = actorElement.name

//		if let actorRole = actorElement.role {
//			self.actorJob.text = "as \(actorRole)"
//		}

		if let actorImage = actorElement.image {
			if let nameInitials = actorElement.name?.initials {
				let placeholderImage = nameInitials.toImage(withFrameSize: actorImageView.frame, placeholder: R.image.placeholders.showPerson()!)
				self.actorImageView.setImage(with: actorImage, placeholder: placeholderImage)
			}
		}
		self.actorShadowView.applyShadow()

		if self.actorImageView.gestureRecognizers?.count ?? 0 == 0 {
			self.actorImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImage(_:))))
			self.actorImageView.isUserInteractionEnabled = true
		}

		// Configure character
		if let characterName = actorElement.role {
			self.characterName?.text = "as \(characterName)"
		}

		let nameInitials = actorElement.role?.initials
		self.characterImageView.image = nameInitials?.toImage(withFrameSize: characterImageView.frame, placeholder: R.image.placeholders.showPerson()!)
		self.characterShadowView.applyShadow()

		if self.characterImageView.gestureRecognizers?.count ?? 0 == 0 {
			self.characterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImage(_:))))
			self.characterImageView.isUserInteractionEnabled = true
		}
	}

	/**
		Presents the selected cast image in an image viewer.

		- Parameter gestureRecognizer: The gesture recognizer object that contains information about the tapped location on the view.
	*/
	@objc func showImage(_ gestureRecognizer: UITapGestureRecognizer) {
		guard let imageView = gestureRecognizer.view as? UIImageView else { return }
		parentViewController?.presentPhotoViewControllerWith(image: imageView.image, from: imageView)
	}
}
