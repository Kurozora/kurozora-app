//
//  SettingsSplitViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SettingsSplitViewController: UISplitViewController {
	// MARK: - Properties
	private var gradientView: GradientView = {
		let gradientView = GradientView()
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.gradientLayer?.theme_colors = KThemePicker.backgroundColors.gradientPicker
		return gradientView
	}()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.delegate = self

		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared init of the view controller.
	private func sharedInit() {
		self.view.addSubview(self.gradientView)
		self.view.sendSubviewToBack(self.gradientView)

		NSLayoutConstraint.activate([
			self.gradientView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.gradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.gradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.gradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		])
	}
}

// MARK: - UISplitViewControllerDelegate
extension SettingsSplitViewController: UISplitViewControllerDelegate {
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return true
	}

	func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
		return .primary
	}
}
