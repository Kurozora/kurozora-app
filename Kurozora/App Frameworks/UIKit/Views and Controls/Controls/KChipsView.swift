//
//  KChipsView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A horizontally scrolling row of selectable chips, drawn as a tinted pill that slides behind the selected title.
///
/// - Tag: KChipsView
final class KChipsView: UIScrollView {
	// MARK: - Properties
	/// The margin the selected chip's pill lines up with, matching the content's own margin.
	private static let horizontalInset: CGFloat = 10.0

	/// The padding the pill adds either side of a chip's title.
	private static let chipPadding: CGFloat = 12.0

	/// The height of the pill drawn behind a chip.
	private static let chipHeight: CGFloat = 32.0

	/// The height the row asks for when hosted in a navigation bar palette.
	static let paletteHeight: CGFloat = 48.0

	// MARK: - Views
	/// The row of chips that receives touches.
	private let chipStackView = UIStackView()

	/// The row of chips drawn over the pill, masked to it.
	private let tintedChipStackView = UIStackView()

	/// The tinted pill drawn behind the selected chip.
	private let selectionView = UIView()

	/// The mask clipping the tinted row to the selected chip.
	private let selectionMaskView = UIView()

	// MARK: - Properties
	/// The chip titles in display order.
	var titles: [String] = [] {
		didSet {
			self.rebuildChips()
		}
	}

	/// The index of the selected chip.
	private(set) var selectedIndex = 0

	/// Whether no chip is shown as selected.
	var isSelectionHidden = false {
		didSet {
			self.selectionView.isHidden = self.isSelectionHidden
			self.tintedChipStackView.isHidden = self.isSelectionHidden
		}
	}

	/// Called with the index of the chip the user picks.
	var chipSelectedHandler: ((Int) -> Void)?

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

		self.chipStackView.layoutIfNeeded()

		UIView.performWithoutAnimation {
			self.layoutSelection()
		}
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.alwaysBounceHorizontal = true
		self.showsHorizontalScrollIndicator = false
		self.contentInsetAdjustmentBehavior = .always
		let contentInset = Self.horizontalInset + Self.chipPadding
		self.contentInset = UIEdgeInsets(top: 0.0, left: contentInset, bottom: 0.0, right: contentInset)

		self.configureStackView(self.chipStackView)
		self.configureSelectionView()
		self.configureStackView(self.tintedChipStackView)

		self.tintedChipStackView.isUserInteractionEnabled = false
		self.tintedChipStackView.mask = self.selectionMaskView

