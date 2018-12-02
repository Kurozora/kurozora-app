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
	var forumPosts: [JSON]?

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
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) posts", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		refreshControl.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)

		fetchPosts()
        
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

	@objc private func refreshPostsData(_ sender: Any) {
		guard let sectionTitle = sectionTitle?.lowercased() else {return}
		refreshControl.attributedTitle = 			NSAttributedString(string: "Reloading \(sectionTitle) posts", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		fetchPosts()
	}

	private func fetchPosts() {
		guard let sectionTitle = sectionTitle else {return}
		guard let sectionId = sectionId else {return}

		Service.shared.getForumPosts(forSection: sectionId, order: "top", page: 0, withSuccess: { (posts) in
			DispatchQueue.main.async {
				self.forumPosts = posts
				self.tableView.reloadData()
				self.refreshControl.endRefreshing()
				self.refreshControl.attributedTitle = 			NSAttributedString(string: "Pull to refresh \(sectionTitle) posts", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
			}
		}) { (errorMessage) in
			self.refreshControl.endRefreshing()
			SCLAlertView().showError("Error getting posts", subTitle: errorMessage)
		}
	}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let postsCount = forumPosts?.count, postsCount != 0 {
			return postsCount
		}

        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let postCell = tableView.dequeueReusableCell(withIdentifier: "TopicCell") as! TopicCell

		if let postTitle = forumPosts?[indexPath.row]["title"].stringValue, postTitle != "" {
			postCell.titleLabel.text = postTitle
		}

		postCell.typeLabel.text = ""
		postCell.tagsLabel.text = "#KurozoraBiash"
		postCell.informationLabel.text = " 3 Comments · 10 hrs"

        return postCell
    }
    
}
