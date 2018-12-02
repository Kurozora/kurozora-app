//
//  WelcomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import SCLAlertView

class WelcomeViewController: UIViewController {
	var logoutReason: String? = ""
	var isKiller: Bool?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if let logoutReason = logoutReason, logoutReason != "", let isKiller = isKiller, !isKiller {
			SCLAlertView().showInfo("You have been logged out", subTitle: logoutReason)
			self.logoutReason = ""
		}
	}
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
