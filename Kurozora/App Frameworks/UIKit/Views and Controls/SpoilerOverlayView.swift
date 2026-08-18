//
//  SpoilerOverlayView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A blurred cover that withholds spoiler material until the reader asks for it.
class SpoilerOverlayView: UIView {
	// MARK: - Views
	private let blurView: KVisualEffectView = {
		let visualEffectView = KVisualEffectView(effect: nil)
		visualEffectView.translatesAutoresizingMaskIntoConstraints = false
		return visualEffectView
	}()

	private let warningLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote).bold
		label.theme_textColor = KThemePicker.textColor.rawValue
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()

	// MARK: - Properties
	/// The handler called when the reader reveals the covered content.
	var revealHandler: (() -> Void)?

	/// The space between the warning and the cover's edges.
	private static let warningInset: CGFloat = 12.0

	/// The duration of the reveal animation.
	private static let revealDuration: TimeInterval = 0.2

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
	/// Configures the cover with the warning it shows.
	///
	/// - Parameters:
	///    - warning: The warning shown in place of the covered content.
	///    - cornerRadius: The corner radius the cover is rounded to.
	func configure(warning: String, cornerRadius: CGFloat) {
		self.warningLabel.text = warning
		self.blurView.layerCornerRadius = cornerRadius
	}

	/// Uncovers the content behind the cover.
	func reveal() {
		UIView.animate(withDuration: Self.revealDuration) {
			self.alpha = 0
		} completion: { _ in
			self.isHidden = true
			self.alpha = 1
			self.revealHandler?()
		}
	}

	private func configureSubviews() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.isHidden = true

		self.addSubview(self.blurView)
		self.blurView.contentView.addSubview(self.warningLabel)

		NSLayoutConstraint.activate([
			self.blurView.topAnchor.constraint(equalTo: self.topAnchor),
			self.blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

			self.warningLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.blurView.contentView.leadingAnchor, constant: Self.warningInset),
			self.warningLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.blurView.contentView.trailingAnchor, constant: -Self.warningInset),
			self.warningLabel.centerXAnchor.constraint(equalTo: self.blurView.contentView.centerXAnchor),
			self.warningLabel.centerYAnchor.constraint(equalTo: self.blurView.contentView.centerYAnchor)
		])

		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.coverTapped)))
	}

	@objc private func coverTapped() {
		self.reveal()
	}
}
