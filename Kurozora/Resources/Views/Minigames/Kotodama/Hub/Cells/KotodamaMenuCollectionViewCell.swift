//
//  KotodamaMenuCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaMenuCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let rowView = KotodamaMenuRowView()

	// MARK: - Properties
	override var isHighlighted: Bool {
		didSet {
			self.rowView.isHighlighted = self.isHighlighted
		}
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared init of the cell.
	private func sharedInit() {
		self.rowView.isUserInteractionEnabled = false
		self.contentView.addSubview(self.rowView)

		NSLayoutConstraint.activate([
			self.rowView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.rowView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.rowView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.rowView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
		])
	}

	/// Configures the cell with the given mode.
	///
	/// - Parameter mode: The mode the cell opens.
	func configure(using mode: KotodamaMode) {
		self.rowView.configure(
			symbolName: mode.symbolName,
			title: mode.stringValue,
			subtitle: mode.detailStringValue
		)
	}
}
