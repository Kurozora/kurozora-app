//
//  EmojiRatingView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftTheme
import UIKit

protocol EmojiRatingViewDelegate: AnyObject {
	/// Tells the delegate the user picked an emoji.
	///
	/// - Parameters:
	///    - emojiRatingView: The view the user interacted with.
	///    - rating: The rating the pick maps to. `0` when the pick was cleared.
	func emojiRatingView(_ emojiRatingView: EmojiRatingView, rateWith rating: Double)
}

/// A row of emoji that rates an item with a single tap.
final class EmojiRatingView: UIView {
	// MARK: - Properties
	weak var delegate: EmojiRatingViewDelegate?

	/// The emoji scores in order of increasing sentiment.
	private let emojiScores: [EmojiScore] = [.disliked, .neutral, .liked]

	/// The emoji score matching the view's rating.
	private(set) var selectedEmojiScore: EmojiScore?

	/// Whether picking the selected emoji again clears the rating.
	var allowsDeselection: Bool = true

	/// Whether picking an emoji requires a signed in user.
	var requiresAuthentication: Bool = true

	private var buttons: [UIButton] = []

	/// The diameter of an emoji button.
	static let buttonSize: CGFloat = 48.0

	/// The space between two emoji buttons.
	private static let buttonSpacing: CGFloat = 8.0

	/// The point size of an emoji.
	private static let emojiFontSize: CGFloat = 30.0

	// MARK: - Initializers
	init() {
		super.init(frame: .zero)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - Functions
	/// Configures the view with the given rating.
	///
	/// - Parameter rating: The rating to reflect. `nil` when the item is unrated.
	func configure(using rating: Double?) {
		self.selectedEmojiScore = EmojiScore(rating: rating)
		self.updateButtonAppearance()
	}

	private func configureSubviews() {
		self.buttons = self.emojiScores.enumerated().map { index, emojiScore in
			let button = UIButton(type: .custom)
			button.tag = index
			button.setTitle(emojiScore.emoji, for: .normal)
			button.accessibilityLabel = emojiScore.localizedDescription
			button.titleLabel?.font = .systemFont(ofSize: Self.emojiFontSize)
			button.layerCornerRadius = Self.buttonSize / 2.0
			button.translatesAutoresizingMaskIntoConstraints = false
			button.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)

			NSLayoutConstraint.activate([
				button.widthAnchor.constraint(equalToConstant: Self.buttonSize),
				button.heightAnchor.constraint(equalToConstant: Self.buttonSize)
			])

			return button
		}

		let stackView = UIStackView(arrangedSubviews: self.buttons)
		stackView.axis = .horizontal
		stackView.spacing = Self.buttonSpacing
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])

		self.updateButtonAppearance()
	}

	/// Dims the emoji that were not picked and tints the one that was.
	private func updateButtonAppearance() {
		let selectedEmojiScore = self.selectedEmojiScore

		for (index, button) in self.buttons.enumerated() {
			button.isSelected = self.emojiScores[index] == selectedEmojiScore
			button.alpha = selectedEmojiScore == nil || button.isSelected ? 1.0 : 0.5
			self.applyBackground(to: button)
		}
	}

	/// Draws the background of the button's current state.
	private func applyBackground(to button: UIButton) {
		guard button.isSelected else {
			button.theme_backgroundColor = nil
			button.backgroundColor = .clear
			return
		}

		button.backgroundColor = nil
		button.theme_backgroundColor = KThemePicker.tintedBackgroundColor.rawValue
	}

	// MARK: - Actions
	@objc private func buttonPressed(_ sender: UIButton) {
		guard let emojiScore = self.emojiScores[safe: sender.tag] else { return }

		Task { [weak self] in
			guard let self = self else { return }

			if self.requiresAuthentication {
				let signedIn = await WorkflowController.shared.isSignedIn()
				guard signedIn else { return }
			}

			let isDeselecting = self.allowsDeselection && emojiScore == self.selectedEmojiScore
			self.selectedEmojiScore = isDeselecting ? nil : emojiScore
			self.updateButtonAppearance()

			self.delegate?.emojiRatingView(self, rateWith: isDeselecting ? 0.0 : emojiScore.score)
		}
	}
}
