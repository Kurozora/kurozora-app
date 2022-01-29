//
//  CharacterLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CharacterLockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var characterImageView: CharacterImageView!
	@IBOutlet weak var nameLabel: KLabel!

	// MARK: - Functions
	/**
		Configure the cell with the given details.

		- Parameter character: The character object used to configure the cell.
	*/
	func configureCell(with character: Character) {
		self.nameLabel.text = character.attributes.name
		self.characterImageView.setImage(with: character.attributes.profile?.url ?? "", placeholder: character.attributes.placeholderImage)
	}
}
