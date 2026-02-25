//
//  CastCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

protocol CastCollectionViewCellDelegate: AnyObject {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton)
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton)
}

class CastCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var personImageView: PosterImageView!
	@IBOutlet weak var personNameLabel: KCopyableTintedLabel!
	@IBOutlet weak var personButton: UIButton!

	@IBOutlet weak var characterImageView: PosterImageView!
	@IBOutlet weak var characterNameLabel: KCopyableLabel!
	@IBOutlet weak var characterRoleLabel: KSecondaryLabel!
	@IBOutlet weak var characterButton: UIButton!

	// MARK: - Properties
	weak var delegate: CastCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - cast: The `Cast` object used to configure the cell.
	func configure(using cast: Cast?) {
		guard let cast = cast else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure person
		if let person = cast.relationships.people?.data.first {
			self.personNameLabel.text = person.attributes.fullName
			person.attributes.profileImage(imageView: self.personImageView)
		}

		// Configure character
		if let character = cast.relationships.characters.data.first {
			self.characterNameLabel.text = "as \(character.attributes.name)"
			character.attributes.profileImage(imageView: self.characterImageView)
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
