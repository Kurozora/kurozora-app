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
			tableView.reloadData()
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
		tableView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }

			if let username = self.user?.attributes.username, let userID = User.current?.id {
				if self.followList == .followers {
					let detailLabelString = self.user?.id != userID ? "Be the first to follow \(username)!" : "Follow other users so they will follow you back. Who knows, you might meet your next BFF!"

					view.titleLabelString(NSAttributedString(string: "No \(self.followList.stringValue)", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
						.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
						.image(R.image.empty.follow())
						.imageTintColor(KThemePicker.textColor.colorValue)
						.verticalOffset(-50)
						.verticalSpace(5)
						.isScrollAllowed(true)

					if self.user?.id != userID {
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

		KService.updateFollowStatus(forUserID: userID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let followUpdate):
				self.user?.attributes.update(using: followUpdate)
				self.fetchFollowList()
			case .failure: break
			}
		}
	}

	/// Fetch the follow list for the currently viewed profile.
    func fetchFollowList() {
		guard let userID = user?.id else { return }

		KService.getFollowList(forUserID: userID, self.followList, next: nextPageURL) {[weak self] result in
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userFollow.count
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let followCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.followCell, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(R.reuseIdentifier.followCell.identifier)")
		}
		followCell.user = userFollow[indexPath.row]
        return followCell
    }
}

// MARK: - UITableViewDelegate
extension FollowTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 5 {
			if self.nextPageURL != nil {
				self.fetchFollowList()
			}
		}
	}
}
