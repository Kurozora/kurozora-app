//
//  ReCapCardCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A Re:CAP card.
class ReCapCardCollectionViewCell: KCollectionViewCell {
	// MARK: - Types
	/// The surface a card is drawn on.
	enum Surface {
		case secondary
		case blur
	}

	// MARK: - Properties
	/// The corner radius of the card.
	static let cornerRadius: CGFloat = 22.0

	/// The surface the card is drawn on.
	var surface: Surface {
		return .secondary
	}

	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Views
	/// The view the card's content is placed in.
	let cardView = UIView()

	private let borderView = BorderView()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: Self.cornerRadius).cgPath
	}

	// MARK: - Functions
	private func sharedInit() {
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 0.1
		self.layer.shadowRadius = 4.0
		self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)

		self.cardView.clipsToBounds = true
		self.cardView.layer.cornerRadius = Self.cornerRadius
		self.cardView.layer.cornerCurve = .continuous
		self.cardView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.cardView)
		self.cardView.fillToSuperview()

		switch self.surface {
		case .secondary:
			self.cardView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		case .blur:
			self.cardView.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		}

		self.borderView.cornerRadius = Self.cornerRadius
		self.borderView.isUserInteractionEnabled = false
		self.borderView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.borderView)
		self.borderView.fillToSuperview()
	}
}
