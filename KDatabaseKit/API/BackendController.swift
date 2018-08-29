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

//    MARK: - User
    
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

        let endpoint = GlobalVariables().baseUrlString + "user/login"

        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
        .responseJSON { response in
            switch response.result {
                case .success/*(let data)*/:
                if response.result.value != nil{
                    let swiftyJsonVar = JSON(response.result.value!)

                    let responseSuccess = swiftyJsonVar["success"]
                    let responseMessage = swiftyJsonVar["error_message"]
                    let responseSession = swiftyJsonVar["session_secret"]
                    let responseUserId = swiftyJsonVar["user_id"].intValue

                    if responseSession != JSON.null {
                        try? GlobalVariables().KDefaults.set("\(responseUserId)", key: "user_id")
                        try? GlobalVariables().KDefaults.set((responseSession.rawValue as? String)!, key: "session_secret")
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
    public class func logout(_ sessionSecret:String, _ userId:Int, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_secret": sessionSecret,
            "user_id": userId
        ]
        
        let endpoint = GlobalVariables().baseUrlString + "user/logout"
        
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
                NSLog("Logout Response String: \(String(describing: err))")
                SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                NSLog("------------------DATA END-------------------")
            }
        }
    }
    
//    MARK: - Sessions
    
//    Validate session
    public class func validateSession(withSuccess successHandler:@escaping (Bool) -> Void) {
        if User.currentSessionSecret() != nil &&  User.currentId() != nil {
            
            let sessionSecret = User.currentSessionSecret()!
            let userId = User.currentId()!
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let parameters:Parameters = [
                "session_secret": sessionSecret,
                "user_id": userId
            ]
            
            let endpoint = GlobalVariables().baseUrlString + "session/validate"
            
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
                        NSLog("Validate Session Response String: \(String(describing: err))")
                        successHandler(false)
                        NSLog("------------------DATA END-------------------")
                }
            }
        }
        successHandler(false)
    }
    
//    Get sessions
    public class func getSessions(withSuccess successHandler:@escaping ([JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void){
        let sessionSecret = User.currentSessionSecret()
        let userId = User.currentId()
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!
        ]
        
        let endpoint = GlobalVariables().baseUrlString + "user/get_sessions"
        
        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success/*(let data)*/:
                    if response.result.value != nil{
                        let swiftyJsonVar = JSON(response.result.value!)
                        
                        let responseSuccess = swiftyJsonVar["success"]
                        let responseMessage = swiftyJsonVar["error_message"]
                        let responseSessions = swiftyJsonVar["sessions"].array
                        
                        if responseSuccess.boolValue {
                            if responseSessions!.isEmpty {
                                failureHandler("No sessions were found!")
                            }else{
                                successHandler(responseSessions!)
                            }
                        }else{
                            failureHandler(responseMessage.stringValue)
                        }
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Get Session Response String: \(String(describing: err))")
                    failureHandler("There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
    
//    Delete session
    public class func deleteSession(_ id: Int, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        
        let delSessionId = id
        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!,
            "del_session_id": delSessionId
        ]
        
        let endpoint = GlobalVariables().baseUrlString + "user/delete_session"
        
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
                    NSLog("Delete Session Response String: \(String(describing: err))")
                    SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
    
    
//    MARK: - Theme Store
    
//    Get Themes
    public class func getThemes(withSuccess successHandler:@escaping ([JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void){
//        let sessionId = User.currentSessionId()
//        let userId = User.currentId()
        
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
        
//        let parameters:Parameters = [
//            "session_id": sessionId!,
//            "user_id": userId!
//        ]
        
//        let endpoint = GlobalVariables().baseURLString + "user/get_themes"
        let endpoint = "https://api.jsonbin.io/b/5b758d1be013915146d55c8f"
        
        Alamofire.request(endpoint, method: .get /*, parameters: parameters, headers: headers*/)
            .responseJSON { response in
                switch response.result {
                case .success/*(let data)*/:
                    if response.result.value != nil{
                        let swiftyJsonVar = JSON(response.result.value!)
                        
                        let responseSuccess = swiftyJsonVar["success"]
                        let responseMessage = swiftyJsonVar["error_message"]
                        let responseThemes = swiftyJsonVar["themes"].array!
                        
                        if responseSuccess.boolValue {
                            if responseThemes.isEmpty {
                                failureHandler("Themes aren't available at this time!")
                            }else{
                                successHandler(responseThemes)
                            }
                        }else{
                            failureHandler(responseMessage.stringValue)
                        }
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Get Theme Response String: \(String(describing: err))")
                    failureHandler("There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
    
    // Featch anime
    public class func fetchAnime(showId: Int?, score: Double?, withSuccess successHandler:@escaping (FeaturedShows) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        
        let rating = score
        guard let id = showId else { return }
        
        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!,
            "rating": rating!
        ]
        
        let endpoint = GlobalVariables().baseUrlString + "anime/\(id)/rate"
        
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
                    NSLog("Delete Session Response String: \(String(describing: err))")
                    SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
    
    // Rate anime
    public class func rate(showId: Int?, score: Double?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        
        let rating = score
        guard let id = showId else { return }
        
        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!,
            "rating": rating!
        ]
        
        let endpoint = GlobalVariables().baseUrlString + "anime/\(id)/rate"
        
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
                    NSLog("Delete Session Response String: \(String(describing: err))")
                    SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }
}
