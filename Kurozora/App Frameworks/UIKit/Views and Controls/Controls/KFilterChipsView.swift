//
//  KFilterChipsView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A horizontally scrolling row of chips the user removes by tapping.
final class KFilterChipsView: UIScrollView {
	// MARK: - Views
	/// The row holding the chips.
	private let chipStackView = UIStackView()

	// MARK: - Properties
	/// The margin the row lines its chips up with.
	private static let horizontalInset: CGFloat = 10.0

	/// The height the row occupies below the search bar.
	static let rowHeight: CGFloat = 44.0

	/// The chip titles in display order.
	var titles: [NSAttributedString] = [] {
		didSet {
			self.rebuildChips()
		}
	}

	/// Called with the index of the chip the user removes.
	var chipRemovedHandler: ((Int) -> Void)?

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
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.showsHorizontalScrollIndicator = false
		self.showsVerticalScrollIndicator = false

		self.chipStackView.translatesAutoresizingMaskIntoConstraints = false
		self.chipStackView.axis = .horizontal
		self.chipStackView.spacing = 8.0
		self.chipStackView.alignment = .center
		self.chipStackView.distribution = .fill

		self.addSubview(self.chipStackView)

		NSLayoutConstraint.activate([
			self.chipStackView.leadingAnchor.constraint(equalTo: self.contentLayoutGuide.leadingAnchor, constant: Self.horizontalInset),
			self.chipStackView.trailingAnchor.constraint(equalTo: self.contentLayoutGuide.trailingAnchor, constant: -Self.horizontalInset),
			self.chipStackView.topAnchor.constraint(equalTo: self.contentLayoutGuide.topAnchor),
			self.chipStackView.bottomAnchor.constraint(equalTo: self.contentLayoutGuide.bottomAnchor),
			self.chipStackView.heightAnchor.constraint(equalTo: self.frameLayoutGuide.heightAnchor)
		])
	}

	/// Rebuilds the row from the current titles.
	private func rebuildChips() {
		self.chipStackView.arrangedSubviews.forEach { arrangedSubview in
			arrangedSubview.removeFromSuperview()
		}

		for (index, title) in self.titles.enumerated() {
			self.chipStackView.addArrangedSubview(self.makeChip(title: title, index: index))
		}
	}

	/// Returns a chip carrying the given title.
	///
	/// - Parameters:
	///    - title: The title the chip shows.
	///    - index: The position of the chip.
	///
	/// - Returns: The chip to add to the row.
	private func makeChip(title: NSAttributedString, index: Int) -> UIButton {
		var configuration = UIButton.Configuration.gray()
		configuration.attributedTitle = AttributedString(title)
		configuration.image = UIImage(systemName: "xmark", withConfiguration: Self.symbolConfiguration)
		configuration.imagePlacement = .trailing
		configuration.imagePadding = 6.0
		configuration.cornerStyle = .capsule
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 6.0, leading: 14.0, bottom: 6.0, trailing: 12.0)
		configuration.preferredSymbolConfigurationForImage = Self.symbolConfiguration
		configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = Self.titleFont
			return outgoing
		}

		let chipButton = KButton(configuration: configuration)
		chipButton.theme_tintColor = KThemePicker.tintColor.rawValue
		chipButton.setContentHuggingPriority(.required, for: .horizontal)
		chipButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		chipButton.addAction(UIAction { [weak self] _ in
			self?.chipRemovedHandler?(index)
		}, for: .touchUpInside)

		return chipButton
	}

	/// The size a chip's close mark is drawn at.
	private static var symbolConfiguration: UIImage.SymbolConfiguration {
		return UIImage.SymbolConfiguration(pointSize: 9.0, weight: .bold)
	}

	/// The font a chip's title is written in.
	private static var titleFont: UIFont {
		return UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 15.0, weight: .semibold))
	}
}
