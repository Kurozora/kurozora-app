//
//  PrivacySettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class PrivacySettingsViewController: SubSettingsViewController {
}

// MARK: - UITableViewDataSource
extension PrivacySettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath {
		case [0, 0]:
			#if targetEnvironment(macCatalyst)
			let settingsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")
			#else
			let settingsUrl = URL(string: UIApplication.openSettingsURLString)
			#endif

			UIApplication.shared.kOpen(settingsUrl)
		default: return
		}
	}
}
