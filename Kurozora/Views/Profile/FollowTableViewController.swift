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
	var userFollow: [UserProfile]! {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var followList: FollowList = .followers
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

		self.title = followList.stringValue

		// Fetch follow list.
		DispatchQueue.global(qos: .background).async {
			self.fetchFollowList()
		}
    }

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			if let username = self.user?.username, let userID = User.current?.id {
				if self.followList == .followers {
					let detailLabelString = self.user?.id != userID ? "Be the first to follow \(username)!" : "Follow other users so they will follow you back. Who knows, you might meet your next BFF!"

					view.titleLabelString(NSAttributedString(string: "No \(self.followList.stringValue)", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
						.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
						.image(R.image.empty.follow())
						.imageTintColor(KThemePicker.textColor.colorValue)
						.verticalOffset(-50)
						.verticalSpace(5)
						.isScrollAllowed(true)

					if self.user?.id != userID, !(self.user?.following ?? true) {
						view.buttonTitle(NSAttributedString(string: "＋ Follow \(username)", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue]), for: .normal)
							.buttonTitle(NSAttributedString(string: "＋ Follow \(username)", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue.darken()]), for: .highlighted)
							.didTapDataButton {
								self.followUser()
						}
					}
				} else {
					let detailLabelString = self.user?.id != userID ? "\(username) is not following anyone yet." : "Follow a user and they will show up here!"

					view.titleLabelString(NSAttributedString(string: "No \(self.followList.stringValue)", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
						.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
						.image(R.image.empty.follow())
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

		KService.updateFollowStatus(userID, withFollowStatus: .follow) { result in
			switch result {
			case .success:
				self.fetchFollowList()
			case .failure: break
			}
		}
	}

	/// Fetch the follow list for the currently viewed profile.
    func fetchFollowList() {
		guard let userID = user?.id else { return }

		KService.getFollowList(userID, self.followList, page: currentPage) { result in
			switch result {
			case .success(let userFollow):
				DispatchQueue.main.async {
					self.currentPage = userFollow.currentPage ?? 1
					self.lastPage = userFollow.lastPage ?? 1

					if self.currentPage == 1 {
						self.userFollow = userFollow.following?.isEmpty ?? true ? userFollow.followers : userFollow.following
					} else {
						for userProfile in (userFollow.following?.isEmpty ?? true ? userFollow.followers : userFollow.following) ?? [] {
							self.userFollow.append(userProfile)
						}
					}
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
					profileTableViewController.userProfile = currentCell.userProfile
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
		guard let followCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.followCell, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(R.reuseIdentifier.followCell.identifier)")
		}
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
