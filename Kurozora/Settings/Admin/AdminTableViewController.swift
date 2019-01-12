//
//  AdminTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KCommonKit
import EmptyDataSet_Swift

class AdminTableViewController: UITableViewController, EmptyDataSetDelegate, EmptyDataSetSource {
    let kDefaultItems = GlobalVariables().KDefaults.allItems()
    let kDefaultKeys = GlobalVariables().KDefaults.allKeys()
    var kDefaultCount = GlobalVariables().KDefaults.allItems().count
    
    override func viewDidLoad() {
        super.viewDidLoad()

		// Setup table view
		tableView.dataSource = self
        tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No badges found!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(false)
		}
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let KDefaultsTableViewCell = self.tableView.cellForRow(at: indexPath) as! KDefaultsCell
            guard let key = KDefaultsTableViewCell.keyLabel.text else {return}
            
            self.tableView.beginUpdates()
            try? GlobalVariables().KDefaults.remove(key)
            self.kDefaultCount = kDefaultCount - 1
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kDefaultCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kDefaultsCell:KDefaultsCell = self.tableView.dequeueReusableCell(withIdentifier: "KDefaultsCell", for: indexPath) as! KDefaultsCell
        
        if let key = kDefaultItems[indexPath.row]["key"] as? String, key != "" {
            kDefaultsCell.keyLabel.text = key
        }
        if let value = kDefaultItems[indexPath.row]["value"] as? String, value != "" {
            kDefaultsCell.valueTextField.text = value
        }

        return kDefaultsCell
    }
}
