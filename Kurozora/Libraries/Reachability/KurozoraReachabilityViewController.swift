//
//  KurozoraReachabilityViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import RevealingSplashView

class KurozoraReachabilityViewController: UIViewController {
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var noSignalImageView: UIImageView!

	var window: UIWindow?
	let network = KNetworkManager.shared

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.shadowView.applyShadow()

		// Hide the navigation bar
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// If the network is reachable show the main controller
		network.reachability.whenReachable = { _ in
			Kurozora.showMainPage(for: self.window, viewController: self)
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
			Kurozora.showMainPage(for: self.window, viewController: self)
		}
	}
}
