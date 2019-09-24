//
//  FeedTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import SwiftTheme

class FeedTableViewController: UITableViewController {
	// MARK: - Properties
	var sectionTitle: String = ""
	var sectionID: Int?
	var sectionIndex: Int?
	var feedPostElement: [FeedPostElement]? {
		didSet {
			tableView.reloadData()
		}
	}

	// Pagination
	var totalPages = 0
	var pageNumber = 0

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		refreshControl?.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(sectionTitle) feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshControl?.addTarget(self, action: #selector(refreshFeedsData(_:)), for: .valueChanged)

		fetchFeedPosts()

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Feed", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get feed list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_comment"))
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	// MARK: - Functions
	/**
		Refresh the feeds data by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshFeedsData(_ sender: Any) {
		refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing your \(sectionTitle) feed...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		pageNumber = 0
		fetchFeedPosts()
	}

	// Fetch feed posts for the current section
	func fetchFeedPosts() {
		guard let sectionID = sectionID else { return }

		Service.shared.getFeedPosts(for: sectionID, page: pageNumber, withSuccess: { (feed) in
			DispatchQueue.main.async {
				if let feedPages = feed?.feedPages {
					self.totalPages = feedPages
				}

				if self.pageNumber == 0 {
					self.feedPostElement = feed?.posts
					self.pageNumber += 1
				} else if self.pageNumber <= self.totalPages - 1 {
					for feedPostsElement in (feed?.posts)! {
						self.feedPostElement?.append(feedPostsElement)
					}
					self.pageNumber += 1
				}

				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(self.sectionTitle) feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
			}
		})

		self.refreshControl?.endRefreshing()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "FeedSegue" {
			let threadViewController = segue.destination as? ThreadTableViewController
			threadViewController?.hidesBottomBarWhenPushed = true
			threadViewController?.forumsThreadElement = sender as? ForumsThreadElement
		}
	}
}

// MARK: - UITableViewDataSource
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let threadsCount = feedPostElement?.count else { return 0 }
		return threadsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let feedPostCell = tableView.dequeueReusableCell(withIdentifier: "FeedPostCell") as! FeedPostCell
		return feedPostCell
	}
}

// MARK: - UITableViewDelegate
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "ThreadSegue", sender: feedPostElement?[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 1 {
			if pageNumber <= totalPages - 1 {
				fetchFeedPosts()
			}
		}
	}
}

// MARK: - KRichTextEditorViewDelegate
//extension FeedTableViewController: KRichTextEditorViewDelegate {
//	func updateThreadsList(with thread: ForumsThreadElement) {
//	}
//
//	func updateFeedPosts(with posts: FeedPostsElement) {
//		DispatchQueue.main.async {
//			if self.feedPosts == nil {
//				self.feedPosts = [posts]
//			} else {
//				self.feedPosts?.prepend(posts)
//			}
//		}
//	}
//}
