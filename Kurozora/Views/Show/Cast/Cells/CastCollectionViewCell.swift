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
		self.personNameLabel.text = cast.relationships.people.data.first?.attributes.fullName ?? "Unknown"
		self.personImageView.image = self.cast.relationships.people.data.first?.attributes.personalImage

		// Configure character
		if let characterName = cast.relationships.characters.data.first?.attributes.name {
			self.characterNameLabel.text = !characterName.isEmpty ? "as \(characterName)" : ""
		}
		self.characterRoleLabel.text = cast.attributes.role.name
		self.characterImageView.image = self.cast.relationships.characters.data.first?.attributes.personalImage
	}

	// MARK: - IBActions
	@IBAction func personButtonPressed(_ sender: UIButton) {
		self.delegate?.castCollectionViewCell(self, didPressPersonButton: sender)
	}

	@IBAction func characterButtonPressed(_ sender: UIButton) {
		self.delegate?.castCollectionViewCell(self, didPressCharacterButton: sender)
	}
}
