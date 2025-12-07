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
	private var numberOfTaps: Int = 0
	private var selectedChime: AppChimeElement?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.chimeSound

		// Disable activity indicator
		self._prefersActivityIndicatorHidden = true

		self.selectedChime = Chime.shared.appChimeGroups.flatMap({ $0.chimes }).flatMap({ $0 }).first(where: { $0.name == UserSettings.selectedChime })
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
		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Couldn't dequeue cell with identifier \(IconTableViewCell.reuseID)")
		}
		let chimes = Chime.shared.appChimeGroups[indexPath.section].chimes[indexPath.row]
		let sameChimeGroup = chimes.contains(where: { $0 == self.selectedChime })
		let chime = {
			if sameChimeGroup, let selectedIndex = chimes.firstIndex(where: { $0 == self.selectedChime }) {
				let filteredChimes = chimes[selectedIndex...]
				return filteredChimes.first
			}

			return chimes.first
		}() ?? chimes.first

		let selectedChime = UserSettings.selectedChime
		iconTableViewCell.setSelected(chime?.name == selectedChime)
		iconTableViewCell.configureCell(using: chime)

		return iconTableViewCell
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
		let chimes = Chime.shared.appChimeGroups[indexPath.section].chimes[indexPath.row]
		let sameChimeGroup = chimes.contains(where: { $0 == self.selectedChime })
		guard let chime = {
			if sameChimeGroup, let selectedIndex = chimes.firstIndex(where: { $0 == self.selectedChime }) {
				let filteredChimes = chimes[selectedIndex...] + chimes[..<selectedIndex]
				let firstChime = filteredChimes.first
				return firstChime?.alternativeFileRequiredTaps == self.numberOfTaps ? (filteredChimes.dropFirst().first ?? firstChime) : firstChime
			}

			return chimes.first
		}() ?? chimes.first else { return }

		if sameChimeGroup && self.selectedChime?.alternativeFile != nil && self.selectedChime?.alternativeFileRequiredTaps != self.numberOfTaps {
			self.numberOfTaps += 1
		} else {
			self.numberOfTaps = 1
		}

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

		self.selectedChime = chime
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
