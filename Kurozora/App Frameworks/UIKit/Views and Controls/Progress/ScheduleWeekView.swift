//
//  ScheduleWeekView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view that marks today and the next release on a week of dates.
final class ScheduleWeekView: UIView {
	// MARK: - Views
	/// The seven days the row covers.
	private let dayViews = (0..<7).map { _ in ScheduleDayView() }

	/// The stack holding the days in a row.
	private lazy var rowStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: self.dayViews)
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.alignment = .top
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	// MARK: - Properties
	/// The symbols naming each weekday in the user's locale.
	private static let weekdaySymbols = DateFormatter.app.veryShortStandaloneWeekdaySymbols ?? []

	/// The day the next release lands on.
	private var releaseDate: Date?

	/// The observer that rolls the row over at midnight.
	private var significantTimeChangeObserver: NSObjectProtocol?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	isolated deinit {
		if let significantTimeChangeObserver {
			NotificationCenter.default.removeObserver(significantTimeChangeObserver)
		}
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.addSubview(self.rowStackView)

		NSLayoutConstraint.activate([
			self.rowStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.rowStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.rowStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.rowStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		self.significantTimeChangeObserver = NotificationCenter.default.addObserver(
			forName: UIApplication.significantTimeChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.reloadDays()
			}
		}
	}

	/// Lays out the week leading to the given release.
	///
	/// - Parameter releaseDate: The day the next release lands on.
	func configure(releaseDate: Date?) {
		self.releaseDate = releaseDate
		self.reloadDays()
	}

	/// Writes the week the release falls in onto the days.
	///
	/// - Parameter calendar: The calendar the dates are read in.
	private func reloadDays(calendar: Calendar = .app) {
		guard let releaseDate = self.releaseDate else { return }

		let today = calendar.startOfDay(for: Date())
		let releaseDay = calendar.startOfDay(for: releaseDate)
		let weekEndingOnRelease = calendar.date(byAdding: .day, value: -6, to: releaseDay) ?? today
		let firstDay = max(today, weekEndingOnRelease)

		for (offset, dayView) in self.dayViews.enumerated() {
			guard let date = calendar.date(byAdding: .day, value: offset, to: firstDay) else { continue }
			let weekday = calendar.component(.weekday, from: date)

			dayView.configure(
				weekday: Self.weekdaySymbols[safe: weekday - 1] ?? "",
				day: calendar.component(.day, from: date),
				isToday: calendar.isDateInToday(date),
				isRelease: calendar.isDate(date, inSameDayAs: releaseDate)
			)
		}
	}
}

// MARK: - ScheduleDayView
/// A view that pairs a weekday with its date.
private final class ScheduleDayView: UIView {
	// MARK: - Views
	/// The initial of the weekday.
	private let weekdayLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.font = .preferredFont(forTextStyle: .caption2)
		label.adjustsFontForContentSizeCategory = true
		label.textAlignment = .center
		return label
	}()

	/// The date of the day.
	private let dayLabel: KLabel = {
		let label = KLabel()
		label.font = .preferredFont(forTextStyle: .caption1)
		label.adjustsFontForContentSizeCategory = true
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.7
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	/// The outline drawn around today.
	private let ringView: CircularView = {
		let view = CircularView()
		view.layer.borderWidth = 0
		view.layer.theme_borderColor = KThemePicker.subTextColor.cgColorPicker
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The disc filled behind a release day.
	private let discView: CircularView = {
		let view = CircularView()
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stack holding the weekday above its date.
	private lazy var columnStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [self.weekdayLabel, self.ringView])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 4.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

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
		self.ringView.addSubview(self.discView)
		self.discView.addSubview(self.dayLabel)
		self.addSubview(self.columnStackView)

		// Collapses the circle onto the smallest square its date fits in.
		let ringSqueeze = self.ringView.widthAnchor.constraint(equalToConstant: 0)
		ringSqueeze.priority = UILayoutPriority(1)

		NSLayoutConstraint.activate([
			self.columnStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.columnStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.columnStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.columnStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.ringView.widthAnchor.constraint(equalTo: self.ringView.heightAnchor),
			self.ringView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor),
			ringSqueeze,

			self.discView.topAnchor.constraint(equalTo: self.ringView.topAnchor, constant: 2.0),
			self.discView.leadingAnchor.constraint(equalTo: self.ringView.leadingAnchor, constant: 2.0),
			self.discView.trailingAnchor.constraint(equalTo: self.ringView.trailingAnchor, constant: -2.0),
			self.discView.bottomAnchor.constraint(equalTo: self.ringView.bottomAnchor, constant: -2.0),

			self.dayLabel.centerXAnchor.constraint(equalTo: self.discView.centerXAnchor),
			self.dayLabel.centerYAnchor.constraint(equalTo: self.discView.centerYAnchor),
			self.dayLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.discView.leadingAnchor, constant: 3.0),
			self.dayLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.discView.trailingAnchor, constant: -3.0),
			self.dayLabel.topAnchor.constraint(greaterThanOrEqualTo: self.discView.topAnchor, constant: 2.0),
			self.dayLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.discView.bottomAnchor, constant: -2.0)
		])
	}

	/// Configure the view with the given day.
	///
	/// - Parameters:
	///    - weekday: The initial of the weekday.
	///    - day: The date of the day.
	///    - isToday: Whether the day is today.
	///    - isRelease: Whether the day carries the next release.
	func configure(weekday: String, day: Int, isToday: Bool, isRelease: Bool) {
		self.weekdayLabel.text = weekday
		self.dayLabel.text = "\(day)"

		self.ringView.layer.borderWidth = isToday ? 1.5 : 0

		if isRelease {
			self.discView.theme_backgroundColor = KThemePicker.tintColor.rawValue
			self.dayLabel.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
			self.dayLabel.font = UIFont.preferredFont(forTextStyle: .caption1).bold
		} else {
			self.discView.theme_backgroundColor = nil
			self.discView.backgroundColor = .clear
			self.dayLabel.theme_textColor = KThemePicker.textColor.rawValue
			self.dayLabel.font = .preferredFont(forTextStyle: .caption1)
		}
	}
}
