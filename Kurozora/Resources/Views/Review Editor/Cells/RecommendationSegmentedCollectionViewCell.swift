//
//  RecommendationSegmentedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol RecommendationSegmentedCollectionViewCellDelegate: AnyObject {
	func recommendationSegmentedCollectionViewCell(_ cell: RecommendationSegmentedCollectionViewCell, didSelect recommendation: ReviewRecommendation?)
}

class RecommendationSegmentedCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let titleLabel = KLabel()

	private let segmentedControl: DeselectableSegmentedControl = {
		let control = DeselectableSegmentedControl(items: ReviewRecommendation.offeredOrder.map(\.localizedName))
		control.translatesAutoresizingMaskIntoConstraints = false
		control.selectedSegmentIndex = UISegmentedControl.noSegment
		return control
	}()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	weak var delegate: RecommendationSegmentedCollectionViewCellDelegate?

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
	/// Configures the cell with the selected recommendation.
	///
	/// - Parameters:
	///    - selected: The currently selected recommendation.
	///    - delegate: The delegate that receives change events.
	func configure(selected: ReviewRecommendation?, delegate: RecommendationSegmentedCollectionViewCellDelegate?) {
		self.hideSkeleton()
		self.delegate = delegate

		if let selected, let index = ReviewRecommendation.offeredOrder.firstIndex(of: selected) {
			self.segmentedControl.selectedSegmentIndex = index
		} else {
			self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
		}
	}

	private func configureSubviews() {
		self.backgroundColor = .clear
		self.contentView.directionalLayoutMargins = .zero

		self.titleLabel.text = L10n.reviewRecommendation
		self.titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.titleLabel.adjustsFontForContentSizeCategory = true

		let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.segmentedControl])
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
		])

		self.segmentedControl.addTarget(self, action: #selector(self.valueChanged), for: .valueChanged)
	}

	@objc private func valueChanged() {
		let recommendation = ReviewRecommendation.offeredOrder[safe: self.segmentedControl.selectedSegmentIndex]

		self.delegate?.recommendationSegmentedCollectionViewCell(self, didSelect: recommendation)
	}
}
