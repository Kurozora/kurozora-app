//
//  CharacterLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class CharacterLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var characterImageView: CharacterImageView!
	@IBOutlet weak var labelsStackView: UIStackView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var rankLabel: KLabel!

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - character: The character object used to configure the cell.
	///    - role: The role of the character in the series.
	///    - rank: The rank of the character in a ranked list.
	///    - showsTitle: Whether to show the primary label.
	///    - showsSubtitle: Whether to show the secondary label.
	///    - showsRank: Whether to show the rank label.
	func configure(using character: Character?, role: CastRole? = nil, rank: Int? = nil, showsTitle: Bool = true, showsSubtitle: Bool = true, showsRank: Bool = true) {
		guard let character = character else {
			self.showSkeleton()
			return
		}
		self.self.hideSkeleton()

		// Configure primary label
		self.primaryLabel.text = character.attributes.name
		self.primaryLabel.isHidden = !showsTitle

		// Configure secondary label
		self.secondaryLabel.text = role?.name
		self.secondaryLabel.isHidden = !showsSubtitle || role == nil

		// Configure rank
		if showsRank, let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}

		// Configure labels stack view visibility
		self.labelsStackView.isHidden = self.primaryLabel.isHidden && self.secondaryLabel.isHidden && self.rankLabel.isHidden

		// Configure image view
		character.attributes.profileImage(imageView: self.characterImageView)
	}
}
