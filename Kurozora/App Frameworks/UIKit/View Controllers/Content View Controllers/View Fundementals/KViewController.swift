//
//  KViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A supercharged object that manages a view hierarchy for your UIKit app.
///
/// This implemenation of [UIViewController](apple-reference-documentation://hs37A1uTs6) implements the following behavior:
/// - The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.
///
/// Create a custom subclass of `KViewController` for each view that you manage.
///
/// - Tag: KViewController
class KViewController: UIViewController {
	// MARK: - Properties
	/// The gradient view object of the view controller.
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

		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared init of the view controller.
	private func sharedInit() {
		// Configure the gradient view.
		self.configureGradientView()
	}

	/// Configures the gradient view with default values.
	fileprivate func configureGradientView() {
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
