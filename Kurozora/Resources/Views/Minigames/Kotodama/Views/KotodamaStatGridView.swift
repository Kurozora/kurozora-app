//
//  KotodamaStatGridView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaStatGridView: UIView {
	// MARK: - Views
	private let rowsStackView = UIStackView()

	// MARK: - Properties
	/// Whether each value sits inside its own bordered tile, above its name.
	var showsTiles: Bool = false

	private var stats: [KotodamaStat] = []
	private var renderedColumnCount = 0

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

		guard self.columnCount(fitting: self.bounds.width) != self.renderedColumnCount else { return }

		self.rebuild()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.rowsStackView.translatesAutoresizingMaskIntoConstraints = false
		self.rowsStackView.axis = .vertical
		self.rowsStackView.alignment = .fill
		self.rowsStackView.distribution = .fillEqually
		self.rowsStackView.spacing = 10
		self.addSubview(self.rowsStackView)

		NSLayoutConstraint.activate([
			self.rowsStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.rowsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.rowsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.rowsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}

	/// Configures the grid with the given values.
	///
	/// - Parameter stats: The values to show.
	func configure(using stats: [KotodamaStat]) {
		self.stats = stats

		self.rebuild()
	}

	/// Lays the values out across the number of columns the current width allows.
	private func rebuild() {
		self.rowsStackView.arrangedSubviews.forEach {
			self.rowsStackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}

		guard !self.stats.isEmpty else { return }

		let columnCount = self.columnCount(fitting: self.bounds.width)
		self.renderedColumnCount = columnCount

		for chunkStart in stride(from: 0, to: self.stats.count, by: columnCount) {
			let chunk = self.stats[chunkStart..<min(chunkStart + columnCount, self.stats.count)]
			let rowStackView = UIStackView()
			rowStackView.axis = .horizontal
			rowStackView.alignment = .fill
			rowStackView.distribution = .fillEqually
			rowStackView.spacing = 10

			for stat in chunk {
				rowStackView.addArrangedSubview(self.makeStatView(for: stat))
			}

			// Keeps a short final row's columns the same width as the rows above it.
			for _ in chunk.count..<columnCount {
				rowStackView.addArrangedSubview(UIView())
			}

			self.rowsStackView.addArrangedSubview(rowStackView)
		}
	}

	/// Returns how many columns fit in the given width.
	///
	/// The values step between one row, two rows and a single column, never an uneven three.
	///
	/// - Parameter width: The width available to the grid.
	///
	/// - Returns: The number of columns to lay the values out in.
	private func columnCount(fitting width: CGFloat) -> Int {
		let minimumWidth: CGFloat = self.showsTiles ? 132 : 84

		for columns in [4, 2] {
			let spacing = CGFloat(columns - 1) * 10
			if (width - spacing) / CGFloat(columns) >= minimumWidth {
				return columns
			}
		}

		return 1
	}

	/// Returns a view showing one value.
	///
	/// - Parameter stat: The value to show.
	///
	/// - Returns: The view to add to a row.
	private func makeStatView(for stat: KotodamaStat) -> UIView {
		let valueLabel = UILabel()
		valueLabel.text = stat.value
		valueLabel.font = .monospacedDigitSystemFont(ofSize: self.showsTiles ? 22 : 20, weight: .bold)
		valueLabel.adjustsFontSizeToFitWidth = true
		valueLabel.minimumScaleFactor = 0.6
		valueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

		let titleLabel = UILabel()
		titleLabel.text = stat.title
		titleLabel.numberOfLines = 2
		titleLabel.font = .preferredFont(forTextStyle: .caption2)
		titleLabel.adjustsFontForContentSizeCategory = true
		titleLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue

		let stackView = UIStackView(arrangedSubviews: self.showsTiles
			? [valueLabel, titleLabel]
			: [titleLabel, valueLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.spacing = 2

		guard self.showsTiles else {
			return stackView
		}

		valueLabel.textAlignment = .center
		titleLabel.textAlignment = .center

		let containerView = UIView()
		containerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		containerView.layer.cornerCurve = .continuous
		containerView.layer.cornerRadius = 4
		containerView.layer.borderWidth = 1
		containerView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		containerView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
			stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
			stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
		])

		return containerView
	}
}
