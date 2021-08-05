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

	// MARK: - Properties
	var person: Person! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		self.personImageView.setImage(with: self.person.attributes.profile?.url ?? "", placeholder: self.person.attributes.placeholderImage)
		self.nameLabel.text = person.attributes.fullName
	}
}
