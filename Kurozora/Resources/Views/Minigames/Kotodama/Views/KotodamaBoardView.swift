//
//  KotodamaBoardView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaBoardView: UIView {
	// MARK: - Views
	private let rowsStackView = UIStackView()

	// MARK: - Properties
	private var tileViews: [[KotodamaTileView]] = []
	private var renderedRows: [[KotodamaTileState]] = []

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
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.rowsStackView.translatesAutoresizingMaskIntoConstraints = false
		self.rowsStackView.axis = .vertical
		self.rowsStackView.alignment = .center
		self.rowsStackView.distribution = .fill
		self.rowsStackView.spacing = KotodamaTileView.spacing
		self.addSubview(self.rowsStackView)

		NSLayoutConstraint.activate([
			self.rowsStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.rowsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.rowsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.rowsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}

	/// Configures the board with the given rows.
	///
	/// - Parameters:
	///    - rows: The rows to render.
	///    - animated: Whether newly revealed tiles should flip.
	func configure(using rows: [[KotodamaTileState]], animated: Bool) {
		if self.tileViews.count != rows.count || self.tileViews.first?.count != rows.first?.count {
			self.rebuild(rowCount: rows.count, columnCount: rows.first?.count ?? 0)
		}

		for (rowIndex, row) in rows.enumerated() {
			guard rowIndex < self.tileViews.count else { continue }
			let previousRow = rowIndex < self.renderedRows.count ? self.renderedRows[rowIndex] : []

			for (columnIndex, state) in row.enumerated() {
				guard columnIndex < self.tileViews[rowIndex].count else { continue }
				let previousState = columnIndex < previousRow.count ? previousRow[columnIndex] : .empty

				guard previousState != state else { continue }

				self.tileViews[rowIndex][columnIndex].configure(using: state, animated: animated)
			}
		}

		self.renderedRows = rows
	}

	/// Shakes the given row to signal a rejected guess.
	///
	/// - Parameter rowIndex: The index of the row to shake.
	func shakeRow(at rowIndex: Int) {
		guard rowIndex >= 0, rowIndex < self.rowsStackView.arrangedSubviews.count else { return }

		let rowView = self.rowsStackView.arrangedSubviews[rowIndex]
		let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
		animation.values = [0, -10, 10, -6, 6, 0]
		animation.duration = 0.4
		animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
		rowView.layer.add(animation, forKey: "shake")
	}

	/// Rebuilds the tiles for the given dimensions.
	///
	/// - Parameters:
	///    - rowCount: The number of rows.
	///    - columnCount: The number of tiles per row.
	private func rebuild(rowCount: Int, columnCount: Int) {
		self.rowsStackView.arrangedSubviews.forEach {
			self.rowsStackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}

		self.tileViews = []
		self.renderedRows = []

		for _ in 0..<rowCount {
			let rowStackView = UIStackView()
			rowStackView.axis = .horizontal
			rowStackView.alignment = .center
			rowStackView.distribution = .fill
			rowStackView.spacing = KotodamaTileView.spacing

			var row: [KotodamaTileView] = []

			for _ in 0..<columnCount {
				let tileView = KotodamaTileView()
				rowStackView.addArrangedSubview(tileView)
				row.append(tileView)
			}

			self.tileViews.append(row)
			self.rowsStackView.addArrangedSubview(rowStackView)
		}
	}
}
