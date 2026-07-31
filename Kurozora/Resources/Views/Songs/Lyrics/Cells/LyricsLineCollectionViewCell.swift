//
//  LyricsLineCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

final class LyricsLineCollectionViewCell: UITableViewCell {
	// MARK: - Views
	private let lineView = KaraokeLineView()

	private let backgroundLineView: KaraokeLineView = {
		let view = KaraokeLineView()
		view.fontScale = 0.65
		view.alpha = 0.85
		view.isHidden = true
		return view
	}()

	private let translationLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = LyricsLayout.translationFont
		label.theme_textColor = KThemePicker.subTextColor.rawValue
		return label
	}()

	private let stackView = UIStackView()

	// MARK: - Properties
	private var isActiveLine = false
	private var hasWordTiming = false
	private var hasBackground = false
	private var isHovered = false
	private var isScrollSuppressed = false
	private var isStatic = false
	private var blurRadius: CGFloat = 0

	private var cachedBlurRadius: CGFloat = -1
	private var cachedBlurFilter: NSObject?

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.configureSubviews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()
		self.isHovered = false
		self.isScrollSuppressed = false
		self.isStatic = false
	}

	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
		let lineWidth = targetSize.width - 2 * LyricsLayout.horizontalInset
		self.lineView.preferredMaxLayoutWidth = lineWidth
		self.backgroundLineView.preferredMaxLayoutWidth = lineWidth
		return super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
	}

	// MARK: - Functions
	private func configureSubviews() {
		self.backgroundColor = .clear
		self.selectionStyle = .none

		self.stackView.axis = .vertical
		self.stackView.spacing = LyricsLayout.translationSpacing
		self.stackView.alignment = .fill
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.stackView.addArrangedSubview(self.lineView)
		self.stackView.addArrangedSubview(self.backgroundLineView)
		self.stackView.addArrangedSubview(self.translationLabel)
		self.contentView.addSubview(self.stackView)

		NSLayoutConstraint.activate([
			self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: LyricsLayout.topInset),
			self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -LyricsLayout.bottomInset),
			self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: LyricsLayout.horizontalInset),
			self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -LyricsLayout.horizontalInset),
		])

		self.contentView.addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(self.handleHover)))
	}

	/// Configures the cell for a line.
	///
	/// - Parameters:
	///    - pairs: The timed word pairs of the line.
	///    - backgroundPairs: The timed word pairs of the line's background vocals.
	///    - hasWordTiming: Whether the line carries per-word timing.
	///    - translationText: The line's translation text.
	///    - offsetMs: The global timing offset applied to every word.
	///    - alignment: The horizontal alignment for the line and its translation.
	func configure(pairs: [KaraokeWordPair], backgroundPairs: [KaraokeWordPair], hasWordTiming: Bool, translationText: String?, offsetMs: Int, alignment: NSTextAlignment) {
		self.hasWordTiming = hasWordTiming
		self.lineView.textAlignment = alignment
		self.lineView.configure(pairs: pairs, offsetMs: offsetMs)

		self.hasBackground = !backgroundPairs.isEmpty
		self.backgroundLineView.textAlignment = alignment
		self.backgroundLineView.configure(pairs: backgroundPairs, offsetMs: offsetMs)

		self.translationLabel.textAlignment = alignment
		self.translationLabel.text = translationText
		self.translationLabel.isHidden = translationText?.isEmpty ?? true

		self.updateBackgroundVisibility()
	}

	/// Shows the background vocal line only while the line is active.
	private func updateBackgroundVisibility() {
		self.backgroundLineView.isHidden = !self.hasBackground || !(self.isActiveLine || self.isStatic)
	}

	/// Sets the line's active state and its inactive blur radius.
	///
	/// - Parameters:
	///    - isActive: Whether the line is the currently sung line.
	///    - blurRadius: The blur radius for the line's text.
	func setActive(_ isActive: Bool, blurRadius: CGFloat) {
		self.isStatic = false
		self.isActiveLine = isActive
		self.blurRadius = blurRadius

		self.applyFillState()
		self.updateBackgroundVisibility()
		self.updateBlur()
	}

	/// Reveals every line in the sung color for unsynced playback, without blur or interaction.
	func setStaticReveal() {
		self.isStatic = true
		self.isActiveLine = false
		self.blurRadius = 0

		self.lineView.setFullyRevealed()
		self.backgroundLineView.setFullyRevealed()
		self.updateBackgroundVisibility()
		self.updateBlur()
	}

	/// Applies the fill state for an inactive line.
	private func applyFillState() {
		guard !self.isActiveLine, !self.isStatic else { return }

		if self.isHovered {
			self.lineView.setFullyRevealed()
		} else {
			self.lineView.setUnrevealed()
		}
	}

	/// Suppresses the text blur while scrolling.
	///
	/// - Parameter suppressed: Whether the blur should be lifted.
	func setScrollSuppressed(_ suppressed: Bool) {
		guard self.isScrollSuppressed != suppressed else { return }
		self.isScrollSuppressed = suppressed
		self.updateBlur()
	}

	/// Advances the word-fill of the active line to the given playback position.
	///
	/// - Parameter ms: The playback position in milliseconds.
	func setProgress(ms: Int) {
		guard self.isActiveLine else { return }

		if self.hasWordTiming {
			self.lineView.setProgress(ms: ms)
			self.backgroundLineView.setProgress(ms: ms)
		} else {
			self.lineView.setFullyRevealed()
			self.backgroundLineView.setFullyRevealed()
		}
	}

	private func updateBlur() {
		let shouldBlur = !self.isActiveLine && !self.isStatic && self.blurRadius > 0 && !self.isHovered && !self.isScrollSuppressed

		if shouldBlur, let blurFilter = self.blurFilter(radius: self.blurRadius) {
			self.stackView.layer.filters = [blurFilter]
		} else {
			self.stackView.layer.filters = nil
		}
	}

	/// Returns a cached gaussian-blur filter for the given radius.
	///
	/// - Parameter radius: The blur radius in points.
	///
	/// - Returns: The filter for the radius.
	private func blurFilter(radius: CGFloat) -> NSObject? {
		if radius != self.cachedBlurRadius {
			self.cachedBlurFilter = GaussianBlur.filter(radius: radius)
			self.cachedBlurRadius = radius
		}
		return self.cachedBlurFilter
	}

	@objc private func handleHover(_ recognizer: UIHoverGestureRecognizer) {
		guard !self.isStatic else { return }

		switch recognizer.state {
		case .began, .changed:
			self.isHovered = true
		default:
			self.isHovered = false
		}

		self.applyFillState()
		self.updateBlur()
	}
}
