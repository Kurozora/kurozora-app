//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import SwifterSwift

class ManageActiveSessionsController: UIViewController {
    @IBOutlet var tableView: UITableView!

	var dismissEnabled: Bool = false
	var sessions: UserSessions? {
		didSet {
			tableView.reloadData()
		}
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		if dismissEnabled {
			let closeButton = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(dismiss(_:)))
			self.navigationItem.leftBarButtonItem  = closeButton
		}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		NotificationCenter.default.addObserver(self, selector: #selector(removeSessionFromTable(_:)), name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(addSessionToTable(_:)), name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil)

		fetchSessions()
        
        // Setup table view
        tableView.dataSource = self
        tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
    }

	// MARK: - Functions
	private func fetchSessions() {
		Service.shared.getSessions( withSuccess: { (sessions) in
			DispatchQueue.main.async() {
				self.sessions = sessions
			}
		})
	}

	@objc func dismiss(_ sender: Any?) {
		self.dismiss(animated: true, completion: nil)
	}

	private func removeSession(_ otherSessionsCell: OtherSessionsCell) {
		let alertView = SCLAlertView()
		alertView.addButton("Yes!", action: {
			let sessionSecret = otherSessionsCell.sessions?.id

			Service.shared.deleteSession(sessionSecret, withSuccess: { (success) in
				if success {
					// Get index path for cell
					if let indexPath = self.tableView.indexPath(for: otherSessionsCell) {
						// Start delete process
						self.tableView.beginUpdates()
						self.sessions?.otherSessions?.remove(at: indexPath.row)
						self.tableView.deleteRows(at: [indexPath], with: .left)
						self.tableView.endUpdates()
					}
				}
			})
		})

		alertView.showNotice("Confirm deletion", subTitle: "Are you sure you want to delete this session?", closeButtonTitle: "Maybe not now")
	}

	@objc func removeSessionFromTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["session_id"] as? Int {
			self.tableView.beginUpdates()
			let sessionIndex = self.sessions?.otherSessions?.firstIndex(where: { (json) -> Bool in
				return json.id == sessionID
			})

			if let sessionIndex = sessionIndex, sessionIndex != 0 {
				self.sessions?.otherSessions?.remove(at: sessionIndex)
				self.tableView.deleteRows(at: [IndexPath(row: 0, section: sessionIndex)], with: .left)
			}
			self.tableView.endUpdates()
		}
	}

	@objc func addSessionToTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["id"] as? Int, let device = notification.userInfo?["device"] as? String, let ip = notification.userInfo?["ip"] as? String, let lastValidated = notification.userInfo?["last_validated"] as? String {
			guard let sessionsCount = sessions?.otherSessions?.count else { return }
			let newSession: JSON = ["id": sessionID,
									"device": device,
									"ip": ip,
									"last_validated": lastValidated
			]
			
			if let newSessionElement = try? UserSessionsElement(json: newSession) {
				self.tableView.beginUpdates()
				self.sessions?.otherSessions?.append(newSessionElement)
				self.tableView.insertRows(at: [[1, sessionsCount]], with: .right)
				self.tableView.endUpdates()
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageActiveSessionsController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Current Session"
		} else {
			return "Other Sessions"
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
			guard let sessionsCount = sessions?.otherSessions?.count else { return 0 }
			return sessionsCount
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let currentSessionCell = tableView.dequeueReusableCell(withIdentifier: "CurrentSessionCell", for: indexPath) as! CurrentSessionCell
			currentSessionCell.session = sessions?.currentSessions
			return currentSessionCell
		} else {
			let otherSessionsCount = sessions?.otherSessions?.count

			// No other sessions
			if otherSessionsCount == 0 {
				let noSessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "NoSessionsCell", for: indexPath) as! NoSessionsCell
				return noSessionsCell
			}

			// Other sessions found
			let otherSessionsCell = tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath) as! OtherSessionsCell

			otherSessionsCell.delegate = self
			otherSessionsCell.sessions = sessions?.otherSessions?[indexPath.row]

			return otherSessionsCell
		}
	}
}

// MARK: - UITableViewDelegate
extension ManageActiveSessionsController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.font = UIFont.systemFont(ofSize: 15)
			headerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
}

// MARK: - OtherSessionsCellDelegate
extension ManageActiveSessionsController: OtherSessionsCellDelegate {
	func removeSession(for otherSessionsCell: OtherSessionsCell) {
		self.removeSession(otherSessionsCell)
	}
}
