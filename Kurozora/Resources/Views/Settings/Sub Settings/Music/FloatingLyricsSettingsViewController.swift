//
//  FloatingLyricsSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class FloatingLyricsSettingsViewController: SubSettingsViewController {
	// MARK: - Views
	/// The preview cell.
	private let previewCell = FloatingLyricsPreviewCell(style: .default, reuseIdentifier: nil)

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

		self.title = L10n.floatingLyrics
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.tableView.reloadData()
		FloatingLyricsManager.shared.beginPreview(self.previewCell.previewView)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		FloatingLyricsManager.shared.endPreview()
	}

	// MARK: - Functions
	/// The title of the second-line toggle, naming what the second line will actually show.
	private var secondLineToggleTitle: String {
		if UserSettings.lyricsTranslationLanguage != nil {
			return L10n.showTranslation
		}

		switch UserSettings.lyricsLargerText {
		case .lyrics:
			return L10n.showPronunciation
		case .pronunciation:
			return L10n.showLyrics
		}
	}

	/// Refreshes the affected rows and pushes the changed settings to the manager.
	private func settingsChanged() {
		self.previewCell.setRows(UserSettings.lyricsFloatingWindowRows)
		self.tableView.reloadData()
		FloatingLyricsManager.shared.settingsDidChange()
	}

	/// Installs the single-selection font size menu on the given button.
	///
	/// - Parameter button: The button to install the menu on.
	private func configureFontSizeMenu(_ button: UIButton) {
		button.showsMenuAsPrimaryAction = true
		button.menu = UIMenu(options: .singleSelection, children: LyricsFloatingWindowFontSize.allCases.map { option in
			UIAction(title: option.stringValue, state: option == UserSettings.lyricsFloatingWindowFontSize ? .on : .off) { [weak self] _ in
				UserSettings.set(option.rawValue, forKey: .lyricsFloatingWindowFontSize)
				self?.settingsChanged()
			}
		})
	}

	/// Installs the single-selection display rows menu on the given button.
	///
	/// - Parameter button: The button to install the menu on.
	private func configureDisplayMenu(_ button: UIButton) {
		button.showsMenuAsPrimaryAction = true
		button.menu = UIMenu(options: .singleSelection, children: LyricsFloatingWindowRows.allCases.map { option in
			UIAction(title: option.stringValue, state: option == UserSettings.lyricsFloatingWindowRows ? .on : .off) { [weak self] _ in
				UserSettings.set(option.rawValue, forKey: .lyricsFloatingWindowRows)
				self?.settingsChanged()
			}
		})
	}
}

// MARK: - KTableViewDataSource
extension FloatingLyricsSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			MenuSettingsCell.self,
			SwitchSettingsCell.self,
		]
	}
}

// MARK: - UITableViewDataSource
extension FloatingLyricsSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .options:
			return Row.allCases.count
		default:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .preview:
			return self.previewCell
		case .options:
			switch Row(rawValue: indexPath.row) {
			case .fontSize:
				guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuSettingsCell.self, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(MenuSettingsCell.reuseID)")
				}
				cell.configure(title: L10n.fontSize, buttonTitle: UserSettings.lyricsFloatingWindowFontSize.stringValue)
				self.configureFontSizeMenu(cell.menuActionButton)
				return cell
			case .display:
				guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuSettingsCell.self, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(MenuSettingsCell.reuseID)")
				}
				cell.configure(title: L10n.displayLines, buttonTitle: UserSettings.lyricsFloatingWindowRows.stringValue)
				self.configureDisplayMenu(cell.menuActionButton)
				return cell
			default:
				guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
				}
				let translationAvailable = UserSettings.lyricsFloatingWindowRows == .two
				cell.configure(title: self.secondLineToggleTitle, isOn: translationAvailable && UserSettings.lyricsFloatingWindowShowsTranslation, tag: 0, action: UIAction { [weak self] action in
					guard let sender = action.sender as? KSwitch else { return }
					UserSettings.set(sender.isOn, forKey: .lyricsFloatingWindowShowsTranslation)
					self?.settingsChanged()
				})
				cell.toggleSwitch.isEnabled = translationAvailable
				cell.primaryLabel?.alpha = translationAvailable ? 1 : 0.5
				return cell
			}
		case .autoOpen:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			cell.configure(title: L10n.openAutomatically, isOn: UserSettings.lyricsFloatingWindowAutoOpen, tag: 0, action: UIAction { [weak self] action in
				guard let sender = action.sender as? KSwitch else { return }
				UserSettings.set(sender.isOn, forKey: .lyricsFloatingWindowAutoOpen)
				self?.settingsChanged()
			})
			cell.toggleSwitch.isEnabled = true
			cell.primaryLabel?.alpha = 1
			return cell
		default:
			return UITableViewCell()
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch Section(rawValue: section) {
		case .preview:
			return L10n.floatingLyricsDescription
		case .options:
			return L10n.showTranslationDescription
		case .autoOpen:
			return L10n.openAutomaticallyDescription
		default:
			return nil
		}
	}
}

// MARK: - Sections and Rows
private extension FloatingLyricsSettingsViewController {
	enum Section: Int, CaseIterable {
		case preview = 0
		case options
		case autoOpen
	}

	enum Row: Int, CaseIterable {
		case fontSize = 0
		case display
		case showTranslation
	}
}
