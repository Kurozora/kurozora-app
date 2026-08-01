//
//  MuseumTitleView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

class MuseumTitleView: UIView {
	// MARK: - Views
	/// The heading label showing the Museum title.
	private let titleLabel = UILabel()

	/// The year button beside the heading, carrying the decade menu.
	private let yearButton = UIButton(type: .system)

	/// The collection-scale caption beneath the heading.
	private let captionLabel = UILabel()

	/// The vertical stack holding the heading row and the caption.
	private let contentStackView = UIStackView()

	// MARK: - Properties
	/// The duration of one leg of the caption's cross-fade.
	private static let captionFadeDuration: TimeInterval = 0.15

	/// The spacing between the heading label and the year button.
	private static let headingSpacing: CGFloat = 4.0

	/// The pending caption cross-fade task.
	private var captionFadeTask: Task<Void, Never>?

	/// The menu presented by the year button.
	var yearMenu: UIMenu? {
		get {
			return self.yearButton.menu
		}
		set {
			self.yearButton.menu = newValue
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

	// MARK: - View
	override var intrinsicContentSize: CGSize {
		let titleSize = self.titleLabel.intrinsicContentSize
		let yearSize = self.yearButton.isHidden ? .zero : self.yearButton.intrinsicContentSize
		let captionSize = self.captionLabel.intrinsicContentSize
		let headingHeight = max(titleSize.height, yearSize.height)

		return CGSize(width: UIView.layoutFittingExpandedSize.width, height: headingHeight + captionSize.height)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass else { return }
		self.updateAlignment()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		let headlineFont = UIFont.preferredFont(forTextStyle: .headline)

		self.titleLabel.font = UIFont.systemFont(ofSize: headlineFont.pointSize, weight: .bold)
		self.titleLabel.text = L10n.museum
		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.titleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}

		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 9.0, weight: .bold))
		configuration.imagePlacement = .trailing
		configuration.imagePadding = 2.0
		configuration.contentInsets = .zero
		self.yearButton.configuration = configuration
		self.yearButton.showsMenuAsPrimaryAction = true
		self.yearButton.isHidden = true

		self.captionLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .semibold)
		self.captionLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		let headingStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.yearButton])
		headingStackView.axis = .horizontal
		headingStackView.alignment = .center
		headingStackView.spacing = Self.headingSpacing

		self.contentStackView.addArrangedSubview(headingStackView)
		self.contentStackView.addArrangedSubview(self.captionLabel)
		self.contentStackView.axis = .vertical
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.contentStackView)

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
		])

		self.updateAlignment()
		self.restyle()
	}

	/// Aligns the text for the current orientation.
	private func updateAlignment() {
		let isCentered = self.traitCollection.verticalSizeClass == .compact
		self.contentStackView.alignment = isCentered ? .center : .leading
		self.captionLabel.textAlignment = isCentered ? .center : .left
	}

	/// Shows the given year on the year button, hiding the button when absent.
	///
	/// - Parameter year: The year to show.
	func setYear(_ year: Int?) {
		guard let year = year else {
			self.yearButton.configuration?.attributedTitle = nil
			self.yearButton.isHidden = true
			self.invalidateIntrinsicContentSize()
			return
		}

		var attributedTitle = AttributedString(String(year))
		attributedTitle.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
		self.yearButton.configuration?.attributedTitle = attributedTitle
		self.yearButton.isHidden = false
		self.invalidateIntrinsicContentSize()
	}

	/// Sets the caption, cross-fading the swap when requested.
	///
	/// - Parameters:
	///    - text: The caption to show.
	///    - crossFade: Whether to fade the caption out and back in around the swap.
	func setCaption(_ text: String, crossFade: Bool) {
		guard crossFade else {
			self.captionLabel.text = text
			self.invalidateIntrinsicContentSize()
			return
		}

		self.captionFadeTask?.cancel()

		UIView.animate(withDuration: Self.captionFadeDuration) {
			self.captionLabel.alpha = 0.0
		}

		self.captionFadeTask = Task { [weak self] in
			do {
				try await Task.sleep(nanoseconds: 150_000_000)
			} catch {
				return
			}

			guard let self = self else { return }
			self.captionLabel.text = text
			self.invalidateIntrinsicContentSize()

			UIView.animate(withDuration: Self.captionFadeDuration) {
				self.captionLabel.alpha = 1.0
			}
		}
	}

	/// Re-applies the theme's colors to the year button.
	func restyle() {
		self.yearButton.configuration?.baseForegroundColor = KThemePicker.subTextColor.colorValue
	}
}
