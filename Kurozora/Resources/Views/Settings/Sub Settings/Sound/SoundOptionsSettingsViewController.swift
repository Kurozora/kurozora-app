//
//  SoundOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol SoundOptionsViewControllerDelegate: AnyObject {
	func soundOptionsViewController(_ vc: SoundOptionsViewController, didChangeChimeTo chime: AppChimeElement)
}

class SoundOptionsViewController: SubSettingsViewController {
	// MARK: - Properties
	weak var delegate: SoundOptionsViewControllerDelegate?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Disable activity indicator
		self._prefersActivityIndicatorHidden = true
	}
}

// MARK: - UITableViewDataSource
extension SoundOptionsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Chime.shared.appChimeGroups.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Chime.shared.appChimeGroups[section].chimes.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let notificationsGroupingCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.iconTableViewCell.identifier, for: indexPath) as? IconTableViewCell else {
			fatalError("Couldn't dequeue cell with identifier \(R.reuseIdentifier.iconTableViewCell.identifier)")
		}
		let chime = Chime.shared.appChimeGroups[indexPath.section].chimes[indexPath.row]
		let selectedChime = UserSettings.selectedChime

		notificationsGroupingCell.configureCell(using: chime)
		notificationsGroupingCell.setSelected(chime.name == selectedChime)

		return notificationsGroupingCell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if Chime.shared.appChimeGroups[section].chimes.count != 0 {
			return Chime.shared.appChimeGroups[section].title.uppercased()
		}

		return nil
	}
}

// MARK: - UITableViewDelegate
extension SoundOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let chime = Chime.shared.appChimeGroups[indexPath.section].chimes[indexPath.row]

		switch indexPath.section {
		case 0:
			self.changeChime(chime)
		default:
			Task { [weak self] in
				guard let self = self else { return }

				if await WorkflowController.shared.isProOrSubscribed(on: self) {
					self.changeChime(chime)
				}
			}
		}
	}

	private func changeChime(_ chime: AppChimeElement) {
		Chime.shared.play(chime.file)
		Chime.shared.changeChime(to: chime)

		self.delegate?.soundOptionsViewController(self, didChangeChimeTo: chime)

		self.tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension SoundOptionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
