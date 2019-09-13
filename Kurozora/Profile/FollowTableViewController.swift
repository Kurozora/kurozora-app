//
//  FollowTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class FollowTableViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	var userFollow: [UserProfile]! {
		didSet {
			tableView.reloadData()
		}
	}
	var followList: String = "followers"
	var currentPage = 0
	var lastPage = 0

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		title = "\(followList.capitalized) List"
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		fetchFollowList()

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No \(self.followList) to show."))
				.image(#imageLiteral(resourceName: "profile"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
		}
    }

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? FollowCell {
			if segue.identifier == "ProfileSegue" {
				if let profileTableViewController = segue.destination as? ProfileTableViewController {
					profileTableViewController.otherUserID = currentCell.userProfile?.id
				}
			}
		}
	}

	// MARK: - Functions
    func fetchFollowList() {
		Service.shared.getFollow(for: followList, page: 0) { (userFollow) in
			self.currentPage = userFollow?.currentPage ?? 0
			self.lastPage = userFollow?.lastPage ?? 0
			self.userFollow = userFollow?.following ?? userFollow?.followers
		}
	}
}

// MARK: - UITableViewDataSource
extension FollowTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let followCount = userFollow?.count else { return 0 }
		return followCount
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let followCell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
		followCell.userProfile = userFollow?[indexPath.row]
        return followCell
    }
}

// MARK: - UITableViewDelegate
extension FollowTableViewController {

}
