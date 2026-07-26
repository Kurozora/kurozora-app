//
//  LibrarySyncScenariosViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import KurozoraKit
import UIKit

/// Lists deterministic library-sync QA scenarios and runs the tapped one against the current account.
final class LibrarySyncScenariosViewController: UITableViewController {
	// MARK: - Properties
	/// The row currently running a scenario, if any.
	private var runningIndexPath: IndexPath?

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Sync Scenarios"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}

	// MARK: - UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return LibrarySyncScenarioRunner.allCases.count
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "Runs a fixed mutation sequence through the outbox and logs a fingerprint to library-diagnostics.json after each step. Run the same scenario on both simulators, then diff the file."
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let scenario = LibrarySyncScenarioRunner.allCases[indexPath.row]

		var content = cell.defaultContentConfiguration()
		content.text = scenario.name
		cell.contentConfiguration = content

		if indexPath == self.runningIndexPath {
			let activityIndicatorView = UIActivityIndicatorView(style: .medium)
			activityIndicatorView.startAnimating()
			cell.accessoryView = activityIndicatorView
		} else {
			cell.accessoryView = nil
		}

		cell.selectionStyle = self.runningIndexPath == nil ? .default : .none
		return cell
	}

	// MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard self.runningIndexPath == nil else { return }

		let scenario = LibrarySyncScenarioRunner.allCases[indexPath.row]
		guard let userSlug = User.current?.attributes.slug else {
			self.presentAlert(title: "No Account", message: "Sign in before running a scenario.")
			return
		}

		self.runningIndexPath = indexPath
		tableView.reloadData()

		Task { [weak self] in
			await scenario.run(forUserSlug: userSlug)

			guard let self = self else { return }
			self.runningIndexPath = nil
			tableView.reloadData()
			self.presentAlert(title: "Done", message: "\(scenario.name) finished. Check library-diagnostics.json.")
		}
	}

	// MARK: - Functions
	/// Presents a single-button informational alert.
	private func presentAlert(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default))
		self.present(alertController, animated: true)
	}
}
#endif
