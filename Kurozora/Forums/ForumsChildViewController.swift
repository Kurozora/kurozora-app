//
//  ForumsChildViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift

class ForumsChildViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EmptyDataSetSource, EmptyDataSetDelegate {
    @IBOutlet var tableView: UITableView!

	private let refreshControl = UIRefreshControl()

    var sectionTitle: String?
	var sectionId: Int?
	var forumThreads: [JSON]?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let sectionTitle = sectionTitle else {return}

		// Add Refresh Control to Table View
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl)
		}

		refreshControl.tintColor = UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		refreshControl.addTarget(self, action: #selector(refreshThreadsData(_:)), for: .valueChanged)

		fetchThreads()
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup empty table view
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: sectionTitle))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(false)
        }
    }

	@objc private func refreshThreadsData(_ sender: Any) {
		guard let sectionTitle = sectionTitle?.lowercased() else {return}
		refreshControl.attributedTitle = NSAttributedString(string: "Reloading \(sectionTitle) threads", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		fetchThreads()
	}

	private func fetchThreads() {
		guard let sectionTitle = sectionTitle else {return}
		guard let sectionId = sectionId else {return}

		Service.shared.getForumThreads(forSection: sectionId, order: "top", page: 0, withSuccess: { (threads) in
			DispatchQueue.main.async {
				self.forumThreads = threads
				self.tableView.reloadData()
				self.refreshControl.endRefreshing()
				self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
			}
		}) { (errorMessage) in
			self.refreshControl.endRefreshing()
			SCLAlertView().showError("Error getting threads", subTitle: errorMessage)
		}
	}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let threadsCount = forumThreads?.count, threadsCount != 0 {
			return threadsCount
		}

        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let threadCell:ThreadCell = tableView.dequeueReusableCell(withIdentifier: "ThreadCell") as! ThreadCell

		if let threadTitle = forumThreads?[indexPath.row]["title"].stringValue, threadTitle != "" {
			threadCell.titleLabel.text = threadTitle
		} else {
			threadCell.titleLabel.text = "Unknown"
		}

		if let threadCreator = forumThreads?[indexPath.row]["poster_username"].stringValue, threadCreator != "" {
			threadCell.usernameLabel.text = threadCreator
		} else {
			threadCell.usernameLabel.text = "Unknown"
		}

		if let threadPostCount = forumThreads?[indexPath.row]["reply_count"].intValue, let creationDate = forumThreads?[indexPath.row]["creation_date"].stringValue, creationDate != "" {
			threadCell.informationLabel.text = " \(threadPostCount) \((threadPostCount > 1 ? "Comments" : "Comment")) · \(Date.timeAgo(creationDate))"
		}

        return threadCell
    }
    
}
