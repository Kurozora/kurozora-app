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
        UIBarButtonItem.appearance()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
        
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
            self.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)]
        }

        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18.0)]
    }
    
}
