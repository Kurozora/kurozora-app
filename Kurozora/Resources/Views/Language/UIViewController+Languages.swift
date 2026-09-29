//
//  UIViewController+Languages.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension UIViewController {
	// MARK: - Functions
	/// Presents the languages a title is available in.
	///
	/// - Parameter source: The title whose languages to present.
	func presentLanguages(for source: LanguagesTableViewController.Source) {
		let languagesTableViewController = LanguagesTableViewController(source: source)
		let navigationController = KNavigationController(rootViewController: languagesTableViewController)

		if let sheetPresentationController = navigationController.sheetPresentationController {
			sheetPresentationController.detents = [.medium(), .large()]
			sheetPresentationController.prefersGrabberVisible = true
		}

		self.present(navigationController, animated: true)
	}
}
