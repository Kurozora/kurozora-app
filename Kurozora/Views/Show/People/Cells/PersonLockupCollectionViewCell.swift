//
//  PersonLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class PersonLockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var personImageView: PersonImageView!
	@IBOutlet weak var nameLabel: KLabel!

	// MARK: - Functions
	/**
		Configure the cell with the given details.

		- Parameter person: The person object used to configure the cell.
	*/
	func configureCell(with person: Person) {
		self.personImageView.setImage(with: person.attributes.profile?.url ?? "", placeholder: person.attributes.placeholderImage)
		self.nameLabel.text = person.attributes.fullName
	}
}
