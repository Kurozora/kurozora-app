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
        Service.shared.getSessions( withSuccess: { (array) in
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
            let point = sender.superview!.convert(center, to: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: point)
            let cell = self.tableView.cellForRow(at: indexPath!) as! SessionsCell
            let sessionSecret =  Int(cell.extraLable.text!)
            
            Service.shared.deleteSession(sessionSecret!, withSuccess: { (success) in
                if success {
                    // Get index path for cell
                    let buttonPosition: CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
                    if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                        
                        // Start delete process
                        self.tableView.beginUpdates()
                        
                        if self.sessionsArray.count == 2 {
                            self.sessionsArray.removeAll()
                        } else {
                            self.sessionsArray.remove(at: indexPath.row)
                        }
                        
                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                        
                        self.tableView.endUpdates()
                    }
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

    // Cell header
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

    // Number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sessionsCount = sessionsArray.count
        
        if sessionsCount <= 1 {
            return sessionsCount
        }
        
        return sessionsCount - 1
    }

    // Initialize cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionsCount = sessionsArray.count
        
        // No other sessions
        if sessionsCount == 1 {
            currentIPAddress.text = sessionsArray[indexPath.row]["ip"].stringValue
            currentDeviceType.text = "Kurozora for " + sessionsArray[indexPath.row]["device"].stringValue
            
            let sessionsCell:NoSessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "NoSessionsCell", for: indexPath as IndexPath) as! NoSessionsCell
            sessionsCell.noSessionsLabel.text = "No other sessions found!"
            return sessionsCell
        }
        
        // Other sessions found
        let sessionsCell:SessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath as IndexPath) as! SessionsCell
        
        var index = indexPath.row
     
        if sessionsArray[index]["secret"].stringValue == User.currentSessionSecret() {
            currentIPAddress.text = sessionsArray[index]["ip"].stringValue
            currentDeviceType.text = "Kurozora for " + sessionsArray[index]["device"].stringValue
        }
        
        index = index + 1
        
        // Init IP Address
        sessionsCell.ipAddressLable.text = "IP-Adress:"
        sessionsCell.ipAddressValueLable.text = sessionsArray[index]["ip"].stringValue
        
        // Init Device Type
        sessionsCell.deviceTypeLable.text = "Device Type:"
        sessionsCell.deviceTypeValueLable.text = "Kurozora for " + sessionsArray[index]["device"].stringValue
        
        // Init Last Accessed
        sessionsCell.dateLable.text = "Last Accessed:"
        sessionsCell.dateValueLable?.text = sessionsArray[index]["last_validated"].stringValue
        
        // Init ID
        sessionsCell.extraLable.text = sessionsArray[index]["id"].stringValue
        sessionsCell.removeSessionButton.tag = index

        return sessionsCell
    }
    
}
