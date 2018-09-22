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

    var sessionsArray: [JSON]?
    
    override func viewWillAppear(_ animated: Bool) {
        Service.shared.getSessions( withSuccess: { (sessions) in
            if let session = sessions {
                self.sessionsArray = session.otherSessions
                self.updateCurrentSession(with: session)
            }

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
    
    func updateCurrentSession(with session: Session?) {
        if let sessionIp = session?.ip {
            currentIPAddress.text = sessionIp
        }
        if let sessionDevice = session?.device {
            currentDeviceType.text = "Kurozora for " + sessionDevice
        }
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
                        self.sessionsArray?.remove(at: indexPath.row)
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
        guard let sessionsCount = sessionsArray?.count else {return 0}
        
        return sessionsCount
    }

    // Initialize cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionsCount = sessionsArray?.count
        
        // No other sessions
        if sessionsCount == 0 {
            let sessionsCell:NoSessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "NoSessionsCell", for: indexPath as IndexPath) as! NoSessionsCell
            sessionsCell.noSessionsLabel.text = "No other sessions found!"
            return sessionsCell
        }
        
        // Other sessions found
        let sessionsCell:SessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath as IndexPath) as! SessionsCell
        
        // Init IP Address
        sessionsCell.ipAddressLable.text = "IP-Adress:"
        if let ipAddress = sessionsArray?[indexPath.row]["ip"].stringValue {
            sessionsCell.ipAddressValueLable.text = ipAddress
        }
        
        // Init Device Type
        sessionsCell.deviceTypeLable.text = "Device Type:"
        if let deviceType = sessionsArray?[indexPath.row]["device"].stringValue {
            sessionsCell.deviceTypeValueLable.text = "Kurozora for " + deviceType
        }
        
        // Init Last Accessed
        sessionsCell.dateLable.text = "Last Accessed:"
        if let lastValidated = sessionsArray?[indexPath.row]["last_validated"].stringValue {
            sessionsCell.dateValueLable?.text = lastValidated
        }
        
        // Init misc
        if let id = sessionsArray?[indexPath.row]["id"].stringValue {
            sessionsCell.extraLable.text = id
        }
        sessionsCell.removeSessionButton.tag = indexPath.row

        return sessionsCell
    }
    
}
