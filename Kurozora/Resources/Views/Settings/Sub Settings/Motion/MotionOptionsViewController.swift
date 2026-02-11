//
//  MotionOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

protocol MotionOptionsViewControllerDelegate: AnyObject {
	func motionOptionsViewController(_ vc: MotionOptionsViewController, didChangeAnimationTo animation: SplashScreenAnimation)
}

class MotionOptionsViewController: SubSettingsViewController {
	// MARK: - Properties
	weak var delegate: MotionOptionsViewControllerDelegate?
	private var selectedAnimation: SplashScreenAnimation = UserSettings.currentSplashScreenAnimation

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

		self.title = Trans.splashScreen
	}
}

// MARK: - UITableViewDataSource
extension MotionOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return SplashScreenAnimation.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Couldn't dequeue cell with identifier \(IconTableViewCell.reuseID)")
		}
		let animation = SplashScreenAnimation.allCases[indexPath.row]
		let currentAnimation = UserSettings.currentSplashScreenAnimation

		iconTableViewCell.setSelected(animation.titleValue == currentAnimation.titleValue)
		iconTableViewCell.configureCell(using: animation)

		return iconTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension MotionOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let animation = SplashScreenAnimation.allCases[indexPath.row]

		self.changeAnimation(animation)
	}

	private func changeAnimation(_ animation: SplashScreenAnimation) {
		Animation.shared.changeAnimation(to: animation)

		self.selectedAnimation = animation
		self.delegate?.motionOptionsViewController(self, didChangeAnimationTo: animation)

		self.tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension MotionOptionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
