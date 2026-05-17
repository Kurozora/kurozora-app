//
//  ReminderSubscriptionTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ReminderSubscriptionTableViewController: SubSettingsViewController {
	// MARK: - Properties
	/// The webcal-scheme subscription URL used to build per-app destination URLs.
	private var webcalURL: URL?

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.reminder
		self.headerTitle = L10n.subscribeToReminders
		self.headerDescription = L10n.reminderSubscriptionHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
		self.webcalURL = Self.makeWebcalURL()
	}

	// MARK: - Functions
	/// Builds the webcal-scheme subscription URL from `KService.reminderSubscriptionURL`.
	///
	/// - Returns: A webcal-scheme URL.
	private static func makeWebcalURL() -> URL? {
		let subscriptionURL = KService.reminderSubscriptionURL

		guard let scheme = subscriptionURL.scheme else {
			return subscriptionURL
		}

		let webcalString = subscriptionURL.absoluteString.replacingOccurrences(of: scheme, with: "webcal")
		return URL(string: webcalString)
	}

	/// Copies the webcal subscription URL to the system pasteboard and presents a confirmation alert.
	private func copySubscriptionLink() {
		guard let webcalURL = self.webcalURL else { return }

		UIPasteboard.general.string = webcalURL.absoluteString
		_ = self.presentAlertController(title: L10n.subscriptionLinkCopied, message: nil)
	}

	/// Opens the subscription URL for the supplied calendar app.
	///
	/// - Parameter calendarApp: The calendar destination to open.
	private func openCalendarApp(_ calendarApp: KCalendarApp) {
		guard let webcalURL = self.webcalURL else { return }
		guard let destinationURL = calendarApp.subscriptionURL(from: webcalURL) else { return }

		if calendarApp.isDeepLink {
			if UIApplication.shared.canOpenURL(destinationURL) {
				UIApplication.shared.open(destinationURL)
			} else if let storeURL = calendarApp.storeURL {
				UIApplication.shared.kOpen(storeURL)
			}
		} else {
			UIApplication.shared.kOpen(destinationURL)
		}
	}
}

// MARK: - KTableViewDataSource
extension ReminderSubscriptionTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			IconTableViewCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension ReminderSubscriptionTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1 + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard self.contentSection(for: section) != nil else { return 1 }
		return KCalendarApp.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(IconTableViewCell.reuseID)")
		}

		let calendarApp = KCalendarApp.allCases[indexPath.row]
		iconTableViewCell.configureCell(using: calendarApp)
		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard self.contentSection(for: section) != nil else { return nil }
		return L10n.reminderSubscriptionFooter
	}
}

// MARK: - UITableViewDelegate
extension ReminderSubscriptionTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let contentSection = self.contentSection(for: section) else { return .leastNormalMagnitude }
		return super.tableView(tableView, heightForHeaderInSection: contentSection)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard self.contentSection(for: indexPath.section) != nil else { return }

		let calendarApp = KCalendarApp.allCases[indexPath.row]

		if calendarApp.isCopyAction {
			self.copySubscriptionLink()
		} else {
			self.openCalendarApp(calendarApp)
		}
	}
}
