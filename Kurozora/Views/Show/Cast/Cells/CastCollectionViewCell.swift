//
//  CastCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol CastCollectionViewCellDelegate: class {
	func actorButtonPressed(_ cell: CastCollectionViewCell)
	func characterButtonPressed(_ cell: CastCollectionViewCell)
}

class CastCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var actorImageView: UIImageView!
	@IBOutlet weak var actorNameLabel: KCopyableTintedLabel!
	@IBOutlet weak var actorButton: UIButton!

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
		// Configure actor
		self.actorNameLabel.text = cast.relationships.actors.data.first?.attributes.fullName ?? "Unknown"
		self.actorImageView.image = self.cast.relationships.actors.data.first?.attributes.personalImage

		// Configure character
		if let characterName = cast.relationships.characters.data.first?.attributes.name {
			self.characterNameLabel.text = !characterName.isEmpty ? "as \(characterName)" : ""
		}
		self.characterRoleLabel.text = cast.attributes.role
		self.characterImageView.image = self.cast.relationships.characters.data.first?.attributes.personalImage
	}

	// MARK: - IBActions
	@IBAction func actorButtonPressed(_ sender: UIButton) {
		self.delegate?.actorButtonPressed(self)
	}

	@IBAction func characterButtonPressed(_ sender: UIButton) {
		self.delegate?.characterButtonPressed(self)
	}
}
