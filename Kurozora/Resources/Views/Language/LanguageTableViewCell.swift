//
//  LanguageTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A language and the ways a title supports it.
class LanguageTableViewCell: UITableViewCell {
	// MARK: - Properties
	static let reuseID = "LanguageTableViewCell"

	private let nameLabel: KLabel = {
		let label = KLabel()
		label.font = .preferredFont(forTextStyle: .headline)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let markerLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.setContentHuggingPriority(.defaultLow, for: .horizontal)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let typeStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 6.0
		stackView.alignment = .leading
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the cell.
	private func sharedInit() {
		self.selectionStyle = .none
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		let headerStackView = UIStackView(arrangedSubviews: [self.nameLabel, self.markerLabel])
		headerStackView.axis = .horizontal
		headerStackView.spacing = 8.0
		headerStackView.alignment = .firstBaseline
		headerStackView.translatesAutoresizingMaskIntoConstraints = false

		let containerStackView = UIStackView(arrangedSubviews: [headerStackView, self.typeStackView])
		containerStackView.axis = .vertical
		containerStackView.spacing = 8.0
		containerStackView.alignment = .leading
		containerStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(containerStackView)

		NSLayoutConstraint.activate([
			containerStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12.0),
			containerStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12.0),
			containerStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			containerStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -16.0)
		])
	}

	/// Configure the cell with the given language.
	///
	/// - Parameters:
	///    - name: The name of the language.
	///    - types: The ways the language is supported.
	///    - marker: The label marking the language.
	///    - isViewerLanguage: Whether the language is the viewer's own.
	func configure(name: String, types: [LanguageSupportType], marker: String?, isViewerLanguage: Bool) {
		self.nameLabel.text = name
		self.markerLabel.text = marker
		self.markerLabel.isHidden = marker == nil
		self.markerLabel.theme_textColor = isViewerLanguage
			? KThemePicker.tintColor.rawValue
			: KThemePicker.subTextColor.rawValue

		self.typeStackView.arrangedSubviews.forEach {
			self.typeStackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}

		for type in types.sorted(by: { $0.rawValue < $1.rawValue }) {
			self.typeStackView.addArrangedSubview(self.makeChip(for: type))
		}
	}

	/// Builds a chip for the given support type.
	///
	/// - Parameter type: The support type the chip reads.
	///
	/// - Returns: A chip for the support type.
	private func makeChip(for type: LanguageSupportType) -> UIView {
		let label = KLabel()
		label.text = type.stringValue
		label.font = .preferredFont(forTextStyle: .footnote)
		label.translatesAutoresizingMaskIntoConstraints = false

		let chipView = UIView()
		chipView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		chipView.layerCornerRadius = 6.0
		chipView.translatesAutoresizingMaskIntoConstraints = false
		chipView.addSubview(label)

		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: chipView.topAnchor, constant: 3.0),
			label.bottomAnchor.constraint(equalTo: chipView.bottomAnchor, constant: -3.0),
			label.leadingAnchor.constraint(equalTo: chipView.leadingAnchor, constant: 8.0),
			label.trailingAnchor.constraint(equalTo: chipView.trailingAnchor, constant: -8.0)
		])

		return chipView
	}
}
