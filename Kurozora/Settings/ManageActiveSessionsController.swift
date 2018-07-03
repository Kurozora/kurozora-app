//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit
import Alamofire
import SwiftyJSON

class ManageActiveSessionsController: UITableViewController {
    
    @IBOutlet weak var currentIPAddress: UILabel!
    @IBOutlet weak var currentDeviceType: UILabel!
    
    let platform = "iOS"
    let device = UIDevice.modelName
    var sessionsArray: [JSON]! = nil
    
    override func viewWillAppear(_ animated: Bool) {
        getSessions()
    }
    
    override func viewDidLoad() {
        currentIPAddress.text = "86.355.x.x"
        currentDeviceType.text = "Kurozora for " + platform + " on " + device
    }
    
    func getSessions(){
        let sessionId = GlobalVariables().KDefaults.string(forKey: "session_id")!
        let userId = GlobalVariables().KDefaults.string(forKey: "user_id")!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "session_id": sessionId,
            "user_id": userId,
            "device": device
        ]
        
        let endpoint = GlobalVariables().BaseURLString + "get_user_sessions"
        
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
                                self.presentBasicAlertWithTitle(title: responseMessage.stringValue)
                            }else{
                                self.sessionsArray = responseSessions
                            }
                        }else{
                            
                        }
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Response String: \(String(describing: err))")
                    self.presentBasicAlertWithTitle(title: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
                }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(SessionsTableViewCell.self, forCellReuseIdentifier: "OtherSessionsCell")
        
        let sessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath as IndexPath) as! SessionsTableViewCell
        
        sessionsCell.ipAddressValueLable?.text = sessionsArray[indexPath.row]["ip_address"].stringValue
        sessionsCell.deviceTypeValueLable?.text = "Kurozora for " + platform + " on " +  sessionsArray[indexPath.row]["device_type"].stringValue
        sessionsCell.dateValueLable?.text = sessionsArray[indexPath.row]["date"].stringValue
        
        return sessionsCell
    }
    
}
