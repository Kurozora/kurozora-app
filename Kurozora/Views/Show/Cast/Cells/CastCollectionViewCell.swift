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
	@IBOutlet weak var personImageView: UIImageView!
	@IBOutlet weak var personNameLabel: KCopyableTintedLabel!
	@IBOutlet weak var personButton: UIButton!

	@IBOutlet weak var characterImageView: UIImageView!
	@IBOutlet weak var characterNameLabel: KCopyableLabel!
	@IBOutlet weak var characterRoleLabel: KSecondaryLabel!
	@IBOutlet weak var characterButton: UIButton!

	// MARK: - Properties
	weak var delegate: CastCollectionViewCellDelegate?
	var cast: Cast! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		// Configure person
		if let person = self.cast.relationships.people.data.first {
			self.personNameLabel.text = person.attributes.fullName
			self.personImageView.setImage(with: person.attributes.imageURL ?? "", placeholder: person.attributes.placeholderImage)
		}

		// Configure character
		if let character = cast.relationships.characters.data.first {
			self.characterNameLabel.text = "as \(character.attributes.name)"
			self.characterImageView.setImage(with: character.attributes.imageURL ?? "", placeholder: character.attributes.placeholderImage)
		}
		self.characterRoleLabel.text = cast.attributes.role.name
	}

	// MARK: - IBActions
	@IBAction func personButtonPressed(_ sender: UIButton) {
		self.delegate?.castCollectionViewCell(self, didPressPersonButton: sender)
	}

	@IBAction func characterButtonPressed(_ sender: UIButton) {
		self.delegate?.castCollectionViewCell(self, didPressCharacterButton: sender)
	}
}
