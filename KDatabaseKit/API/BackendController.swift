//
//  BackendController.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit
import Alamofire
import SwiftyJSON
import SCLAlertView

public class Request : UIViewController {

   @IBAction public func login(_ username:Any, password:Any)  {
        
//        var loginSuccess = false
        let usernameString = username as! String
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let parameters:Parameters = [
            "username": username,
            "password": password,
            "device": "iPhone 7"
        ]

        let endpoint = GlobalVariables().BaseURLString + "login"

        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
        .responseJSON { response in
            switch response.result {
                case .success/*(let data)*/:
                if response.result.value != nil{
                let swiftyJsonVar = JSON(response.result.value!)
    
                let responseSuccess = swiftyJsonVar["success"]
                let responseMessage = swiftyJsonVar["error_message"]
                let responseSession = swiftyJsonVar["session_id"]
                let responseUserId = swiftyJsonVar["user_id"]

                if responseSession != JSON.null {
                //                            try? GlobalVariables().KDefaults.set(responseSession.rawValue, key: "session_id")
                //                            try? GlobalVariables().KDefaults.set(responseUserId.rawValue, key: "user_id")
                GlobalVariables().KDefaults["user_id"] = responseUserId.rawValue as? String
                GlobalVariables().KDefaults["session_id"] =  responseSession.rawValue as? String
                try? GlobalVariables().KDefaults.set(usernameString, key: "username")
    
                    if responseSuccess.boolValue {
                        let storyboard:UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileNavigation") as! UINavigationController
                        self.present(vc, animated: false)
                    }else{
                        SCLAlertView().showNotice("Warning!", subTitle: responseMessage.stringValue)
                    }
                }else{
                    SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                }
            }
            case .failure(let err):
                NSLog("------------------DATA START-------------------")
                NSLog("Response String: \(String(describing: err))")
                SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                NSLog("------------------DATA END-------------------")
            }
        }
//        return loginSuccess
    }
    
    @IBAction public func logout(_ sessionId:Any, userId:Any)  {
        
        //        var loginSuccess = false
        let sessionIdString = sessionId as! String
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_id": sessionId,
            "user_id": userId,
            "device": "iPhone 7"
        ]
        
        let endpoint = GlobalVariables().BaseURLString + "logout"
        
        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success/*(let data)*/:
                    if response.result.value != nil{
                        let swiftyJsonVar = JSON(response.result.value!)
                        
                        let responseSuccess = swiftyJsonVar["success"]
                        let responseMessage = swiftyJsonVar["error_message"]
                        
                        if responseSuccess.boolValue {
                            WorkflowController.logoutUser()
                            
                            let storyboard:UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileNavigation") as! UINavigationController
                            self.present(vc, animated: false)
                        }else{
                            SCLAlertView().showNotice("Warning!", subTitle: responseMessage.stringValue)
                        }
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Response String: \(String(describing: err))")
                    SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
        //        return loginSuccess
    }
}
