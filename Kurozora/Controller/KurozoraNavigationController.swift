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
        
        self.navigationBar.isTranslucent = true
        
        // Navigation bar
        self.navigationBar.barStyle = .black
        self.navigationBar.barTintColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
        
        // Navigation item
        self.navigationBar.tintColor = UIColor.init(red: 255/255.0, green: 147/255.0, blue: 0/255.0, alpha: 1.0)
        
        // Navigation Title
        self.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0), .font: UIFont.systemFont(ofSize: 18.0)]
        
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
            self.navigationBar.largeTitleTextAttributes = [.foregroundColor : UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)]
        }
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
