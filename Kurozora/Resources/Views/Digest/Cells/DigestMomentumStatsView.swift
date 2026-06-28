//
//  DigestMomentumStatsView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Lays out the momentum stat blocks in a centered row, wrapping onto further rows when they don't fit.
final class DigestMomentumStatsView: UIView {
	// MARK: - Views
	private var statViews: [UIView] = []

	// MARK: - Properties
	private var heightConstraint: NSLayoutConstraint!
	private let horizontalSpacing: CGFloat = 24.0
	private let verticalSpacing: CGFloat = 16.0

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		let height = self.reflow(in: self.bounds.width, apply: true)
		if abs(self.heightConstraint.constant - height) > 0.5 {
			self.heightConstraint.constant = height
		}
	}

	// MARK: - Functions
	/// Rebuilds the stat blocks from the given value/label pairs.
	///
	/// - Parameter stats: The big-number stats, each a value paired with its label.
	func configure(with stats: [(value: String, label: String)]) {
		self.statViews.forEach { $0.removeFromSuperview() }
		self.statViews = stats.map { self.makeStatView(value: $0.value, label: $0.label) }
		self.statViews.forEach { self.addSubview($0) }
		self.setNeedsLayout()
	}

	/// Activates the self-sizing height constraint.
	private func configureView() {
		self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 0.0)
		self.heightConstraint.isActive = true
	}

	/// Positions the stat blocks into centered, wrapping rows and returns the total height.
	@discardableResult
	private func reflow(in width: CGFloat, apply: Bool) -> CGFloat {
		guard width > 0.0, !self.statViews.isEmpty else { return 0.0 }

		var rows: [[(view: UIView, size: CGSize)]] = [[]]
		var rowWidth: CGFloat = 0.0

		for statView in self.statViews {
			let size = statView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
			let startsRow = rows[rows.count - 1].isEmpty
			let projectedWidth = rowWidth + (startsRow ? 0.0 : self.horizontalSpacing) + size.width

			if !startsRow, projectedWidth > width {
				rows.append([])
				rowWidth = 0.0
			}

			let isFirst = rows[rows.count - 1].isEmpty
			rows[rows.count - 1].append((statView, size))
			rowWidth += (isFirst ? 0.0 : self.horizontalSpacing) + size.width
		}

		var y: CGFloat = 0.0
		for row in rows {
			let totalWidth = row.reduce(0.0) { $0 + $1.size.width } + CGFloat(max(0, row.count - 1)) * self.horizontalSpacing
			let rowHeight = row.map { $0.size.height }.max() ?? 0.0
			var x = (width - totalWidth) / 2.0

			for item in row {
				if apply {
					item.view.frame = CGRect(x: x, y: y, width: item.size.width, height: item.size.height)
				}
				x += item.size.width + self.horizontalSpacing
			}

			y += rowHeight + self.verticalSpacing
		}

		return max(0.0, y - self.verticalSpacing)
	}

	/// Builds a single stat block pairing a big-number value with its label.
	private func makeStatView(value: String, label: String) -> UIView {
		let valueLabel = KLabel()
		valueLabel.font = .preferredFont(forTextStyle: .title1).bold
		valueLabel.adjustsFontForContentSizeCategory = true
		valueLabel.textAlignment = .center
		valueLabel.text = value

		let descriptionLabel = KSecondaryLabel()
		descriptionLabel.adjustsFontForContentSizeCategory = true
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = label

		let statStackView = UIStackView(arrangedSubviews: [valueLabel, descriptionLabel])
		statStackView.axis = .vertical
		statStackView.alignment = .center
		statStackView.spacing = 2.0
		return statStackView
	}
}