		self.selectionMaskView.backgroundColor = .black
		self.selectionMaskView.clipsToBounds = true
		self.selectionMaskView.layer.cornerCurve = .continuous

		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.chipTapped(_:))))

		self.restyle()
	}

	/// Pins the given row of chips to the scroll view's content.
	///
	/// - Parameter stackView: The row to pin.
	private func configureStackView(_ stackView: UIStackView) {
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.spacing = Self.chipPadding * 2.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.contentLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.contentLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.contentLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.contentLayoutGuide.bottomAnchor),
			stackView.heightAnchor.constraint(equalTo: self.frameLayoutGuide.heightAnchor),
		])
	}

	/// Adds the tinted pill above the row taking the touches.
	private func configureSelectionView() {
		self.selectionView.clipsToBounds = true
		self.selectionView.layer.cornerCurve = .continuous
		self.insertSubview(self.selectionView, aboveSubview: self.chipStackView)
	}

	/// Re-applies the theme's colors to the chips and the pill.
	func restyle() {
		self.selectionView.backgroundColor = KThemePicker.tintColor.colorValue

		for case let chipLabel as UILabel in self.chipStackView.arrangedSubviews {
			chipLabel.textColor = KThemePicker.textColor.colorValue
		}

		for case let chipLabel as UILabel in self.tintedChipStackView.arrangedSubviews {
			chipLabel.textColor = KThemePicker.tintedButtonTextColor.colorValue
		}
	}

	/// Selects the chip at the given index.
	///
	/// - Parameters:
	///    - index: The index of the chip to select.
	///    - animated: Whether the pill animates to the chip.
	func selectChip(at index: Int, animated: Bool) {
		guard self.titles.indices.contains(index) else { return }
		self.selectedIndex = index

		guard animated else {
			UIView.performWithoutAnimation {
				self.layoutSelection()
			}
			return
		}

		UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .allowUserInteraction]) {
			self.layoutSelection()
			self.scrollSelectionIntoView()
		}
	}

	/// Brings the selected chip into view when the row overflows.
	private func scrollSelectionIntoView() {
		// `scrollRectToVisible(_:animated:)` ignores the content inset, which leaves the row short of its
		// resting edge when the first chip comes back into view.
		guard let pillFrame = self.pillFrame(at: self.selectedIndex) else { return }

		let leadingInset = self.adjustedContentInset.left
		let trailingInset = self.adjustedContentInset.right
		let minimumOffsetX = -leadingInset
		let maximumOffsetX = max(minimumOffsetX, self.contentSize.width - self.bounds.width + trailingInset)
		var offsetX = self.contentOffset.x

		if pillFrame.minX - leadingInset < offsetX {
			offsetX = pillFrame.minX - leadingInset
		} else if pillFrame.maxX + trailingInset > offsetX + self.bounds.width {
			offsetX = pillFrame.maxX + trailingInset - self.bounds.width
		}

		self.contentOffset.x = min(max(offsetX, minimumOffsetX), maximumOffsetX)
	}

	/// Rebuilds both rows of chips for the current titles.
	private func rebuildChips() {
		for arrangedSubview in self.chipStackView.arrangedSubviews + self.tintedChipStackView.arrangedSubviews {
			arrangedSubview.removeFromSuperview()
		}

		for title in self.titles {
			self.chipStackView.addArrangedSubview(self.chipLabel(title: title, textColor: KThemePicker.textColor.colorValue))
			self.tintedChipStackView.addArrangedSubview(self.chipLabel(title: title, textColor: KThemePicker.tintedButtonTextColor.colorValue))
		}

		if !self.titles.indices.contains(self.selectedIndex) {
			self.selectedIndex = 0
		}

		self.contentOffset.x = -self.adjustedContentInset.left
		self.setNeedsLayout()
	}

	/// Returns a chip title drawn in the given color.
	///
	/// - Parameters:
	///    - title: The title of the chip.
	///    - textColor: The color of the title.
	///
	/// - Returns: A chip title.
	private func chipLabel(title: String, textColor: UIColor) -> UILabel {
		let chipLabel = UILabel()
		chipLabel.text = title
		chipLabel.textColor = textColor
		chipLabel.font = .systemFont(ofSize: 13.0, weight: .semibold)
		chipLabel.setContentHuggingPriority(.required, for: .horizontal)
		chipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		return chipLabel
	}

	/// The pill sized around the chip at the given index.
	///
	/// - Parameter index: The index of the chip.
	///
	/// - Returns: The pill's frame.
	private func pillFrame(at index: Int) -> CGRect? {
		guard let chipLabel = self.chipStackView.arrangedSubviews[safe: index] else { return nil }

		return CGRect(
			x: chipLabel.frame.minX - Self.chipPadding,
			y: ((self.bounds.height - Self.chipHeight) / 2.0).rounded(),
			width: chipLabel.frame.width + Self.chipPadding * 2.0,
			height: Self.chipHeight
		)
	}

	/// Moves the pill and its mask onto the selected chip.
	private func layoutSelection() {
		guard let pillFrame = self.pillFrame(at: self.selectedIndex) else { return }

		let cornerRadius = pillFrame.height / 2.0
		self.selectionView.layer.cornerRadius = cornerRadius
		self.selectionView.frame = pillFrame
		self.selectionMaskView.layer.cornerRadius = cornerRadius
		self.selectionMaskView.frame = pillFrame
	}

	/// Handles a chip being tapped.
	///
	/// - Parameter sender: The recognizer that fired.
	@objc private func chipTapped(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: self)

		let tappedIndex = self.chipStackView.arrangedSubviews.indices.first { index in
			self.pillFrame(at: index)?.contains(location) ?? false
		}

		guard let index = tappedIndex, index != self.selectedIndex || self.isSelectionHidden else { return }

		self.selectChip(at: index, animated: true)
		self.chipSelectedHandler?(index)
	}
}
