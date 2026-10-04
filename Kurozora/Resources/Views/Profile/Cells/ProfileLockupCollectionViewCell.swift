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
	@IBOutlet weak var borderView: BorderView!
	@IBOutlet weak var contentStackView: UIStackView!
	@IBOutlet weak var labelsStackView: UIStackView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var tertiaryLabel: KSecondaryLabel!
	@IBOutlet weak var rankLabel: KLabel!

	// MARK: - Properties
	/// The constraint that fixes the avatar size in the horizontal style.
	private var avatarWidthConstraint: NSLayoutConstraint?

	// MARK: - View Lifecycle
	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.imageView.layer.borderWidth = 0
			self.borderView.cornerRadius = self.imageView.bounds.height / 2.0
			self.avatarWidthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: 80)
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.borderView.cornerRadius = self.imageView.bounds.height / 2.0
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.setHorizontalStyle(false)
		self.tertiaryLabel.text = nil
		self.tertiaryLabel.isHidden = true
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
	///    - detail: The text shown in place of the role.
	///    - rank: The rank of the person in a ranked list.
	///    - showsTitle: Whether to show the primary label.
	///    - showsSubtitle: Whether to show the secondary label.
	///    - showsRank: Whether to show the rank label.
	func configure(using person: Person?, role: StaffRole? = nil, detail: String? = nil, rank: Int? = nil, showsTitle: Bool = true, showsSubtitle: Bool = true, showsRank: Bool = true) {
		guard let person = person else {
			self.showSkeleton()
			return
		}

		self.hideSkeleton()

		self.primaryLabel.text = person.attributes.fullName
		self.primaryLabel.isHidden = !showsTitle

		self.secondaryLabel.text = detail ?? role?.name
		self.secondaryLabel.isHidden = !showsSubtitle || self.secondaryLabel.text == nil

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

	/// Configures the cell to display a person relationship.
	///
	/// - Parameter relationship: The person relationship used to configure the cell.
	func configure(using relationship: PersonRelationship) {
		self.hideSkeleton()

		let relatedPerson = relationship.person
		self.primaryLabel.text = relatedPerson.attributes.fullName
		self.primaryLabel.isHidden = false

		self.secondaryLabel.text = relationship.attributes.relation.description
		self.secondaryLabel.isHidden = false

		self.tertiaryLabel.text = self.durationText(for: relationship)
		self.tertiaryLabel.isHidden = self.tertiaryLabel.text == nil

		self.applyRank(nil, showsRank: false)
		self.setHorizontalStyle(true)
		self.updateLabelsStackVisibility()

		relatedPerson.attributes.profileImage(imageView: self.imageView)
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
			&& self.tertiaryLabel.isHidden
			&& self.rankLabel.isHidden
	}

	/// Returns the year span of the given relationship.
	///
	/// - Parameter relationship: The relationship whose span is formatted.
	///
	/// - Returns: The formatted year span.
	private func durationText(for relationship: PersonRelationship) -> String? {
		guard let startedAt = relationship.attributes.startedAt else { return nil }

		let calendar = Calendar.current
		let startYear = calendar.component(.year, from: startedAt)

		if let endedAt = relationship.attributes.endedAt {
			let endYear = calendar.component(.year, from: endedAt)
			return L10n.yearRange(String(startYear), String(endYear))
		}

		return L10n.yearRange(String(startYear), L10n.present)
	}

	/// Arranges the avatar and labels vertically or horizontally.
	///
	/// - Parameter isHorizontal: Whether the avatar sits beside the labels.
	private func setHorizontalStyle(_ isHorizontal: Bool) {
		self.contentStackView.axis = isHorizontal ? .horizontal : .vertical
		self.contentStackView.alignment = isHorizontal ? .top : .fill
		self.labelsStackView.alignment = isHorizontal ? .leading : .center

		if isHorizontal {
			self.labelsStackView.insertArrangedSubview(self.secondaryLabel, at: 0)
		} else {
			self.labelsStackView.insertArrangedSubview(self.rankLabel, at: 0)
			self.labelsStackView.insertArrangedSubview(self.primaryLabel, at: 1)
			self.labelsStackView.insertArrangedSubview(self.secondaryLabel, at: 2)
			self.labelsStackView.insertArrangedSubview(self.tertiaryLabel, at: 3)
		}

		let textAlignment: NSTextAlignment = isHorizontal ? .natural : .center
		self.primaryLabel.textAlignment = textAlignment
		self.secondaryLabel.textAlignment = textAlignment
		self.tertiaryLabel.textAlignment = textAlignment

		self.avatarWidthConstraint?.isActive = isHorizontal
	}
}

// MARK: - Measurement
extension ProfileLockupCollectionViewCell {
	/// Returns the item that measures the given character.
	///
	/// - Parameters:
	///    - character: The character the item measures.
	///    - rank: The rank of the character in a ranked list.
	///
	/// - Returns: The item that measures the character.
	static func measurableItem(for character: Character, rank: Int? = nil) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: ProfileLockupCollectionViewCell.self) { cell in
			cell.configure(using: character, rank: rank)
		}
	}

	/// Returns the item that measures the given person.
	///
	/// - Parameters:
	///    - person: The person the item measures.
	///    - detail: The text shown in place of the role.
	///    - rank: The rank of the person in a ranked list.
	///
	/// - Returns: The item that measures the person.
	static func measurableItem(for person: Person, detail: String? = nil, rank: Int? = nil) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: ProfileLockupCollectionViewCell.self) { cell in
			cell.configure(using: person, detail: detail, rank: rank)
		}
	}

	/// Returns the item that measures the given person relationship.
	///
	/// - Parameter relationship: The relationship the item measures.
	///
	/// - Returns: The item that measures the relationship.
	static func measurableItem(for relationship: PersonRelationship) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: ProfileLockupCollectionViewCell.self) { cell in
			cell.configure(using: relationship)
		}
	}
}
