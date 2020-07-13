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
	@IBOutlet weak var characterNameLabel: KCopyableLabel!
	@IBOutlet weak var characterRoleLabel: KSecondaryLabel!

	@IBOutlet weak var actorImageView: UIImageView!
	@IBOutlet weak var actorShadowView: UIView!
	@IBOutlet weak var actorNameLabel: KCopyableTintedLabel!
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	var castElement: CastElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		// Configure actor
		self.actorNameLabel.text = castElement?.actor?.fullName ?? "Unknown"

		if let actorImage = castElement?.actor?.imageString {
			if let nameInitials = castElement?.actor?.fullName?.initials {
				let placeholderImage = nameInitials.toImage(withFrameSize: actorImageView.frame, placeholder: R.image.placeholders.showPerson()!)
				self.actorImageView.setImage(with: actorImage, placeholder: placeholderImage)
			}
		}
		self.actorShadowView.applyShadow()

		// Configure character
		if let characterName = castElement?.character?.name {
			self.characterNameLabel.text = !characterName.isEmpty ? "as \(characterName)" : ""
		}

		self.characterRoleLabel.text = castElement?.role

		if let characterImage = castElement?.character?.imageString {
			if let nameInitials = castElement?.character?.name?.initials {
				let placeholderImage = nameInitials.toImage(withFrameSize: characterImageView.frame, placeholder: R.image.placeholders.showPerson()!)
				self.characterImageView.setImage(with: characterImage, placeholder: placeholderImage)
			}
		}
		self.characterShadowView.applyShadow()
	}
}
