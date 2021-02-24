//
//  FollowTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FollowTableViewController: KTableViewController {
	// MARK: - Properties
	var userFollow: [User] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData {
				self.toggleEmptyDataView()
			}
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.followList.stringValue) list!")
			#endif
		}
	}
	var followList: FollowList = .followers
	var user: User?
	var nextPageURL: String?

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK:- Views
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = self.followList.stringValue

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.followList.stringValue) list!")
		#endif

		// Fetch follow list.
		DispatchQueue.global(qos: .background).async {
			self.fetchFollowList()
		}
    }

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchFollowList()
	}

	override func configureEmptyDataView() {
		var detailString: String
		var buttonTitle: String = ""
		var buttonAction: (() -> Void)? = nil

		let username = self.user?.attributes.username
		switch followList {
		case .followers:
			if self.user?.id == User.current?.id {
				detailString = "Follow other users so they will follow you back. Who knows, you might meet your next BFF!"
			} else {
				detailString = "Be the first to follow \(username ?? "this user")!"
				buttonTitle = "＋ Follow \(username ?? "User")"
				buttonAction = {
					self.followUser()
				}
			}
		case .following:
			if self.user?.id == User.current?.id {
				detailString = "Follow a user and they will show up here!"
			} else {
				detailString = "\(username ?? "This user") is not following anyone yet."
			}
		}

		emptyBackgroundView.configureImageView(image: R.image.empty.follow()!)
		emptyBackgroundView.configureLabels(title: "No \(self.followList.stringValue)", detail: detailString)
		emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfSections == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/// Sends a request to follow the user whose followers list is being viewed.
	func followUser() {
		guard let userID = user?.id else { return }

		WorkflowController.shared.isSignedIn {
			KService.updateFollowStatus(forUserID: userID) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let followUpdate):
					DispatchQueue.main.async {
						self.user?.attributes.update(using: followUpdate)
						self.handleRefreshControl()
					}
				case .failure: break
				}
			}
		}
	}

	/// Fetch the follow list for the currently viewed profile.
    func fetchFollowList() {
		guard let userID = user?.id else { return }

		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing \(self.followList.stringValue) list...")
			#endif
		}

		KService.getFollowList(forUserID: userID, self.followList, next: nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let userFollow):
				DispatchQueue.main.async {
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.userFollow = []
					}

					// Append new data and save next page url
					self.userFollow.append(contentsOf: userFollow.data)
					self.nextPageURL = userFollow.next
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? FollowCell {
			if segue.identifier == R.segue.followTableViewController.profileSegue.identifier {
				if let profileTableViewController = segue.destination as? ProfileTableViewController {
					profileTableViewController.userID = currentCell.user.id
				}
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension FollowTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return userFollow.count
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let followCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.followCell, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(R.reuseIdentifier.followCell.identifier)")
		}
		followCell.delegate = self
		followCell.user = userFollow[indexPath.section]
        return followCell
    }
}

// MARK: - FollowCellDelegate
extension FollowTableViewController: FollowCellDelegate {
	func followCell(_ cell: FollowCell, didPressButton button: UIButton) {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		var user = self.userFollow[indexPath.section]
		KService.updateFollowStatus(forUserID: user.id) { result in
			switch result {
			case .success(let followUpdate):
				user.attributes.update(using: followUpdate)
				cell.updateFollowButton()
			case .failure: break
			}
		}
	}
}
