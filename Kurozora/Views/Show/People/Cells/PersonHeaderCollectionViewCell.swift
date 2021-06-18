//
//  PersonHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class PersonHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var personImageView: PersonImageView!
	@IBOutlet weak var nameLabel: KLabel!

	// MARK: - Properties
	var person: Person! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		self.nameLabel.text = self.person.attributes.fullName
		self.personImageView.image = self.person.attributes.personalImage
	}
}
