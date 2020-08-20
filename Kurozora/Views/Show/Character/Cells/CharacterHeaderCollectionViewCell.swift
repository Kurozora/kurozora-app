//
//  CharacterHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CharacterHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var characterImageView: CharacterImageView!
	@IBOutlet weak var nameLabel: KLabel!

	// MARK: - Properties
	var character: Character! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		self.nameLabel.text = character.attributes.name
		self.characterImageView.image = character.attributes.personalImage
	}
}
