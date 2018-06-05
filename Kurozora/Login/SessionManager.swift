//
//  SessionManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/06/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit
import Alamofire
import SwiftyJSON

public class SessionManager {
    class func verify() -> Bool{
        var segue = false
        
        if GlobalVariables().KDefaults.string(forKey: "session_id") != nil {
            
            let session = GlobalVariables().KDefaults.string(forKey: "session_id")!
            let username = GlobalVariables().KDefaults.string(forKey: "username")!
            let device   = UIDevice.modelName
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let parameters:Parameters = [
                "sessionKey": session,
                "username": username,
                "device": device
            ]
            
            let endpoint = GlobalVariables().BaseURLString + "login"
            
            Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
            switch response.result {
                case .success:
                if response.result.value != nil{
                    let swiftyJsonVar = JSON(response.result.value!)
            
                    let responseSuccess = swiftyJsonVar["success"]
            
                    if responseSuccess.boolValue {
                        segue = true
                    }else{
                        segue = false
                    }
                }
                case .failure/*(let err)*/:
                    segue = false
                }
            }
        }
        return segue
    }
}
