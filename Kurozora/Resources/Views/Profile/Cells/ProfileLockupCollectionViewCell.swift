//
//  ProfileLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ProfileLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var imageView: CircularImageView!
	@IBOutlet weak var labelsStackView: UIStackView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var rankLabel: KLabel!

	// MARK: - View Lifecycle
	override func awakeFromNib() {
		super.awakeFromNib()

		self.imageView.layer.borderWidth = 2
		self.imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
	}

	// MARK: - Functions
	/// Configures the cell to display a character.
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

		self.hideSkeleton()

		self.primaryLabel.text = character.attributes.name
		self.primaryLabel.isHidden = !showsTitle

		self.secondaryLabel.text = role?.name
		self.secondaryLabel.isHidden = !showsSubtitle || role == nil

		self.applyRank(rank, showsRank: showsRank)
		self.updateLabelsStackVisibility()

		character.attributes.profileImage(imageView: self.imageView)
	}

	/// Configures the cell to display a person.
	///
	/// - Parameters:
	///    - person: The person object used to configure the cell.
	///    - role: The role of the person in the series.
	///    - rank: The rank of the person in a ranked list.
	///    - showsTitle: Whether to show the primary label.
	///    - showsSubtitle: Whether to show the secondary label.
	///    - showsRank: Whether to show the rank label.
	func configure(using person: Person?, role: StaffRole? = nil, rank: Int? = nil, showsTitle: Bool = true, showsSubtitle: Bool = true, showsRank: Bool = true) {
		guard let person = person else {
			self.showSkeleton()
			return
		}

		self.hideSkeleton()

		self.primaryLabel.text = person.attributes.fullName
		self.primaryLabel.isHidden = !showsTitle

		self.secondaryLabel.text = role?.name
		self.secondaryLabel.isHidden = !showsSubtitle || role == nil

		self.applyRank(rank, showsRank: showsRank)
		self.updateLabelsStackVisibility()

		person.attributes.profileImage(imageView: self.imageView)
	}

	/// Configures the cell to display a user.
	///
	/// - Parameters:
	///    - user: The user object used to configure the cell.
	///    - rank: The rank of the user in the leaderboard.
	///    - showsReputation: A Boolean value that determines whether the secondary label
	///      displays the user's reputation count.
	func configure(using user: User?, rank: Int? = nil, showsReputation: Bool = false) {
		guard let user = user else {
			self.showSkeleton()
			return
		}

		self.hideSkeleton()

		self.primaryLabel.text = user.attributes.username
		self.primaryLabel.isHidden = false

		if showsReputation {
			self.secondaryLabel.text = user.attributes.reputationCount.kkFormatted(precision: 0)
			self.secondaryLabel.isHidden = false
		} else {
			self.secondaryLabel.text = nil
			self.secondaryLabel.isHidden = true
		}

		self.applyRank(rank, showsRank: rank != nil)
		self.updateLabelsStackVisibility()

		user.attributes.profileImage(imageView: self.imageView)
	}

	// MARK: - Private
	/// Sets the rank label's text and visibility for the current configuration.
	///
	/// - Parameters:
	///    - rank: The rank to display, or `nil` when no rank should be shown.
	///    - showsRank: A Boolean value that gates the rank's visibility independently
	///      of the rank value being non-`nil`.
	private func applyRank(_ rank: Int?, showsRank: Bool) {
		if showsRank, let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}
	}

	private func updateLabelsStackVisibility() {
		self.labelsStackView.isHidden = self.primaryLabel.isHidden
			&& self.secondaryLabel.isHidden
			&& self.rankLabel.isHidden
	}
}
