//
//  KotodamaKeyView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaKeyView: UIControl {
	// MARK: - Views
	private let titleLabel = UILabel()
	private let symbolImageView = UIImageView()

	// MARK: - Properties
	/// The key this view represents.
	private(set) var key: KotodamaKey = .letter("A")

	/// The constraint driving the key's width.
	private(set) lazy var widthConstraint: NSLayoutConstraint = self.widthAnchor.constraint(
		equalToConstant: self.key.isLetter ? KotodamaKey.maximumLetterWidth : KotodamaKey.height
	)

	/// The strongest feedback received for the key's letter.
	private var feedback: KotodamaTileFeedback?

	override var isHighlighted: Bool {
		didSet {
			self.applyBackground()
		}
	}

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
		self.layer.cornerCurve = .continuous
		self.layer.cornerRadius = 4

		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.textAlignment = .center
		self.titleLabel.adjustsFontSizeToFitWidth = true
		self.titleLabel.minimumScaleFactor = 0.6
		self.titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
		self.titleLabel.isUserInteractionEnabled = false
		self.addSubview(self.titleLabel)

		self.symbolImageView.translatesAutoresizingMaskIntoConstraints = false
		self.symbolImageView.contentMode = .center
		self.symbolImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
		self.symbolImageView.isUserInteractionEnabled = false
		self.addSubview(self.symbolImageView)

		NSLayoutConstraint.activate([
			self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 2),
			self.titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -2),
			self.symbolImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.symbolImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.heightAnchor.constraint(equalToConstant: KotodamaKey.height)
		])
	}

	/// Configures the key with the given value and feedback.
	///
	/// - Parameters:
	///    - key: The key to represent.
	///    - feedback: The strongest feedback received for the key's letter.
	func configure(using key: KotodamaKey, feedback: KotodamaTileFeedback?) {
		self.key = key
		self.accessibilityLabel = key.accessibilityLabel

		switch key {
		case .letter(let letter):
			self.titleLabel.text = String(letter)
			self.titleLabel.isHidden = false
			self.symbolImageView.isHidden = true
		case .submit:
			self.titleLabel.isHidden = true
			self.symbolImageView.isHidden = false
			self.symbolImageView.image = UIImage(systemName: "return")
		case .delete:
			self.titleLabel.isHidden = true
			self.symbolImageView.isHidden = false
			self.symbolImageView.image = UIImage(systemName: "delete.backward")
		}

		self.widthConstraint.isActive = true
		self.feedback = feedback

		switch key {
		case .submit:
			self.symbolImageView.theme_tintColor = KThemePicker.tintedButtonTextColor.rawValue
		case .delete:
			self.symbolImageView.theme_tintColor = KThemePicker.textColor.rawValue
		case .letter:
			if feedback == nil {
				self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue
			} else {
				self.titleLabel.theme_textColor = nil
				self.titleLabel.textColor = KotodamaPalette.revealedLetter
			}
		}

		self.applyBackground()
	}

	/// Draws the background of the key's current state.
	private func applyBackground() {
		if case .submit = self.key {
			self.backgroundColor = nil
			self.theme_backgroundColor = self.isHighlighted
				? KThemePicker.tintedBackgroundColor.rawValue
				: KThemePicker.tintColor.rawValue
			return
		}

		guard let feedback = self.feedback else {
			self.backgroundColor = nil
			self.theme_backgroundColor = self.isHighlighted
				? KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
				: KThemePicker.tableViewCellBackgroundColor.rawValue
			return
		}

		self.theme_backgroundColor = nil
		self.backgroundColor = KotodamaPalette.color(for: feedback)
			.withAlphaComponent(self.isHighlighted ? 0.7 : 1)
	}
}
