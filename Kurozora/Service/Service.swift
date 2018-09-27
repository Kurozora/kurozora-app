//
//  Service.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import TRON
import SwiftyJSON
import SCLAlertView

struct Service {
    
    let tron = TRON(baseURL: "https://kurozora.app/api/v1/")
    
    static let shared = Service()
    
//    MARK: - User

//    Login user
    func login(_ username:String, _ password:String, _ device:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/login")

        try? GlobalVariables().KDefaults.set(username, key: "username")

        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "username": username,
            "password": password,
            "device": device
        ]

        request.perform(withSuccess: { user in
            if let success = user.success {
                if success {
                    if let userId = user.id {
                        try? GlobalVariables().KDefaults.set(String(userId), key: "user_id")
                    }
                    
                    if let sessionSecret = user.session {
                        try? GlobalVariables().KDefaults.set(sessionSecret, key: "session_secret")
                    }
                    
                    if let role = user.role {
                        try? GlobalVariables().KDefaults.set(String(role), key: "user_role")
                    }
                    successHandler(success)
                } else {
                    if let responseMessage = user.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            failureHandler("There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received login error: \(error)")
        })
    }
    
//    Reset password
    func resetPassword(_ email:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/reset_password")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "email": email,
        ]
        
        request.perform(withSuccess: { reset in
            if let success = reset.success {
                if success {
                    successHandler(success)
                } else {
                    if let responseMessage = reset.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            failureHandler("There was an error while requesting the reset link. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received reset password error: \(error)")
        })
    }
    
//    Logout user
    func logout(_ sessionSecret:String, _ userId:Int, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/logout")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "user_id": userId,
            "session_secret": sessionSecret
        ]
        
        request.perform(withSuccess: { user in
             if let success = user.success {
                if success {
                    WorkflowController.logoutUser()
                    successHandler(success)
                } else {
                    if let responseMessage = user.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error logging out", subTitle: "There was an error while logging out to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received logout error: \(error)")
        })
    }
    
//    User details
    func getUserProfile(_ userId:Int?, withSuccess successHandler:@escaping (User?) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        guard let id = userId else { return }
        
        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/\(id)/profile")
        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "user_id": userId!,
            "session_secret": sessionSecret!
        ]
        
        request.perform(withSuccess: { userProfile in
            if let success = userProfile.success {
                if success {
                    successHandler(userProfile)
                } else {
                    if let responseMessage = userProfile.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error getting user", subTitle: "There was an error while getting user details. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received user profile error: \(error)")
        })
    }
    
//    MARK: - Sessions
    
//    Validate session
    func validateSession(withSuccess successHandler:@escaping (Bool) -> Void) {
        if User.currentSessionSecret() != nil && User.currentId() != nil {
            let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("session/validate")
            
            let userId = User.currentId()!
            let sessionSecret = User.currentSessionSecret()!
            
            request.headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            request.authorizationRequirement = .required
            request.method = .post
            request.parameters = [
                "user_id": userId,
                "session_secret": sessionSecret
            ]
            
            request.perform(withSuccess: { user in
                if let success = user.success {
                    if success {
                        successHandler(success)
                    } else {
                        successHandler(success)
                    }
                }
            }, failure: { error in
                SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                
                print("Received validate session error: \(error)")
            })
        } else {
            successHandler(false)
        }
    }
    
//    Get sessions
    func getSessions(withSuccess successHandler:@escaping (Session?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
        let request : APIRequest<Session,JSONError> = tron.swiftyJSON.request("user/get_sessions")
        
        let userId = User.currentId()!
        let sessionSecret = User.currentSessionSecret()!
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "user_id": userId,
            "session_secret": sessionSecret
        ]
        
        request.perform(withSuccess: { session in
            if let success = session.success {
                if success {
                    successHandler(session)
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get session error: \(error)")
        })
    }
    
//    Delete session
    func deleteSession(_ id: Int, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        let request : APIRequest<Session,JSONError> = tron.swiftyJSON.request("user/delete_session")
        
        let delSessionId = id
        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!,
            "del_session_id": delSessionId
        ]
        
        request.perform(withSuccess: { session in
            if let success = session.success {
                if success {
                    successHandler(success)
                } else {
                    if let responseMessage = session.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received delete session error: \(error)")
        })
    }
    
    
//    MARK: - Theme Store
    
//    Get Themes
    func getThemes(withSuccess successHandler:@escaping ([JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void){
//        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/login")
//
//        let delSessionId = id
//        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
//        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
//
//        request.headers = [
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
//        request.authorizationRequirement = .required
//        request.method = .post
//        request.parameters = [
//            "session_secret": sessionSecret!,
//            "user_id": userId!,
//            "del_session_id": delSessionId
//        ]
//
//        request.perform(withSuccess: { user in
//            if let success = user.success {
//                if success {
//                    successHandler(responseThemes)
//                } else {
//                    failureHandler("Themes aren't available at this time!")
//                }
//            }
//        }, failure: { error in
//            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
//
//            print("Received delete session error: \(error)")
//        })
//        let endpoint = "https://api.jsonbin.io/b/5b758d1be013915146d55c8f"
//
//        Alamofire.request(endpoint, method: .get /*, parameters: parameters, headers: headers*/)
//            .responseJSON { response in
//                switch response.result {
//                case .success/*(let data)*/:
//                    if response.result.value != nil{
//                        let swiftyJsonVar = JSON(response.result.value!)
//
//                        let responseSuccess = swiftyJsonVar["success"]
//                        let responseMessage = swiftyJsonVar["error_message"]
//                        let responseThemes = swiftyJsonVar["themes"].array!
//
//                        if responseSuccess.boolValue {
//                            if responseThemes.isEmpty {
//                                failureHandler("Themes aren't available at this time!")
//                            }else{
//                                successHandler(responseThemes)
//                            }
//                        }else{
//                            failureHandler(responseMessage.stringValue)
//                        }
//                    }
//                case .failure(let err):
//                    NSLog("------------------DATA START-------------------")
//                    NSLog("Get Theme Response String: \(String(describing: err))")
//                    failureHandler("There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
//                    NSLog("------------------DATA END-------------------")
//                }
//        }
    }

    // Rate anime
    func rate(showId: Int?, score: Double?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        let rating = score
        guard let id = showId else { return }
        
        let request: APIRequest<User,JSONError> = tron.swiftyJSON.request("anime/\(id)/rate")
        
        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!,
            "rating": rating!
        ]
        
        request.perform(withSuccess: { user in
            if let success = user.success {
                if success {
                    successHandler(success)
                } else {
                    if let responseMessage = user.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received rating error: \(error)")
        })
    }
    
    // MARK: - Settings
    
    // Legal
    func getPrivacyPolicy(withSuccess successHandler:@escaping (Privacy?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        
        let request: APIRequest<Privacy,JSONError> = tron.swiftyJSON.request("misc/get_privacy_policy")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.method = .get
        
        request.perform(withSuccess: { privacyPolicy in
            if let success = privacyPolicy.success {
                if success {
                    successHandler(privacyPolicy)
                } else {
                    if let responseMessage = privacyPolicy.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received privacy policy error: \(error)")
        })
    }
    
    // MARK: - Anime Details
    
    // Cast
    func getCastFor(_ id: Int?, withSuccess successHandler:@escaping ([JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        
        guard let id = id else { return }
        
        let request: APIRequest<CastDetails,JSONError> = tron.swiftyJSON.request("anime/\(id)/actors")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.method = .get
        
        request.perform(withSuccess: { cast in
            if let success = cast.success {
                if success {
                    if let cast = cast.actors {
                        successHandler(cast)
                    } else {
                        failureHandler("No actors were found!")
                    }
                } else {
                    if let responseMessage = cast.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received cast error: \(error)")
        })
    }
    
    
    // Throw json error
    class JSONError: JSONDecodable {
        required init(json: JSON) throws {
            print("JSON ERROR \(json)")
        }
    }
}
