//
//  RollingCounterView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A label whose digits roll to their new readings.
final class RollingCounterView: UIView {
	// MARK: - Views
	/// The row laying the characters out.
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .center
		stackView.spacing = 0.0
		return stackView
	}()

	/// The labels carrying one character each.
	private var characterLabels: [UILabel] = []

	// MARK: - Properties
	/// The font the reading is set in.
	private let font: UIFont

	/// The color the reading is set in.
	private let textColor: UIColor

	/// The reading on show.
	private(set) var text = ""

	/// The number the reading stands for.
	private var value = 0.0

	// MARK: - Initializers
	/// Creates a counter reading in the given style.
	///
	/// - Parameters:
	///    - font: The font the reading is set in.
	///    - textColor: The color the reading is set in.
	init(font: UIFont, textColor: UIColor) {
		self.font = font
		self.textColor = textColor
		super.init(frame: .zero)

		self.addSubview(self.stackView)

		NSLayoutConstraint.activate([
			self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Shows the given reading.
	///
	/// - Parameters:
	///    - text: The reading to show.
	///    - value: The number the reading stands for.
	///    - rolling: Whether the digits roll to the new reading.
	func setText(_ text: String, value: Double, rolling: Bool) {
		guard text != self.text else { return }

		let previousCharacters = Array(self.text)
		let previousValue = self.value
		self.text = text
		self.value = value

		let characters = Array(text)

		// A new length lays the reading out afresh rather than rolling it.
		guard rolling, characters.count == previousCharacters.count else {
			self.layOut(characters)
			return
		}

		let movesUp = value >= previousValue

		for (index, character) in characters.enumerated() where character != previousCharacters[index] {
			self.roll(self.characterLabels[index], to: character, movesUp: movesUp)
		}
	}

	/// Rolls one character to its new value with a short slide and fade.
	///
	/// - Parameters:
	///    - label: The label carrying the character.
	///    - character: The character to roll to.
	///    - movesUp: Whether the new character rises in.
	private func roll(_ label: UILabel, to character: Character, movesUp: Bool) {
		let travel: CGFloat = movesUp ? -4.0 : 4.0

		if let snapshotView = label.snapshotView(afterScreenUpdates: false) {
			snapshotView.frame = label.frame
			label.superview?.addSubview(snapshotView)

			UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut]) {
				snapshotView.alpha = 0.0
				snapshotView.transform = CGAffineTransform(translationX: 0.0, y: travel)
			} completion: { _ in
				snapshotView.removeFromSuperview()
			}
		}

		label.text = String(character)
		label.alpha = 0.0
		label.transform = CGAffineTransform(translationX: 0.0, y: -travel)

		UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut]) {
			label.alpha = 1.0
			label.transform = .identity
		}
	}

	/// Lays the reading out afresh, one label per character.
	///
	/// - Parameter characters: The characters to lay out.
	private func layOut(_ characters: [Character]) {
		for label in self.characterLabels {
			self.stackView.removeArrangedSubview(label)
			label.removeFromSuperview()
		}

		self.characterLabels = characters.map { character in
			let label = UILabel()
			label.font = self.font
			label.textColor = self.textColor
			label.textAlignment = .center
			label.text = String(character)
			return label
		}

		for label in self.characterLabels {
			self.stackView.addArrangedSubview(label)
		}
	}
}
