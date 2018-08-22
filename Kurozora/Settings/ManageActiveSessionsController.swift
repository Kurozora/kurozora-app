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
import SCLAlertView

class ManageActiveSessionsController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var currentIPAddress: UILabel!
    @IBOutlet weak var currentDeviceType: UILabel!
    
    let device = UIDevice.modelName
    var sessionsArray:[JSON] = []
    
    override func viewWillAppear(_ animated: Bool) {
        Request.getSessions( withSuccess: { (array) in
            self.sessionsArray = array
            
//            Update table with new information
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }) { (errorMsg) in
            SCLAlertView().showError("Sessions", subTitle: errorMsg)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
//    MARK: - IBActions
    @IBAction func removeSession(sender: UIButton!) {
        let alertView = SCLAlertView()
        alertView.addButton("Yes!", action: {
            let center = sender.center
            let point = sender.superview!.convert(center, to:self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: point)
            let cell = self.tableView.cellForRow(at: indexPath!) as! SessionsCell
            let sessionSecret =  Int(cell.extraLable.text!)
            
            Request.deleteSession(sessionSecret!, withSuccess: { (success) in
                if success {
                    let buttonPosition: CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
                    let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
                    self.sessionsArray.remove(at: 1)
                    
                    self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.left)
                }
            }) { (errorMsg) in
                SCLAlertView().showError("Error removing session", subTitle: errorMsg)
            }
        })

        alertView.showNotice("Confirm deletion", subTitle: "Are you sure you want to delete this session?", closeButtonTitle: "Maybe not now")
    }
    
//    MARK: - Table
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Other sessions"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
        
        let headerLabel = UILabel(frame: CGRect(x: 8, y: 0, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "System", size: 17)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionsCell:SessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath as IndexPath) as! SessionsCell
        
        if sessionsArray[indexPath.row]["secret"].stringValue == GlobalVariables().KDefaults["session_secret"] {
            currentIPAddress.text = sessionsArray[indexPath.row]["ip"].stringValue
            currentDeviceType.text = "Kurozora for " + sessionsArray[indexPath.row]["device"].stringValue
        } else {
            sessionsCell.ipAddressLable.text = "IP-Adress:"
            sessionsCell.ipAddressValueLable.text = sessionsArray[indexPath.row]["ip"].stringValue
            sessionsCell.deviceTypeLable.text = "Device Type:"
            sessionsCell.deviceTypeValueLable.text = "Kurozora for " + sessionsArray[indexPath.row]["device"].stringValue
            sessionsCell.dateLable.text = "Last Accessed:"
            sessionsCell.dateValueLable?.text = sessionsArray[indexPath.row]["last_validated"].stringValue
            sessionsCell.extraLable.text = sessionsArray[indexPath.row]["id"].stringValue
            sessionsCell.removeSessionButton.tag = indexPath.row
//            NSLog("------------------DATA START-------------------")
//            NSLog("Response String: \(String(describing: indexPath.row))")
//            NSLog("------------------DATA END-------------------")
        }
        
        return sessionsCell
    }
    
}
