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
	@IBOutlet weak var rankLabel: KLabel!

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - character: The character object used to configure the cell.
	///    - role: The role of the character in the series.
	///    - rank: The rank of the character in a ranked list.
	func configure(using character: Character?, role: CastRole? = nil, rank: Int? = nil) {
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

		// Configure rank
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}

		// Configure image view
		self.characterImageView.setImage(with: character.attributes.profile?.url ?? "", placeholder: character.attributes.placeholderImage)
	}
}
