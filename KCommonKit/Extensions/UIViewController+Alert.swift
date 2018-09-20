//
//  UIViewController+Alert.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 19/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

extension UIViewController {
    public func presentBasicAlertWithTitle(title: String, message: String? = nil, style: UIAlertController.Style = .alert) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
