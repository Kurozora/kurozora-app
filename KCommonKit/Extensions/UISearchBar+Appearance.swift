//
//  UISearchBar+Appearance.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

extension UISearchBar {
    public func enableCancelButton() {
        for view1 in subviews {
            for view2 in view1.subviews where view2.isKind(of: UIButton.self) {
                let button = view2 as! UIButton
                button.isEnabled = true
                button.isUserInteractionEnabled = true
            }
        }
    }
}
