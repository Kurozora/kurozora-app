//
//  FollowTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class FollowTableViewController: KTableViewController {
	// MARK: - Properties
	var userFollow: [UserProfile]! {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var followList: String = "Followers"
	var user: UserProfile?

	// Pagination
	var currentPage = 1
	var lastPage = 1

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
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = followList

		// Fetch follow list.
		DispatchQueue.global(qos: .background).async {
			self.fetchFollowList()
		}
    }

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			if let username = self.user?.username {
				if self.followList == "Followers" {
					let detailLabelString = self.user?.id != User.currentID ? "Be the first to follow \(username)!" : "Follow other users so they will follow you back. Who knows, you might meet your next BFF!"

					view.titleLabelString(NSAttributedString(string: "No \(self.followList)", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
						.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
						.image(#imageLiteral(resourceName: "empty_follow"))
						.imageTintColor(KThemePicker.textColor.colorValue)
						.verticalOffset(-50)
						.verticalSpace(5)
						.isScrollAllowed(true)

					if self.user?.id != User.currentID, !(self.user?.following ?? true) {
						view.buttonTitle(NSAttributedString(string: "＋ Follow \(username)", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue]), for: .normal)
							.buttonTitle(NSAttributedString(string: "＋ Follow \(username)", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue.darken()]), for: .highlighted)
							.didTapDataButton {
								self.followUser()
						}
					}
				} else {
					let detailLabelString = self.user?.id != User.currentID ? "\(username) is not following anyone yet." : "Follow a user and they will show up here!"

					view.titleLabelString(NSAttributedString(string: "No \(self.followList)", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
						.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
						.image(#imageLiteral(resourceName: "empty_follow"))
						.imageTintColor(KThemePicker.textColor.colorValue)
						.verticalOffset(-50)
						.verticalSpace(5)
						.isScrollAllowed(true)
				}
			}
		}
	}

	/// Sends a request to follow the user whose followers list is being viewed.
	func followUser() {
		guard let userID = user?.id else { return }
		KService.shared.follow(1, user: userID) { (success) in
			if success {
				self.fetchFollowList()
			}
		}
	}

	/// Fetch the follow list for the currently viewed profile.
    func fetchFollowList() {
		guard let userID = user?.id else { return }
		KService.shared.getFollow(list: followList, for: userID, page: currentPage) { (userFollow) in
			DispatchQueue.main.async {
				self.currentPage = userFollow?.currentPage ?? 1
				self.lastPage = userFollow?.lastPage ?? 1

				if self.currentPage == 1 {
					self.userFollow = userFollow?.following?.isEmpty ?? true ? userFollow?.followers : userFollow?.following
				} else {
					for userProfile in (userFollow?.following?.isEmpty ?? true ? userFollow?.followers : userFollow?.following) ?? [] {
						self.userFollow.append(userProfile)
					}
				}
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? FollowCell {
			if segue.identifier == "ProfileSegue" {
				if let profileTableViewController = segue.destination as? ProfileTableViewController {
					profileTableViewController.userID = currentCell.userProfile?.id
				}
			}
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
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 2 {
			if currentPage != lastPage {
				currentPage += 1
				fetchFollowList()
			}
		}
	}
}
