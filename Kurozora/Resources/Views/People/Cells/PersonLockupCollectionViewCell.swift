//
//  PersonLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class PersonLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var personImageView: PersonImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameter person: The person object used to configure the cell.
	func configure(using person: Person?, role: StaffRole? = nil) {
		guard let person = person else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure primary label
		self.primaryLabel.text = person.attributes.fullName

		// Configure secondary label
		self.secondaryLabel.text = role?.name
		self.secondaryLabel.isHidden = role == nil

		// Configure image view
		self.personImageView.setImage(with: person.attributes.profile?.url ?? "", placeholder: person.attributes.placeholderImage)
	}
}
