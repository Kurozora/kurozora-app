//
//  DepictionSegmentedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol DepictionSegmentedCollectionViewCellDelegate: AnyObject {
	func depictionSegmentedCollectionViewCell(_ cell: DepictionSegmentedCollectionViewCell, didSelect depiction: ParentalGuideDepiction?)
}

class DepictionSegmentedCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let segmentedControl: DeselectableSegmentedControl = {
		let control = DeselectableSegmentedControl(items: ParentalGuideDepiction.allCases.map(\.stringValue))
		control.translatesAutoresizingMaskIntoConstraints = false
		control.selectedSegmentIndex = UISegmentedControl.noSegment
		return control
	}()

	// MARK: - Properties
	weak var delegate: DepictionSegmentedCollectionViewCellDelegate?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - Functions
	/// Configures the cell with the selected depiction.
	///
	/// - Parameters:
	///    - selected: The currently selected depiction.
	///    - delegate: The delegate that receives change events.
	func configure(selected: ParentalGuideDepiction?, delegate: DepictionSegmentedCollectionViewCellDelegate?) {
		self.hideSkeleton()
		self.delegate = delegate

		if let depiction = selected, let index = ParentalGuideDepiction.allCases.firstIndex(of: depiction) {
			self.segmentedControl.selectedSegmentIndex = index
		} else {
			self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
		}
	}

	private func configureSubviews() {
		self.contentView.addSubview(self.segmentedControl)

		NSLayoutConstraint.activate([
			self.segmentedControl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.segmentedControl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.segmentedControl.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.segmentedControl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
		])

		self.segmentedControl.addTarget(self, action: #selector(self.valueChanged), for: .valueChanged)
	}

	@objc private func valueChanged() {
		let depiction = ParentalGuideDepiction.allCases[safe: self.segmentedControl.selectedSegmentIndex]
		self.delegate?.depictionSegmentedCollectionViewCell(self, didSelect: depiction)
	}
}
