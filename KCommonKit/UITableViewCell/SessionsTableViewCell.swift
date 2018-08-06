//
//  SessionsTableViewCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 10/06/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Alamofire
import SwiftyJSON

//public class SessionsTableViewCell: UITableViewCell {

//    @IBOutlet weak var ipAddressLable: UILabel!
//    @IBOutlet weak var ipAddressValueLable: UILabel!
//    @IBOutlet weak var deviceTypeLable: UILabel!
//    @IBOutlet weak var deviceTypeValueLable: UILabel!
//    @IBOutlet weak var dateLable: UILabel!
//    @IBOutlet weak var dateValueLable: UILabel!
//
//    @IBAction func removeSessionTapped(_ sender: AnyObject) {
//        let deleteButtonTag = sender.tag
//
//        let sessionId = try? GlobalVariables().KDefaults.getString("session_id")!
//        let userId = try? GlobalVariables().KDefaults.getString("user_id")!

//        let headers: HTTPHeaders = [
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
//
//        let parameters:Parameters = [
//            "session_id": sessionId!,
//            "user_id": userId!
//        ]
//
//        let endpoint = GlobalVariables().BaseURLString + "user/delete_session"
//
//        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
//            .responseJSON { response in
//                switch response.result {
//                case .success/*(let data)*/:
//                    if response.result.value != nil{
//                        let swiftyJsonVar = JSON(response.result.value!)
//
//                        let responseSuccess = swiftyJsonVar["success"]
//
//                        if responseSuccess.boolValue {
//                        }else{
//                        }
//                    }
//                case .failure(let err):
//                    NSLog("------------------DATA START-------------------")
//                    NSLog("Response String: \(String(describing: err))")
////                    self.presentBasicAlertWithTitle(title: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
//                    NSLog("------------------DATA END-------------------")
//                }
//        }
//    }
//    }
//}
