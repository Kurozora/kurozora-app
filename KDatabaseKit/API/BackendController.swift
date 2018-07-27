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

public class Request {

    public class func login(_ username:String, _ password:String, _ device:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let parameters:Parameters = [
            "username": username,
            "password": password,
            "device": device
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
                        GlobalVariables().KDefaults["user_id"] = responseUserId.rawValue as? String
                        GlobalVariables().KDefaults["session_id"] =  responseSession.rawValue as? String
                        try? GlobalVariables().KDefaults.set(username, key: "username")

                        if responseSuccess.boolValue {
                            successHandler(true)
                        } else {
                            failureHandler(responseMessage.stringValue)
                        }
                    } else {
                        failureHandler(responseMessage.stringValue)
                    }
                }
                case .failure/*(let err)*/:
                    failureHandler("There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            }
        }
    }
    
    public class func logout(_ sessionId:String, _ userId:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_id": sessionId,
            "user_id": userId
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
                            successHandler(true)
                        } else {
                            failureHandler(responseMessage.stringValue)
                        }
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Response String: \(String(describing: err))")
                    SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
}

