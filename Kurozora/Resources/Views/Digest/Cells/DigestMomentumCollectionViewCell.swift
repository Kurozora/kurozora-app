//
//  DigestMomentumCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A full-bleed band that summarises the user's week in big-number stats.
class DigestMomentumCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let containerStackView = UIStackView()
	private let captionLabel = KSecondaryLabel()
	private let statsView = DigestMomentumStatsView()
	private let notesStackView = UIStackView()
	private let seeReCapButton = KTintedButton()

	// MARK: - Properties
	/// The closure run when the user taps the Re:CAP button.
	var seeReCapHandler: (() -> Void)?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureCell()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureCell()
	}

	// MARK: - Functions
	/// Configures the band with the week's stats.
	///
	/// - Parameters:
	///    - stats: The primary big-number stats, each a value paired with its label.
	///    - notes: The supporting lines, such as the milestone and streak.
	func configure(stats: [(value: String, label: String)], notes: [String]) {
		self.captionLabel.text = L10n.digestMomentumCaption
		self.statsView.configure(with: stats)

		self.notesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for note in notes {
			let noteLabel = KLabel()
			noteLabel.font = .preferredFont(forTextStyle: .subheadline).semibold
			noteLabel.adjustsFontForContentSizeCategory = true
			noteLabel.textAlignment = .center
			noteLabel.numberOfLines = 0
			noteLabel.text = note
			self.notesStackView.addArrangedSubview(noteLabel)
		}
		self.notesStackView.isHidden = notes.isEmpty

		self.seeReCapButton.setTitle(L10n.digestSeeReCap, for: .normal)
	}

	/// Builds the band's view hierarchy and constraints.
	private func configureCell() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		self.captionLabel.textAlignment = .center

		self.notesStackView.axis = .vertical
		self.notesStackView.alignment = .center
		self.notesStackView.spacing = 24.0

		self.seeReCapButton.addAction(UIAction { [weak self] _ in
			self?.seeReCapHandler?()
		}, for: .touchUpInside)

		self.containerStackView.translatesAutoresizingMaskIntoConstraints = false
		self.containerStackView.axis = .vertical
		self.containerStackView.alignment = .center
		self.containerStackView.spacing = 24.0
		self.containerStackView.addArrangedSubview(self.captionLabel)
		self.containerStackView.addArrangedSubview(self.statsView)
		self.containerStackView.addArrangedSubview(self.notesStackView)
		self.containerStackView.addArrangedSubview(self.seeReCapButton)
		self.contentView.addSubview(self.containerStackView)

		// The background fills the cell edge to edge; the content stays inside the safe area so the
		// notch or Dynamic Island never occludes it.
		let contentGuide = self.contentView.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			self.containerStackView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 32.0),
			self.containerStackView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -32.0),
			self.containerStackView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: 24.0),
			self.containerStackView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: -24.0),
			self.statsView.widthAnchor.constraint(equalTo: self.containerStackView.widthAnchor),
		])
	}
}
