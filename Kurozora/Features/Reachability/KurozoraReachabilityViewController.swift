//
//  KurozoraReachabilityViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class KurozoraReachabilityViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var blurEffectView: UIVisualEffectView! {
		didSet {
			blurEffectView.theme_effect = ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue)
		}
	}
	@IBOutlet weak var noSignalImageView: UIImageView!
	@IBOutlet weak var primaryLabel: UILabel! {
		didSet {
			primaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var secondaryLabel: UILabel! {
		didSet {
			secondaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var reconnectButton: UIButton! {
		didSet {
			reconnectButton.theme_tintColor = KThemePicker.tintColor.rawValue
		}
	}

	// MARK: - Properties
	var window: UIWindow?
	let network = KNetworkManager.shared

	// MARK: - Views
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Hide the navigation bar
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// If the network is reachable show the main controller
		network.reachability.whenReachable = { _ in
			Kurozora.shared.showMainPage(for: self.window, viewController: self)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Show the navigation bar
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "reachability", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "KurozoraReachabilityViewController")
	}

	// MARK: - IBActions
	@IBAction func reconnectButtonPressed(_ sender: UIButton) {
		KNetworkManager.isReachable { _ in
			Kurozora.shared.showMainPage(for: self.window, viewController: self)
		}
	}
}
