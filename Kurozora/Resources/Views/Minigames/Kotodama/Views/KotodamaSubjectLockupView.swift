//
//  KotodamaSubjectLockupView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// The lockup of the catalog entry behind a finished game's answer.
class KotodamaSubjectLockupView: UIView {
	// MARK: - Properties
	/// The width of a lockup laid out as a portrait tile.
	private let tileWidth: CGFloat = 140

	/// The width beyond which a lockup laid out as a row stops growing.
	private let rowWidth: CGFloat = 384

	/// The hosted lockup.
	private var lockupCell: UICollectionViewCell?

	/// The constraints sizing the hosted lockup.
	private var lockupConstraints: [NSLayoutConstraint] = []

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.translatesAutoresizingMaskIntoConstraints = false
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.translatesAutoresizingMaskIntoConstraints = false
	}

	// MARK: - Functions
	/// Configures the view with the revealed subject.
	///
	/// - Parameter subject: The catalog entry behind the answer.
	func configure(using subject: KotodamaSubject) {
		switch subject {
		case .show(let show):
			let cell = self.host(SmallLockupCollectionViewCell.self, isRow: true)
			cell?.configure(using: show)
		case .literature(let literature):
			let cell = self.host(SmallLockupCollectionViewCell.self, isRow: true)
			cell?.configure(using: literature)
		case .game(let game):
			let cell = self.host(SmallLockupCollectionViewCell.self, isRow: true)
			cell?.configure(using: game)
		case .character(let character):
			let cell = self.host(ProfileLockupCollectionViewCell.self, isRow: false)
			cell?.configure(using: character, showsSubtitle: false, showsRank: false)
		case .person(let person):
			let cell = self.host(ProfileLockupCollectionViewCell.self, isRow: false)
			cell?.configure(using: person, showsSubtitle: false, showsRank: false)
		case .studio(let studio):
			let cell = self.host(StudioLockupCollectionViewCell.self, isRow: true)
			cell?.configure(using: studio)
		case .song(let song):
			let cell = self.host(MusicLockupCollectionViewCell.self, isRow: true)
			cell?.configure(using: song, at: IndexPath(item: 0, section: 0))
		}
	}

	/// Replaces the hosted lockup with one of the given type.
	///
	/// - Parameters:
	///    - cellType: The type of the lockup to host.
	///    - isRow: Whether the lockup is laid out as a row rather than a portrait tile.
	///
	/// - Returns: The hosted lockup.
	private func host<Cell: UICollectionViewCell>(_ cellType: Cell.Type, isRow: Bool) -> Cell? {
		NSLayoutConstraint.deactivate(self.lockupConstraints)
		self.lockupConstraints.removeAll()
		self.lockupCell?.removeFromSuperview()
		self.lockupCell = nil

		guard let cell = cellType.nib.instantiate(withOwner: nil).first as? Cell else { return nil }

		cell.translatesAutoresizingMaskIntoConstraints = false
		cell.isUserInteractionEnabled = false
		self.addSubview(cell)
		self.lockupCell = cell

		let widthConstraint = isRow
			? cell.widthAnchor.constraint(lessThanOrEqualToConstant: self.rowWidth)
			: cell.widthAnchor.constraint(equalToConstant: self.tileWidth)

		self.lockupConstraints = [
			cell.topAnchor.constraint(equalTo: self.topAnchor),
			cell.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			cell.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			cell.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
			cell.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
			widthConstraint
		]

		if isRow {
			let fillConstraint = cell.widthAnchor.constraint(equalTo: self.widthAnchor)
			fillConstraint.priority = .defaultHigh
			self.lockupConstraints.append(fillConstraint)
		}

		NSLayoutConstraint.activate(self.lockupConstraints)

		return cell
	}
}
