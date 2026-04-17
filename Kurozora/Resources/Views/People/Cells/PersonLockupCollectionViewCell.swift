//
//  PersonLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class PersonLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var personImageView: PersonImageView!
	@IBOutlet weak var labelsStackView: UIStackView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var rankLabel: KLabel!

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - person: The person object used to configure the cell.
	///    - role: The role of the person in the series.
	///    - rank: The rank of the person in a ranked list.
	///    - showsTitle: Whether to show the primary labe.
	///    - showsSubtitle: Whether to show the secondary label.
	///    - showsRank: Whether to show the rank label.
	func configure(using person: Person?, role: StaffRole? = nil, rank: Int? = nil, showsTitle: Bool = true, showsSubtitle: Bool = true, showsRank: Bool = true) {
		guard let person = person else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure primary label
		self.primaryLabel.text = person.attributes.fullName
		self.primaryLabel.isHidden = !showsTitle

		// Configure secondary label
		self.secondaryLabel.text = role?.name
		self.secondaryLabel.isHidden = role == nil

		// Configure rank
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}

		// Configure labels stack view visibility
		self.labelsStackView.isHidden = self.primaryLabel.isHidden && self.secondaryLabel.isHidden && self.rankLabel.isHidden

		// Configure image view
		person.attributes.profileImage(imageView: self.personImageView)
	}
}
