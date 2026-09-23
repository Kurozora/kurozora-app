//
//  ReCapHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class ReCapHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let textView: UITextView = {
		let textStorage = NSTextStorage()
		let layoutManager = NSLayoutManager()
		let textContainer = NSTextContainer(size: .zero)
		textStorage.addLayoutManager(layoutManager)
		layoutManager.addTextContainer(textContainer)
		return UITextView(frame: .zero, textContainer: textContainer)
	}()

	/// The letters of the rolling text drawn over the title.
	private var letterViews: [UIView] = []

	// MARK: - Properties
	/// The title of the header.
	private var title: String?

	/// The text that rolls into place.
	private var rollingText: String?

	/// Whether the rolling text finished animating for the current title.
	private var hasRolled = false

	/// The size the letters were laid out for.
	private var laidOutSize: CGSize = .zero

	/// The font of the title.
	private var titleFont: UIFont {
		return UIFont.preferredFont(forTextStyle: .title2).semibold
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

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentView.layoutIfNeeded()

		guard self.textView.bounds.size != self.laidOutSize else { return }
		self.layoutLetters()
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window != nil {
			self.roll()
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.removeLetters()
		self.title = nil
		self.rollingText = nil
		self.hasRolled = false
	}

	// MARK: - Functions
	private func sharedInit() {
		self.textView.isEditable = false
		self.textView.isSelectable = false
		self.textView.isScrollEnabled = false
		self.textView.backgroundColor = .clear
		self.textView.textContainerInset = .zero
		self.textView.textContainer.lineFragmentPadding = 0.0
		self.textView.textContainer.widthTracksTextView = true
		self.textView.adjustsFontForContentSizeCategory = true
		self.textView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.textView)

		NSLayoutConstraint.activate([
			self.textView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 40.0),
			self.textView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10.0),
			self.textView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10.0),
			self.textView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -40.0),
		])
	}

	/// Configures the cell with the given title.
	///
	/// - Parameters:
	///    - title: The title of the header.
	///    - rollingText: The part of the title that rolls into place.
	func configure(using title: String, rollingText: String? = nil) {
		let rollingText = UIAccessibility.isReduceMotionEnabled ? nil : rollingText

		if self.title != title || self.rollingText != rollingText {
			self.hasRolled = false
		}

		self.title = title
		self.rollingText = rollingText
		self.textView.accessibilityLabel = title
		self.textView.attributedText = self.attributedTitle(isRollingTextHidden: !self.hasRolled)
		self.removeLetters()
		self.setNeedsLayout()
	}

	/// Returns the styled title.
	///
	/// - Parameter isRollingTextHidden: Whether the rolling text is left out of the title.
	///
	/// - Returns: The styled title.
	private func attributedTitle(isRollingTextHidden: Bool) -> NSAttributedString {
		let title = self.title ?? ""
		let attributedTitle = NSMutableAttributedString(string: title, attributes: [
			.font: self.titleFont,
			.foregroundColor: KThemePicker.subTextColor.colorValue,
		])

		if let rollingRange = self.rollingRange {
			attributedTitle.addAttribute(.foregroundColor, value: isRollingTextHidden ? UIColor.clear : KThemePicker.textColor.colorValue, range: rollingRange)
		}

		return attributedTitle
	}

	/// The range of the rolling text in the title.
	private var rollingRange: NSRange? {
		guard
			let title = self.title,
			let rollingText = self.rollingText,
			let range = title.range(of: rollingText, options: .backwards)
		else { return nil }

		return NSRange(range, in: title)
	}

	/// Rolls the letters of the rolling text into place.
	func roll() {
		guard !self.hasRolled, !self.letterViews.isEmpty else { return }
		self.hasRolled = true

		for (index, letterView) in self.letterViews.enumerated() {
			guard let letterLabel = letterView.subviews.first else { continue }

			let animator = UIViewPropertyAnimator(duration: 0.9, controlPoint1: CGPoint(x: 0.22, y: 1.0), controlPoint2: CGPoint(x: 0.36, y: 1.0)) {
				letterLabel.transform = .identity
			}
			animator.startAnimation(afterDelay: 0.15 + Double(index) * 0.07)
		}
	}

	/// Removes the letters of the rolling text.
	private func removeLetters() {
		self.letterViews.forEach { $0.removeFromSuperview() }
		self.letterViews = []
		self.laidOutSize = .zero
	}

	/// Places a clipped letter over each character of the rolling text.
	private func layoutLetters() {
		self.letterViews.forEach { $0.removeFromSuperview() }
		self.letterViews = []
		self.laidOutSize = self.textView.bounds.size

		guard let rollingRange = self.rollingRange, self.laidOutSize.width > 0.0 else { return }

		if self.hasRolled {
			self.textView.attributedText = self.attributedTitle(isRollingTextHidden: false)
			return
		}

		let layoutManager = self.textView.layoutManager
		let textContainer = self.textView.textContainer
		let origin = self.textView.frame.origin
		let title = (self.title ?? "") as NSString
		layoutManager.ensureLayout(for: textContainer)

		title.enumerateSubstrings(in: rollingRange, options: .byComposedCharacterSequences) { letter, letterRange, _, _ in
			guard let letter else { return }

			let glyphRange = layoutManager.glyphRange(forCharacterRange: letterRange, actualCharacterRange: nil)
			var letterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
			letterRect.origin.x += origin.x
			letterRect.origin.y += origin.y

			let letterView = UIView(frame: letterRect)
			letterView.clipsToBounds = true
			letterView.isUserInteractionEnabled = false

			let letterLabel = UILabel(frame: letterView.bounds)
			letterLabel.attributedText = NSAttributedString(string: letter, attributes: [
				.font: self.titleFont,
				.foregroundColor: KThemePicker.textColor.colorValue,
			])
			letterLabel.transform = CGAffineTransform(translationX: 0.0, y: letterRect.height)
			letterView.addSubview(letterLabel)

			self.contentView.addSubview(letterView)
			self.letterViews.append(letterView)
		}

		if self.window != nil {
			self.roll()
		}
	}
}
