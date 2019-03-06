//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import SwifterSwift

class ManageActiveSessionsController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    @IBOutlet var tableView: UITableView!

	@IBOutlet weak var currentSessionTitleLabel: UILabel!
	@IBOutlet weak var ipAddressTitleLabel: UILabel!
	@IBOutlet weak var currentIPAddress: UILabel!
	@IBOutlet weak var deviceTypeTitleLabel: UILabel!
	@IBOutlet weak var currentDeviceType: UILabel!

	var otherSessionsArray: [UserSessionsElement]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		currentSessionTitleLabel.theme_textColor = "Global.textColor"
		ipAddressTitleLabel.theme_textColor = "Global.textColor"
		deviceTypeTitleLabel.theme_textColor = "Global.textColor"

		NotificationCenter.default.addObserver(self, selector: #selector(removeSessionFromTable(_:)), name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(addSessionToTable(_:)), name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil)

		fetchSessions()
        
        // Setup table view
        tableView.dataSource = self
        tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
        
        // Setup empty table view
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "No other sessions found!"))
                .image(UIImage(named: "session_icon"))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
        }
    }

	// MARK: - Functions
	private func fetchSessions() {
		Service.shared.getSessions( withSuccess: { (sessions) in
			DispatchQueue.main.async() {
				self.otherSessionsArray = sessions?.otherSessions
				self.updateCurrentSession(with: sessions?.currentSessions)
				self.tableView.reloadData()
			}
		})
	}

	@objc func removeSessionFromTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["session_id"] as? Int {
			self.tableView.beginUpdates()
			let sessionIndex = otherSessionsArray?.firstIndex(where: { (json) -> Bool in
				return json.id == sessionID
			})

			if let sessionIndex = sessionIndex, sessionIndex != 0 {
				self.otherSessionsArray?.remove(at: sessionIndex)
				self.tableView.deleteRows(at: [IndexPath(row: 0, section: sessionIndex)], with: .left)
			}
			self.tableView.endUpdates()
		}
	}

	@objc func addSessionToTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["id"] as? Int, let device = notification.userInfo?["device"] as? String, let ip = notification.userInfo?["ip"] as? String, let lastValidated = notification.userInfo?["last_validated"] as? String {
			guard let sessionsCount = otherSessionsArray?.count else { return }
			let newSession: JSON = ["id": sessionID,
									"device": device,
									"ip": ip,
									"last_validated": lastValidated
			]
			
			if let newSessionElement = try? UserSessionsElement(json: newSession) {
				self.tableView.beginUpdates()
				self.otherSessionsArray?.append(newSessionElement)
				self.tableView.insertRows(at: [[0, sessionsCount]], with: .right)
				self.tableView.endUpdates()
			}
		}
	}
    
    func updateCurrentSession(with session: UserSessionsElement?) {
        if let sessionIP = session?.ip {
            currentIPAddress.text = sessionIP
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
			let sessionSecret = Int(cell.extraLabel.text!)
            
            Service.shared.deleteSession(sessionSecret!, withSuccess: { (success) in
                if success {
                    // Get index path for cell
                    let buttonPosition: CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
                    if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                        
                        // Start delete process
                        self.tableView.beginUpdates()
                        self.otherSessionsArray?.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                        self.tableView.endUpdates()
                    }
                }
            })
        })

        alertView.showNotice("Confirm deletion", subTitle: "Are you sure you want to delete this session?", closeButtonTitle: "Maybe not now")
    }
}

// MARK: - UITableViewDataSource
extension ManageActiveSessionsController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Other sessions"
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sessionsCount = otherSessionsArray?.count else {return 0}

		return sessionsCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sessionsCount = otherSessionsArray?.count

		// No other sessions
		if sessionsCount == 0 {
			let sessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "NoSessionsCell", for: indexPath) as! NoSessionsCell
			sessionsCell.noSessionsLabel.theme_textColor = "Global.textColor"
			sessionsCell.noSessionsLabel.text = "No other sessions found!"
			return sessionsCell
		}

		// Other sessions found
		let sessionsCell = tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath) as! SessionsCell

		// IP Address
		if let ipAddress = otherSessionsArray?[indexPath.row].ip {
			sessionsCell.ipAddressValueLabel.text = ipAddress
		}

		// Device Type
		if let deviceType = otherSessionsArray?[indexPath.row].device {
			sessionsCell.deviceTypeValueLabel.text = "Kurozora for " + deviceType
		}

		// Last Accessed
		if let lastValidated = otherSessionsArray?[indexPath.row].lastValidated {
			sessionsCell.dateValueLabel?.text = lastValidated
		}

		// Misc
		if let id = otherSessionsArray?[indexPath.row].id {
			sessionsCell.extraLabel.text = "\(id)"
		}
		sessionsCell.removeSessionButton.tag = indexPath.row

		return sessionsCell
	}
}

// MARK: - UITableViewDelegate
extension ManageActiveSessionsController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.font = UIFont.systemFont(ofSize: 17)
			headerView.textLabel?.theme_textColor = "Global.textColor"
		}
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 21
	}
}
