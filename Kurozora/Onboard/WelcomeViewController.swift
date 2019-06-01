//
//  WelcomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import WhatsNew

class WelcomeViewController: UIViewController {
	@IBOutlet weak var backgroundImageView: UIImageView!
	
	var logoutReason: String? = ""
	var isKiller: Bool?
	var statusBarShouldBeHidden = true

	override var prefersStatusBarHidden: Bool {
		return statusBarShouldBeHidden
	}

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return UIStatusBarAnimation.slide
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		// Show the status bar
		statusBarShouldBeHidden = true
		UIView.animate(withDuration: 0.25) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		backgroundImageView.addParallax()
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
			whatsNew.itemSubtitleColor = #colorLiteral(red: 0.3300000131, green: 0.3300000131, blue: 0.3300000131, alpha: 1)
			whatsNew.buttonText = "Continue"
			whatsNew.buttonTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
			whatsNew.buttonBackgroundColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
			present(whatsNew, animated: true, completion: nil)
		}

		if let logoutReason = logoutReason, logoutReason != "", let isKiller = isKiller, !isKiller {
			SCLAlertView().showInfo("You have been logged out", subTitle: logoutReason)
			self.logoutReason = ""
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Hide the status bar
		statusBarShouldBeHidden = false
		UIView.animate(withDuration: 0.25) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}
}
