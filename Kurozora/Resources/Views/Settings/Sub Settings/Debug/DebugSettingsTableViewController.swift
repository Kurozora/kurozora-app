//
//  DebugSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class DebugSettingsTableViewController: KTableViewController {
	// MARK: - Views
	private var tableHeaderView: UIView!
	private var warningLabel: KLabel!

	// MARK: - Properties
	let kDefaultItems = SharedDelegate.shared.keychain.allItems()
	var kDefaultCount = SharedDelegate.shared.keychain.allItems().count

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.keysManager

		// Stop activity indicator and disable refresh control
		self._prefersActivityIndicatorHidden = true
		self._prefersRefreshControlDisabled = true

		self.toggleEmptyDataView()
		self.configureView()
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		self.tableView.updateHeaderViewFrame()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the table view.
	private func sharedInit() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.keychain)
		self.emptyBackgroundView.configureLabels(title: "No Keys", detail: "All Kurozora related keys in your keychain are removed.")

		self.tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to `kDefaultCount`.
	func toggleEmptyDataView() {
		if self.kDefaultCount == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	// Add text to table view header
	private func configureView() {
		self.configureTableHeaderView()
		self.configureWarningLabel()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureTableHeaderView() {
		self.tableHeaderView = UIView()
		self.tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
		self.tableHeaderView.backgroundColor = .clear
	}

	private func configureWarningLabel() {
		self.warningLabel = KLabel()
		self.warningLabel.translatesAutoresizingMaskIntoConstraints = false
		self.warningLabel.text = "Warning: Modifying these values may break your app! Proceed with caution."
		self.warningLabel.numberOfLines = 0
		self.warningLabel.textAlignment = .center
		self.warningLabel.font = .preferredFont(forTextStyle: .footnote)
	}

	private func configureViewHierarchy() {
		self.tableHeaderView.addSubview(self.warningLabel)
		self.tableView.tableHeaderView = self.tableHeaderView
	}

	private func configureViewConstraints() {
		guard let tableHeaderView = self.tableView.tableHeaderView else { return }

		NSLayoutConstraint.activate([
			self.tableHeaderView.leadingAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.leadingAnchor),
			self.tableHeaderView.trailingAnchor.constraint(equalTo: self.tableView.layoutMarginsGuide.trailingAnchor),
			self.tableHeaderView.topAnchor.constraint(equalTo: self.tableView.topAnchor),

			self.warningLabel.leadingAnchor.constraint(equalTo: tableHeaderView.layoutMarginsGuide.leadingAnchor, constant: 16),
			self.warningLabel.trailingAnchor.constraint(equalTo: tableHeaderView.layoutMarginsGuide.trailingAnchor, constant: -16),
			self.warningLabel.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 12),
			self.warningLabel.bottomAnchor.constraint(equalTo: tableHeaderView.bottomAnchor, constant: -24)
		])

		self.tableView.updateHeaderViewFrame()
	}
}

// MARK: - UITableViewDataSource
extension DebugSettingsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.kDefaultCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let kDefaultsCell = self.tableView.dequeueReusableCell(withIdentifier: KDefaultsCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(KDefaultsCell.reuseID)")
		}

		if let key = kDefaultItems[indexPath.row]["key"] as? String, !key.isEmpty {
			kDefaultsCell.primaryLabel?.text = key
		}
		if let value = kDefaultItems[indexPath.row]["value"] as? String, !value.isEmpty {
			kDefaultsCell.valueTextField.text = value
		}

		return kDefaultsCell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete, let kDefaultsTableViewCell = self.tableView.cellForRow(at: indexPath) as? KDefaultsCell {
			guard let key = kDefaultsTableViewCell.primaryLabel?.text else { return }

			self.tableView.beginUpdates()
			try? SharedDelegate.shared.keychain.remove(key)
			self.kDefaultCount -= 1
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.toggleEmptyDataView()
			self.tableView.endUpdates()
		}
	}
}

// MARK: - KTableViewDataSource
extension DebugSettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [KDefaultsCell.self]
	}
}
