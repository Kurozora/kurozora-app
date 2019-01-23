//
//  KurozoraNavigationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class KurozoraNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar
		self.navigationBar.isTranslucent = true
        self.navigationBar.barStyle = .black
		self.navigationBar.barTintColor = #colorLiteral(red: 0.2174186409, green: 0.2404800057, blue: 0.332449615, alpha: 1)
		self.navigationBar.backgroundColor = .clear

        // Navigation item
        self.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)

        // Navigation Title
        self.navigationBar.titleTextAttributes = [.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), .font: UIFont.systemFont(ofSize: 18.0)]
        
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
            self.navigationBar.largeTitleTextAttributes = [.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        }
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
