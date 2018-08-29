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
        
        if User.currentSessionSecret() != nil {
            
            let sessionId = User.currentSessionSecret()
            let userId = User.currentId()
            let device   = UIDevice.modelName
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let parameters:Parameters = [
                "session_id": sessionId!,
                "user_id": userId!,
                "device": device
            ]
            
            let endpoint = GlobalVariables().baseUrlString + "user/login"
            
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
