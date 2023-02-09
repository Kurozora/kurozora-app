//
//  CharacterLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CharacterLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var characterImageView: CharacterImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameter character: The character object used to configure the cell.
	func configure(using character: Character?, role: CastRole? = nil) {
		guard let character = character else {
			self.showSkeleton()
			return
		}
		self.self.hideSkeleton()

		// Configure primary label
		self.primaryLabel.text = character.attributes.name

		// Configure secondary label
		self.secondaryLabel.text = role?.name
		self.secondaryLabel.isHidden = role == nil

		// Configure image view
		self.characterImageView.setImage(with: character.attributes.profile?.url ?? "", placeholder: character.attributes.placeholderImage)
	}
}
