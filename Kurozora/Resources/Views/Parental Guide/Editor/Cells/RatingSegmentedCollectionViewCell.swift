//
//  RatingSegmentedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol RatingSegmentedCollectionViewCellDelegate: AnyObject {
	func ratingSegmentedCollectionViewCell(_ cell: RatingSegmentedCollectionViewCell, didSelect rating: ParentalGuideRating?)
}

class RatingSegmentedCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let segmentedControl: DeselectableSegmentedControl = {
		let control = DeselectableSegmentedControl(items: ParentalGuideRating.allCases.map(\.stringValue))
		control.translatesAutoresizingMaskIntoConstraints = false
		control.selectedSegmentIndex = UISegmentedControl.noSegment
		return control
	}()

	// MARK: - Properties
	weak var delegate: RatingSegmentedCollectionViewCellDelegate?

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
	/// Configures the cell with the selected rating.
	///
	/// - Parameters:
	///    - selected: The currently selected rating.
	///    - delegate: The delegate that receives change events.
	func configure(selected: ParentalGuideRating?, delegate: RatingSegmentedCollectionViewCellDelegate?) {
		self.hideSkeleton()
		self.delegate = delegate

		if let selected, let index = ParentalGuideRating.allCases.firstIndex(of: selected) {
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
		let rating = ParentalGuideRating.allCases[safe: self.segmentedControl.selectedSegmentIndex]
		self.delegate?.ratingSegmentedCollectionViewCell(self, didSelect: rating)
	}
}
