//
//  KotodamaKeyboardView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol KotodamaKeyboardViewDelegate: AnyObject {
	/// Tells the delegate that a key was pressed.
	///
	/// - Parameters:
	///    - keyboardView: The keyboard the key belongs to.
	///    - key: The key that was pressed.
	func keyboardView(_ keyboardView: KotodamaKeyboardView, didPress key: KotodamaKey)
}

class KotodamaKeyboardView: UIView {
	// MARK: - Views
	private let rowsStackView = UIStackView()

	// MARK: - Properties
	/// The object that acts as the delegate of the keyboard.
	weak var delegate: KotodamaKeyboardViewDelegate?

	/// The number of keys in the longest row.
	static var columnCount: CGFloat {
		return CGFloat(KotodamaKey.rows.map(\.count).max() ?? 10)
	}

	/// The width beyond which the letter keys stop growing.
	static var maximumWidth: CGFloat {
		let columns = Self.columnCount
		return columns * KotodamaKey.maximumLetterWidth + (columns - 1) * KotodamaKey.spacing
	}

	private var keyViews: [KotodamaKeyView] = []

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

		self.updateKeyWidths()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.rowsStackView.translatesAutoresizingMaskIntoConstraints = false
		self.rowsStackView.axis = .vertical
		self.rowsStackView.alignment = .center
		self.rowsStackView.distribution = .fill
		self.rowsStackView.spacing = KotodamaKey.spacing
		self.addSubview(self.rowsStackView)

		NSLayoutConstraint.activate([
			self.rowsStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.rowsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.rowsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
			self.rowsStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
			self.rowsStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
		])

		self.buildKeys()
	}

	/// Configures the keyboard with the feedback gathered so far.
	///
	/// - Parameter feedback: The strongest feedback per letter.
	func configure(using feedback: [Swift.Character: KotodamaTileFeedback]) {
		for keyView in self.keyViews {
			switch keyView.key {
			case .letter(let letter):
				keyView.configure(using: keyView.key, feedback: feedback[letter])
			case .submit, .delete:
				keyView.configure(using: keyView.key, feedback: nil)
			}
		}
	}

	/// Builds a key view for every key on the keyboard.
	private func buildKeys() {
		for row in KotodamaKey.rows {
			let rowStackView = UIStackView()
			rowStackView.axis = .horizontal
			rowStackView.alignment = .fill
			rowStackView.distribution = .fill
			rowStackView.spacing = KotodamaKey.spacing
			self.rowsStackView.addArrangedSubview(rowStackView)

			for key in row {
				let keyView = KotodamaKeyView()
				keyView.configure(using: key, feedback: nil)
				keyView.addTarget(self, action: #selector(self.keyPressed(_:)), for: .touchUpInside)
				rowStackView.addArrangedSubview(keyView)
				self.keyViews.append(keyView)
			}
		}
	}

	/// Sizes every letter key against the width available to the keyboard.
	///
	/// The delete and submit keys are square instead, so they keep the width their own
	/// `widthConstraint` was created with.
	private func updateKeyWidths() {
		let columns = Self.columnCount
		let available = self.bounds.width - (columns - 1) * KotodamaKey.spacing
		let width = min(KotodamaKey.maximumLetterWidth, (available / columns).rounded(.down))

		guard width > 0 else { return }

		for keyView in self.keyViews where keyView.key.isLetter {
			guard keyView.widthConstraint.constant != width else { continue }

			keyView.widthConstraint.constant = width
		}
	}

	/// Forwards a key press to the delegate.
	///
	/// - Parameter sender: The key view that was pressed.
	@objc private func keyPressed(_ sender: KotodamaKeyView) {
		self.playHapticFeedback(for: sender.key)
		self.delegate?.keyboardView(self, didPress: sender.key)
	}

	/// Plays the haptic feedback of the given key.
	///
	/// Action keys feel distinct from letters, mirroring the system keyboard.
	///
	/// - Parameter key: The key that was pressed.
	private func playHapticFeedback(for key: KotodamaKey) {
		guard UserSettings.hapticsAllowed else { return }

		switch key {
		case .letter:
			UISelectionFeedbackGenerator().selectionChanged()
		case .submit, .delete:
			UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
		}
	}
}
