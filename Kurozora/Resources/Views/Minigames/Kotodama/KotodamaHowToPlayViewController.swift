//
//  KotodamaHowToPlayViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaHowToPlayViewController: KViewController {
	// MARK: - Views
	/// The bar button item that dismisses the screen.
	private var closeBarButtonItem: UIBarButtonItem!

	/// The scroll view holding the explanatory content.
	private var scrollView: UIScrollView!

	/// The vertical stack laying out the explanatory content.
	private var contentStackView: UIStackView!

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.kotodamaHowToPlay

		self.configureView()
	}

	// MARK: - Functions
	/// Configures the screen's views, hierarchy and constraints.
	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	/// Configures the screen's individual views.
	private func configureViews() {
		self.configureNavigationItems()
		self.configureScrollView()
		self.configureContentStackView()
	}

	/// Configures the scroll view.
	private func configureScrollView() {
		self.scrollView = UIScrollView()
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.contentInsetAdjustmentBehavior = .scrollableAxes
		self.scrollView.alwaysBounceVertical = true
	}

	/// Configures the content stack view and its arranged subviews.
	private func configureContentStackView() {
		let introLabel = self.makeBodyLabel(text: L10n.kotodamaHowToPlayIntro)
		let guessingLabel = self.makeBodyLabel(text: L10n.kotodamaHowToPlayGuessing)
		let colorsTitleLabel = self.makeHeadlineLabel(text: L10n.kotodamaHowToPlayColorsTitle)
		let hitRowView = self.makeLegendRow(letter: "K", feedback: .hit, description: L10n.kotodamaHowToPlayHit)
		let presentRowView = self.makeLegendRow(letter: "O", feedback: .present, description: L10n.kotodamaHowToPlayPresent)
		let missRowView = self.makeLegendRow(letter: "T", feedback: .miss, description: L10n.kotodamaHowToPlayMiss)
		let hintsLabel = self.makeBodyLabel(text: L10n.kotodamaHowToPlayHints)
		let dailyLabel = self.makeBodyLabel(text: L10n.kotodamaHowToPlayDaily)

		self.contentStackView = UIStackView(arrangedSubviews: [
			introLabel,
			guessingLabel,
			colorsTitleLabel,
			hitRowView,
			presentRowView,
			missRowView,
			hintsLabel,
			dailyLabel
		])
		self.contentStackView.axis = .vertical
		self.contentStackView.spacing = 16
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
	}

	/// Builds a wrapping body paragraph label.
	///
	/// - Parameter text: The paragraph's text.
	///
	/// - Returns: The configured label.
	private func makeBodyLabel(text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.numberOfLines = 0
		label.font = .preferredFont(forTextStyle: .body)
		label.adjustsFontForContentSizeCategory = true
		label.theme_textColor = KThemePicker.textColor.rawValue
		return label
	}

	/// Builds the legend section's heading label.
	///
	/// - Parameter text: The heading's text.
	///
	/// - Returns: The configured label.
	private func makeHeadlineLabel(text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.numberOfLines = 0
		label.font = .preferredFont(forTextStyle: .headline)
		label.adjustsFontForContentSizeCategory = true
		label.theme_textColor = KThemePicker.textColor.rawValue
		return label
	}

	/// Builds a legend row pairing a sample tile with its description.
	///
	/// - Parameters:
	///    - letter: The letter drawn on the sample tile.
	///    - feedback: The feedback the sample tile represents.
	///    - description: The text explaining the tile's meaning.
	///
	/// - Returns: A horizontal stack containing the sample tile and its description.
	private func makeLegendRow(letter: Swift.Character, feedback: KotodamaTileFeedback, description: String) -> UIView {
		let tileView = KotodamaTileView()
		tileView.configure(using: .revealed(letter: letter, feedback: feedback), animated: false)

		let descriptionLabel = UILabel()
		descriptionLabel.text = description
		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = .preferredFont(forTextStyle: .body)
		descriptionLabel.adjustsFontForContentSizeCategory = true
		descriptionLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		let rowStackView = UIStackView(arrangedSubviews: [tileView, descriptionLabel])
		rowStackView.axis = .horizontal
		rowStackView.alignment = .center
		rowStackView.spacing = 12

		return rowStackView
	}

	/// Adds the scroll view and content stack view to the hierarchy.
	private func configureViewHierarchy() {
		self.scrollView.addSubview(self.contentStackView)
		self.view.addSubview(self.scrollView)
	}

	/// Activates the screen's layout constraints.
	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

			self.contentStackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 16),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
			self.contentStackView.centerXAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.centerXAnchor),
			self.contentStackView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, constant: -32)
		])
	}

	/// Configures the close bar button item.
	private func configureCloseBarButtonItem() {
		self.closeBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismiss(animated: true, completion: nil)
		})
		// Close sits on the leading edge, matching the app's other modal screens.
		self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.configureCloseBarButtonItem()
	}
}
