//
//  KurozoraReachabilityViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class KurozoraReachabilityViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var blurEffectView: KVisualEffectView!
	@IBOutlet weak var noSignalImageView: UIImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var reconnectButton: UIButton! {
		didSet {
			self.reconnectButton.theme_tintColor = KThemePicker.tintColor.rawValue
		}
	}

	// MARK: - Properties
	var window: UIWindow?
	let networkManager = KNetworkManager.shared

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// If the network is reachable show the main controller
		self.networkManager.reachability.whenReachable = { [weak self] _ in
			guard let self = self else { return }
			KurozoraDelegate.shared.showMainPage(for: self.window, viewController: self)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Hide the navigation bar
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Show the navigation bar
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// MARK: - IBActions
	@IBAction func reconnectButtonPressed(_ sender: UIButton) {
		KNetworkManager.isReachable { [weak self] _ in
			guard let self = self else { return }
			KurozoraDelegate.shared.showMainPage(for: self.window, viewController: self)
		}
	}
}
