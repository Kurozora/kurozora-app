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

final class LibrarySyncScenariosViewController: SubSettingsViewController {
	// MARK: - Types
	private enum Section: Int, CaseIterable {
		case verify
		case runAll
		case scenarios
	}

	// MARK: - Properties
	/// The scenario currently running.
	private var runningScenario: LibrarySyncScenarioRunner?

	/// Whether every scenario is being run.
	private var isRunningAll = false

	/// Whether a verification is running.
	private var isVerifying = false

	/// The latest verdicts per kind.
	private var verifyVerdicts: [LibrarySyncVerifier.Verdict] = []

	/// The most recent report per scenario.
	private var reports: [LibrarySyncScenarioRunner: LibrarySyncScenarioReport] = [:]

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
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .verify, .runAll:
			return 1
		case .scenarios:
			return LibrarySyncScenarioRunner.allCases.count
		case .none:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch Section(rawValue: section) {
		case .verify:
			return "Compares the local store with the server for every kind without changing anything."
		case .runAll:
			return "Runs every scenario in order against the signed-in account's library. Each scenario puts the titles it touched back before finishing."
		case .scenarios:
			return "Every step syncs, pulls the kind's full state from the server, and diffs it against the local store. Steps are logged under the LibrarySyncScenario and LibrarySyncVerifier categories."
		case .none:
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		var content = cell.defaultContentConfiguration()

		switch Section(rawValue: indexPath.section) {
		case .verify:
			content.text = "Verify Against Server"
			content.secondaryText = self.verifyVerdicts.isEmpty ? nil : self.verifyVerdicts.map(\.summary).joined(separator: "\n")
			content.secondaryTextProperties.color = KThemePicker.subTextColor.colorValue
			content.textProperties.color = self.isBusy ? KThemePicker.subTextColor.colorValue : KThemePicker.tintColor.colorValue
			cell.accessoryView = self.isVerifying ? Self.makeSpinner() : self.verifyAccessoryView()
		case .runAll:
			content.text = "Run All"
			content.textProperties.color = self.isBusy ? KThemePicker.subTextColor.colorValue : KThemePicker.tintColor.colorValue
			cell.accessoryView = self.isRunningAll ? Self.makeSpinner() : nil
		case .scenarios:
			let scenario = LibrarySyncScenarioRunner.allCases[indexPath.row]
			content.text = scenario.name
			content.secondaryText = self.reports[scenario]?.summary
			content.textProperties.color = KThemePicker.tableViewCellTitleTextColor.colorValue
			content.secondaryTextProperties.color = KThemePicker.tableViewCellSubTextColor.colorValue
			cell.accessoryView = self.accessoryView(for: scenario)
		case .none:
			break
		}

		cell.contentConfiguration = content
		cell.selectionStyle = self.isBusy ? .none : .default
		cell.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		let selectedBackgroundView = UIView()
		selectedBackgroundView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		cell.selectedBackgroundView = selectedBackgroundView

		return cell
	}

	// MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard !self.isBusy else { return }

		guard let userSlug = User.current?.attributes.slug else {
			self.presentAlert(title: "No Account", message: "Sign in before running a scenario.")
			return
		}

		switch Section(rawValue: indexPath.section) {
		case .verify:
			self.verifyAllKinds(forUserSlug: userSlug)
		case .runAll:
			self.run(LibrarySyncScenarioRunner.allCases, forUserSlug: userSlug)
		case .scenarios:
			self.run([LibrarySyncScenarioRunner.allCases[indexPath.row]], forUserSlug: userSlug)
		case .none:
			break
		}
	}

	// MARK: - Functions
	/// Whether any work is in progress.
	private var isBusy: Bool {
		return self.runningScenario != nil || self.isVerifying
	}

	/// Verifies every kind against the server.
	private func verifyAllKinds(forUserSlug userSlug: String) {
		self.isVerifying = true
		self.tableView.reloadData()

		Task { [weak self] in
			var verdicts: [LibrarySyncVerifier.Verdict] = []
			var failures: [String] = []

			for kind in LibraryKind.allCases {
				do {
					verdicts.append(try await LibrarySyncVerifier.verify(kind, forUserSlug: userSlug))
				} catch {
					failures.append("kind=\(kind.rawValue) \(error.localizedDescription)")
				}
			}

			guard let self = self else { return }
			self.verifyVerdicts = verdicts
			self.isVerifying = false
			self.tableView.reloadData()

			let differenceLines = verdicts.flatMap { verdict in
				verdict.differences.prefix(10).map { "kind=\(verdict.kind.rawValue) \($0)" }
			}
			let message = (verdicts.map(\.summary) + failures + differenceLines).joined(separator: "\n")
			let passed = failures.isEmpty && verdicts.allSatisfy(\.passed)
			self.presentAlert(title: passed ? "Store matches server" : "Store differs from server", message: message)
		}
	}

	private func verifyAccessoryView() -> UIView? {
		guard !self.verifyVerdicts.isEmpty else { return nil }
		let passed = self.verifyVerdicts.allSatisfy(\.passed)
		let imageView = UIImageView(image: UIImage(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill"))
		imageView.tintColor = passed ? .systemGreen : .systemRed
		return imageView
	}

	/// Runs the given scenarios.
	private func run(_ scenarios: [LibrarySyncScenarioRunner], forUserSlug userSlug: String) {
		self.isRunningAll = scenarios.count > 1

		Task { [weak self] in
			var reports: [LibrarySyncScenarioReport] = []

			for scenario in scenarios {
				guard let self = self else { return }
				self.runningScenario = scenario
				self.tableView.reloadData()

				let report = await scenario.run(forUserSlug: userSlug)
				reports.append(report)

				self.reports[scenario] = report
				self.runningScenario = nil
				self.tableView.reloadData()
			}

			guard let self = self else { return }
			self.isRunningAll = false
			self.tableView.reloadData()
			self.presentSummary(of: reports)
		}
	}

	/// Presents the reports.
	private func presentSummary(of reports: [LibrarySyncScenarioReport]) {
		if reports.count == 1, let report = reports.first {
			let title = report.passed ? "\(report.scenario) passed" : "\(report.scenario) failed"
			self.presentAlert(title: title, message: report.stepLines)
			return
		}

		let passedCount = reports.filter(\.passed).count
		let failedNames = reports.filter { !$0.passed }.map(\.scenario)
		let message = failedNames.isEmpty ? "Every scenario converged." : "Failed: \(failedNames.joined(separator: ", "))"
		self.presentAlert(title: "\(passedCount)/\(reports.count) scenarios passed", message: message)
	}

	private func accessoryView(for scenario: LibrarySyncScenarioRunner) -> UIView? {
		if scenario == self.runningScenario {
			return Self.makeSpinner()
		}

		guard let report = self.reports[scenario] else { return nil }
		let symbolName = report.passed ? "checkmark.circle.fill" : "xmark.circle.fill"
		let imageView = UIImageView(image: UIImage(systemName: symbolName))
		imageView.tintColor = report.passed ? .systemGreen : .systemRed
		return imageView
	}

	private static func makeSpinner() -> UIActivityIndicatorView {
		let activityIndicatorView = UIActivityIndicatorView(style: .medium)
		activityIndicatorView.startAnimating()
		return activityIndicatorView
	}

	/// Presents a single-button informational alert.
	private func presentAlert(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default))
		self.present(alertController, animated: true)
	}
}
#endif
