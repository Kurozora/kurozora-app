//
//  BasicTabBarItemContentView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BasicTabBarItemContentView: ESTabBarItemContentView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        ESTabBar.appearance().barTintColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
        textColor = UIColor.init(white: 175.0/255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(red: 255/255.0, green: 147/255.0, blue: 0/255.0, alpha: 1.0)
        iconColor = UIColor.init(white: 175.0/255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(red: 255/255.0, green: 147/255.0, blue: 0/255.0, alpha: 1.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
