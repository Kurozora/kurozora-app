//
//  FrequencySegmentedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol FrequencySegmentedCollectionViewCellDelegate: AnyObject {
	func frequencySegmentedCollectionViewCell(_ cell: FrequencySegmentedCollectionViewCell, didSelect frequency: ParentalGuideFrequency?)
}

class FrequencySegmentedCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let segmentedControl: DeselectableSegmentedControl = {
		let control = DeselectableSegmentedControl(items: ParentalGuideFrequency.allCases.map(\.stringValue))
		control.translatesAutoresizingMaskIntoConstraints = false
		control.selectedSegmentIndex = UISegmentedControl.noSegment
		return control
	}()

	// MARK: - Properties
	weak var delegate: FrequencySegmentedCollectionViewCellDelegate?

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
	/// Configures the cell with the selected frequency.
	///
	/// - Parameters:
	///    - selected: The currently selected frequency.
	///    - delegate: The delegate that receives change events.
	func configure(selected: ParentalGuideFrequency?, delegate: FrequencySegmentedCollectionViewCellDelegate?) {
		self.hideSkeleton()
		self.delegate = delegate

		if let selected, let index = ParentalGuideFrequency.allCases.firstIndex(of: selected) {
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
		let frequency = ParentalGuideFrequency.allCases[safe: self.segmentedControl.selectedSegmentIndex]
		self.delegate?.frequencySegmentedCollectionViewCell(self, didSelect: frequency)
	}
}
