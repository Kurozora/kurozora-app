//
//  ReCapPeriodPickerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The pinned year pill and month chips that switch the period of a Re:CAP.
final class ReCapPeriodPickerView: UIView {
	// MARK: - Properties
	/// The height of the year pill.
	private static let pillHeight: CGFloat = 32.0

	/// The space between the year pill and the leading edge.
	private static let horizontalInset: CGFloat = 10.0

	/// The width over which the month chips fade out next to the year pill.
	private static let fadeWidth: CGFloat = 12.0

	/// The space between a chip's title and its pill edge.
	private static let chipPadding: CGFloat = 12.0

	/// Called with the month of the selected period.
	var periodSelectedHandler: ((Int) -> Void)?

	/// The months listed by the chips.
	private var months: [Int] = []

	/// The year of the periods.
	private var year = 0

	/// The month of the selected period.
	private var selectedMonth = 0

	// MARK: - Views
	private let yearButton = UIButton(type: .system)

	private let chipsView = KChipsView()

	private let chipsContainerView = UIView()

	private let fadeMaskLayer = CAGradientLayer()

	/// The leading inset the month chips start at without the year pill.
	private var defaultLeadingInset: CGFloat = 0.0

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
	private func sharedInit() {
		self.yearButton.translatesAutoresizingMaskIntoConstraints = false
		self.yearButton.addAction(UIAction { [weak self] _ in
			self?.periodSelectedHandler?(0)
		}, for: .primaryActionTriggered)

		self.chipsView.translatesAutoresizingMaskIntoConstraints = false
		self.chipsView.chipSelectedHandler = { [weak self] index in
			guard let self, let month = self.months[safe: index] else { return }
			self.periodSelectedHandler?(month)
		}

		self.chipsContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.chipsContainerView.layer.mask = self.fadeMaskLayer
		self.fadeMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		self.fadeMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		self.fadeMaskLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
		self.chipsContainerView.addSubview(self.chipsView)
		self.chipsView.fillToSuperview()
		self.defaultLeadingInset = self.chipsView.contentInset.left

		self.addSubview(self.chipsContainerView)
		self.addSubview(self.yearButton)

		NSLayoutConstraint.activate([
			self.yearButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: Self.horizontalInset),
			self.yearButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.yearButton.heightAnchor.constraint(equalToConstant: Self.pillHeight),

			self.chipsContainerView.topAnchor.constraint(equalTo: self.topAnchor),
			self.chipsContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.chipsContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.chipsContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let width = self.chipsContainerView.bounds.width
		let pillMaxX = self.yearButton.isHidden ? 0.0 : self.yearButton.frame.maxX
		let fadeStart = width > 0.0 ? min(max(pillMaxX - Self.fadeWidth, 0.0) / width, 1.0) : 0.0
		let fadeEnd = width > 0.0 ? min(pillMaxX / width, 1.0) : 0.0

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.fadeMaskLayer.frame = self.chipsContainerView.bounds
		self.fadeMaskLayer.locations = self.yearButton.isHidden ? [0.0, 0.0, 0.0, 1.0] : [0.0, NSNumber(value: fadeStart), NSNumber(value: fadeEnd), 1.0]
		CATransaction.commit()

		let leadingInset = self.yearButton.isHidden ? self.defaultLeadingInset : pillMaxX - self.chipsContainerView.safeAreaInsets.left + Self.chipPadding
		if self.chipsView.contentInset.left != leadingInset {
			let isAtRest = self.chipsView.contentOffset.x <= -self.chipsView.adjustedContentInset.left
			self.chipsView.contentInset.left = leadingInset
			if isAtRest {
				self.chipsView.contentOffset.x = -self.chipsView.adjustedContentInset.left
			}
		}
	}

	/// Configures the picker with the given periods.
	///
	/// - Parameters:
	///    - year: The year of the periods.
	///    - hasYearlyRecap: Whether the year has a yearly recap.
	///    - months: The months with a recap.
	///    - selectedMonth: The month of the selected period.
	func configure(year: Int, hasYearlyRecap: Bool, months: [Int], selectedMonth: Int) {
		self.months = months
		self.yearButton.isHidden = !hasYearlyRecap
		self.chipsView.titles = months.map { Self.shortName(ofMonth: $0) }

		self.select(year: year, month: selectedMonth, animated: false)
	}

	/// Shows the period of the given month as selected.
	///
	/// - Parameters:
	///    - year: The year of the period.
	///    - month: The month of the period.
	///    - animated: Whether the change is animated.
	func select(year: Int, month: Int, animated: Bool) {
		self.year = year
		self.selectedMonth = month
		self.configureYearButton()
		self.chipsView.isSelectionHidden = month == 0

		if let index = self.months.firstIndex(of: month) {
			self.chipsView.selectChip(at: index, animated: animated)
		}

		self.setNeedsLayout()
	}

	/// Re-applies the theme's colors to the year pill and the month chips.
	func restyle() {
		self.configureYearButton()
		self.chipsView.restyle()
	}

	/// Styles the year pill.
	private func configureYearButton() {
		let isSelected = self.selectedMonth == 0
		var configuration: UIButton.Configuration

		if isSelected {
			configuration = .filled()
			configuration.baseBackgroundColor = KThemePicker.tintColor.colorValue
			configuration.baseForegroundColor = KTintedButton.titleColor
		} else {
			configuration = .plain()
			configuration.baseForegroundColor = KThemePicker.textColor.colorValue
		}

		configuration.cornerStyle = .capsule
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 12.0, bottom: 0.0, trailing: 12.0)
		configuration.attributedTitle = AttributedString(String(self.year), attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold)]))
		self.yearButton.configuration = configuration
		self.yearButton.accessibilityTraits = isSelected ? [.button, .selected] : .button
	}

	/// Returns the short name of the given month.
	///
	/// - Parameter month: The month to name.
	///
	/// - Returns: The short name of the month.
	private static func shortName(ofMonth month: Int) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = LanguageManager.shared.locale
		return dateFormatter.shortStandaloneMonthSymbols[safe: month - 1] ?? String(month)
	}
}
