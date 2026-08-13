//
//  KotodamaTileView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaTileView: UIView {
	// MARK: - Views
	private let letterLabel = UILabel()

	/// The marker shown in the corner when the system asks to differentiate without color.
	private let markerImageView = UIImageView()

	// MARK: - Properties
	/// The width and height of a tile.
	static let side: CGFloat = 48

	/// The gap between tiles, and between rows of tiles.
	static let spacing: CGFloat = 4

	/// The inset of the color-blind marker from the tile's top-right corner.
	private let markerInset: CGFloat = 3

	/// The width and height of the color-blind marker.
	private let markerSide: CGFloat = 8

	private var state: KotodamaTileState = .empty

	/// The token observing changes to the system's "Differentiate without color" setting.
	private var differentiateWithoutColorObserver: NSObjectProtocol?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	deinit {
		if let differentiateWithoutColorObserver {
			NotificationCenter.default.removeObserver(differentiateWithoutColorObserver)
		}
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.layer.borderWidth = 2
		self.layer.cornerCurve = .continuous
		self.layer.cornerRadius = 4

		self.letterLabel.translatesAutoresizingMaskIntoConstraints = false
		self.letterLabel.textAlignment = .center
		self.letterLabel.adjustsFontSizeToFitWidth = true
		self.letterLabel.minimumScaleFactor = 0.5
		self.letterLabel.font = .systemFont(ofSize: 18, weight: .bold)
		self.addSubview(self.letterLabel)

		self.markerImageView.translatesAutoresizingMaskIntoConstraints = false
		self.markerImageView.tintColor = KotodamaPalette.revealedLetter
		self.markerImageView.contentMode = .scaleAspectFit
		self.markerImageView.isHidden = true
		self.addSubview(self.markerImageView)

		NSLayoutConstraint.activate([
			self.letterLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.letterLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.letterLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
			self.letterLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2),
			self.widthAnchor.constraint(equalToConstant: Self.side),
			self.heightAnchor.constraint(equalToConstant: Self.side),
			self.markerImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.markerInset),
			self.markerImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.markerInset),
			self.markerImageView.widthAnchor.constraint(equalToConstant: self.markerSide),
			self.markerImageView.heightAnchor.constraint(equalToConstant: self.markerSide)
		])

		self.apply(state: .empty)

		self.differentiateWithoutColorObserver = NotificationCenter.default.addObserver(
			forName: UIAccessibility.differentiateWithoutColorDidChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.updateMarker()
		}
	}

	/// Configures the tile with the given state.
	///
	/// - Parameters:
	///    - state: The state to render.
	///    - animated: Whether the change should flip the tile.
	func configure(using state: KotodamaTileState, animated: Bool) {
		let wasRevealed = self.state.feedback != nil
		self.state = state

		guard animated, !wasRevealed, state.feedback != nil else {
			self.apply(state: state)
			return
		}

		UIView.transition(with: self, duration: 0.28, options: [.transitionFlipFromBottom], animations: {
			self.apply(state: state)
		}, completion: nil)
	}

	/// Draws the given state.
	///
	/// - Parameter state: The state to render.
	private func apply(state: KotodamaTileState) {
		self.letterLabel.text = state.letter.map { String($0) } ?? ""

		// Every unrevealed tile looks the same, typed into or not.
		guard let feedback = state.feedback else {
			self.backgroundColor = nil
			self.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
			self.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
			self.letterLabel.theme_textColor = KThemePicker.textColor.rawValue
			self.updateMarker()
			return
		}

		let color = KotodamaPalette.color(for: feedback)
		self.theme_backgroundColor = nil
		self.backgroundColor = color
		self.layer.theme_borderColor = nil
		self.layer.borderColor = color.cgColor
		self.letterLabel.theme_textColor = nil
		self.letterLabel.textColor = KotodamaPalette.revealedLetter
		self.updateMarker()
	}

	/// Shows or hides the color-blind marker for the tile's current feedback.
	private func updateMarker() {
		guard UIAccessibility.shouldDifferentiateWithoutColor, let feedback = self.state.feedback else {
			self.markerImageView.isHidden = true
			return
		}

		switch feedback {
		case .hit:
			self.markerImageView.image = UIImage(systemName: "circle.fill")
			self.markerImageView.isHidden = false
		case .present:
			self.markerImageView.image = UIImage(systemName: "circle")
			self.markerImageView.isHidden = false
		case .miss:
			self.markerImageView.isHidden = true
		}
	}
}
