//
//  SearchFilterDatePickerViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A sheet holding a date picker for a search filter.
class SearchFilterDatePickerViewController: KViewController {
	// MARK: - Views
	private let datePicker = UIDatePicker()

	// MARK: - Properties
	/// The name of the filter the sheet sets.
	var filterTitle: String?

	/// The date the sheet opens on.
	var selectedDate: Date?

	/// Receives the chosen date.
	var dateHandler: ((Date?) -> Void)?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureView()
		self.configureNavigationItem()
		self.configureDatePicker()
	}

	// MARK: - Functions
	private func configureView() {
		self.title = self.filterTitle
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}

	private func configureNavigationItem() {
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: L10n.filterAny, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dateHandler?(nil)
			self.dismiss(animated: true)
		})

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dateHandler?(self.datePicker.date)
			self.dismiss(animated: true)
		})
	}

	private func configureDatePicker() {
		self.datePicker.translatesAutoresizingMaskIntoConstraints = false
		self.datePicker.datePickerMode = .date
		self.datePicker.preferredDatePickerStyle = .inline
		self.datePicker.theme_tintColor = KThemePicker.tintColor.rawValue

		if let selectedDate = self.selectedDate {
			self.datePicker.date = selectedDate
		}

		self.view.addSubview(self.datePicker)

		NSLayoutConstraint.activate([
			self.datePicker.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.datePicker.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
			self.datePicker.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
		])
	}
}
