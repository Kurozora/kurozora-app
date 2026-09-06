//
//  EditorialCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A card rendering the app's own editorial endorsement of an item.
class EditorialCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let captionLabel: KTintedLabel = {
		let label = KTintedLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote).bold
		label.adjustsFontForContentSizeCategory = true
		label.text = L10n.editorsChoice
		return label
	}()

	private let bodyLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = .preferredFont(forTextStyle: .body)
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private let bylineLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

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
	/// Configures the cell with the given editorial.
	///
	/// - Parameter editorial: The editorial to display.
	func configure(using editorial: Editorial) {
		self.bodyLabel.text = editorial.attributes.body
		self.bylineLabel.text = editorial.attributes.byline ?? L10n.kurozoraEditors
	}

	private func configureSubviews() {
		self.contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 10

		let outerStack = UIStackView(arrangedSubviews: [self.captionLabel, self.bodyLabel, self.bylineLabel])
		outerStack.translatesAutoresizingMaskIntoConstraints = false
		outerStack.axis = .vertical
		outerStack.spacing = 8

		self.contentView.addSubview(outerStack)

		NSLayoutConstraint.activate([
			outerStack.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			outerStack.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			outerStack.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			outerStack.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
		])
	}
}

// MARK: - Measurement
extension EditorialCollectionViewCell {
	/// Returns the item that measures the given editorial.
	///
	/// - Parameter editorial: The editorial the item measures.
	///
	/// - Returns: The item that measures the editorial.
	static func measurableItem(for editorial: Editorial) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: EditorialCollectionViewCell.self) { cell in
			cell.configure(using: editorial)
		}
	}
}
