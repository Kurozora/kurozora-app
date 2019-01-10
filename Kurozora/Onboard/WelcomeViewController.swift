//
//  WelcomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import SCLAlertView
import WhatsNew

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

		if WhatsNew.shouldPresent() {
			let whatsNew = WhatsNewViewController(items: [
				WhatsNewItem.image(title: "Very Sleep", subtitle: "Easy on your eyes with the dark theme.", image: #imageLiteral(resourceName: "darkmode")),
				WhatsNewItem.image(title: "High Five", subtitle: "Your privacy is our #1 priority!", image: #imageLiteral(resourceName: "privacy_icon")),
				WhatsNewItem.image(title: "Attention Grabber", subtitle: "New follower? New message? Look here!", image: #imageLiteral(resourceName: "notifications_icon")),
				])
			whatsNew.titleText = "What's New"
			whatsNew.itemSubtitleColor = .darkGray
			whatsNew.buttonText = "Continue"
			whatsNew.buttonTextColor = .white
			whatsNew.buttonBackgroundColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
			present(whatsNew, animated: true, completion: nil)
		}

		if let logoutReason = logoutReason, logoutReason != "", let isKiller = isKiller, !isKiller {
			SCLAlertView().showInfo("You have been logged out", subTitle: logoutReason)
			self.logoutReason = ""
		}
	}
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
