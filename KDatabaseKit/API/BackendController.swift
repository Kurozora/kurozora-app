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

//    Login user
    public class func login(_ username:String, _ password:String, _ device:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let parameters:Parameters = [
            "username": username,
            "password": password,
            "device": device
        ]

        let endpoint = GlobalVariables().BaseURLString + "user/login"

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
    
//    Logout user
    public class func logout(_ sessionId:String, _ userId:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_id": sessionId,
            "user_id": userId
        ]
        
        let endpoint = GlobalVariables().BaseURLString + "user/logout"
        
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

//    Validate session
    public class func validateSession(withSuccess successHandler:@escaping (Bool) -> Void) {
        if User.currentSessionId() != nil &&  User.currentId() != nil {
            
            let sessionId = User.currentSessionId()!
            let userId = User.currentId()!
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let parameters:Parameters = [
                "session_id": sessionId,
                "user_id": userId
            ]
            
            let endpoint = GlobalVariables().BaseURLString + "session/validate"
            
            Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                    case .success/*(let data)*/:
                        if response.result.value != nil{
                            let swiftyJsonVar = JSON(response.result.value!)
                            
                            let responseSuccess = swiftyJsonVar["success"]
                            
                            if responseSuccess.boolValue {
                                successHandler(true)
                            }else{
                                successHandler(false)
                            }
                        }
                    case .failure(let err):
                        NSLog("------------------DATA START-------------------")
                        NSLog("Response String: \(String(describing: err))")
                        successHandler(false)
                        NSLog("------------------DATA END-------------------")
                }
            }
        }
    }
    
//    Get sessions
    public class func getSessions(withSuccess successHandler:@escaping ([JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void){
        let sessionId = User.currentSessionId()
        let userId = User.currentId()
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_id": sessionId!,
            "user_id": userId!
        ]
        
        let endpoint = GlobalVariables().BaseURLString + "user/get_sessions"
        
        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success/*(let data)*/:
                    if response.result.value != nil{
                        let swiftyJsonVar = JSON(response.result.value!)
                        
                        let responseSuccess = swiftyJsonVar["success"]
                        let responseMessage = swiftyJsonVar["error_message"]
                        let responseSessions = swiftyJsonVar["sessions"].array!
                        
                        if responseSuccess.boolValue {
                            if responseSessions.isEmpty {
                                failureHandler("No sessions were found!")
                            }else{
                                successHandler(responseSessions)
                            }
                        }else{
                            failureHandler(responseMessage.stringValue)
                        }
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Response String: \(String(describing: err))")
                    failureHandler("There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
    
//    Delete session
    public class func deleteSession (_ id: String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        
        let delSessionId = id
        let sessionId = try? GlobalVariables().KDefaults.getString("session_id")!
        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_id": sessionId!,
            "user_id": userId!,
            "del_session_id": delSessionId
        ]
        
        let endpoint = GlobalVariables().BaseURLString + "user/delete_session"
        
        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success/*(let data)*/:
                    if response.result.value != nil{
                        let swiftyJsonVar = JSON(response.result.value!)
                        
                        let responseSuccess = swiftyJsonVar["success"]
                        let responseMessage = swiftyJsonVar["error_message"]
                        
                        if responseSuccess.boolValue {
                            successHandler(true)
                        }else{
                            failureHandler(responseMessage.stringValue)
                        }
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Response String: \(String(describing: err))")
                    SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
    
}

