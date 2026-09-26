//
//  ThemeLabViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import UIKit

final class ThemeLabViewController: SubSettingsViewController {
	// MARK: - Properties
	/// The theme files in the lab folder.
	private var themeURLs: [URL] = []

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

		self.title = "Theme Lab"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.reloadThemes()
	}

	// MARK: - UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.themeURLs.count
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "Place theme plists in Library/Themes/Lab. Press ⌃⌥⌘] or ⌃⌥⌘[ on any screen to cycle through them. The chosen theme returns on the next launch."
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		var content = cell.defaultContentConfiguration()

		if let themeURL = self.themeURLs[safe: indexPath.row] {
			content.text = ThemeLab.shared.name(ofThemeAt: themeURL)
			content.textProperties.color = KThemePicker.tableViewCellTitleTextColor.colorValue
			content.image = UIImage(systemName: "circle.fill")
			content.imageProperties.tintColor = ThemeLab.shared.tintColor(ofThemeAt: themeURL)
			cell.accessoryType = themeURL == ThemeLab.shared.appliedThemeURL ? .checkmark : .none
		}

		cell.contentConfiguration = content
		cell.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		let selectedBackgroundView = UIView()
		selectedBackgroundView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		cell.selectedBackgroundView = selectedBackgroundView

		return cell
	}

	// MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let themeURL = self.themeURLs[safe: indexPath.row] else { return }

		ThemeLab.shared.apply(themeAt: themeURL)
		tableView.reloadData()
	}

	// MARK: - Functions
	/// Reloads the theme files from the lab folder.
	private func reloadThemes() {
		do {
			self.themeURLs = try ThemeLab.shared.themeURLs()
		} catch {
			self.themeURLs = []

			let alertController = UIAlertController(title: "Theme Lab Unavailable", message: error.localizedDescription, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(alertController, animated: true)
		}

		self.tableView.reloadData()
	}
}
#endif
