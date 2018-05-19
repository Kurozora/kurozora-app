//
//  String+Validations.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse
//import Bolts
import KCommonKit

extension String {
    public func validEmail(viewController: UIViewController) -> Bool {
        let emailRegex = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        let regularExpression = try? NSRegularExpression(pattern: emailRegex, options: NSRegularExpression.Options.caseInsensitive)
        let matches = regularExpression?.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count))
        
        let validEmail = (matches == 1)
        if !validEmail {
            viewController.presentBasicAlertWithTitle(title: "Invalid email")
        }
        return validEmail
    }
    
    public func validPassword(viewController: UIViewController) -> Bool {
        
        let validPassword = self.count >= 6
        if !validPassword {
            viewController.presentBasicAlertWithTitle(title: "Invalid password", message: "Length should be at least 6 characters")
        }
        return validPassword
    }
    
    public func validUsername(viewController: UIViewController) -> Bool {
        
        switch self {
        case _ where self.count < 3:
            viewController.presentBasicAlertWithTitle(title: "Invalid username", message: "Make it 3 characters or longer")
            return false
        case _ where self.range(of: " ") != nil:
            viewController.presentBasicAlertWithTitle(title: "Invalid username", message: "It can't have spaces")
            return false
        default:
            return true
        }
    }
    
//    public func usernameIsUnique() -> BFTask {
//        let query = User.query()!
//        query.limit = 1
//        query.whereKey("kurozoraUsername", matchesRegex: self, modifiers: "i")
//        return query.findObjectsInBackground()
//    }
}
