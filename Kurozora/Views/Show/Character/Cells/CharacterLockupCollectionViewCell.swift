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

	// MARK: - Properties
	var character: Character! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		self.characterImageView.image = self.character.attributes.personalImage
		self.nameLabel.text = self.character.attributes.name
	}
}
