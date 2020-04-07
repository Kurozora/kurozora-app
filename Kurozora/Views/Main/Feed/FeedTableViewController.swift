//
//  FeedTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwiftTheme

class FeedTableViewController: KTableViewController {
	// MARK: - Properties
	var sectionTitle: String = ""
	var sectionID: Int?
	var sectionIndex: Int?
	var feedPostElements: [FeedPostElement]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}

	// Pagination
	var totalPages = 0
	var pageNumber = 0

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Turn off activity indicator for now
		_prefersActivityIndicatorHidden = true

		refreshControl?.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(sectionTitle) feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshControl?.addTarget(self, action: #selector(refreshFeedsData(_:)), for: .valueChanged)

		// Fetch feed posts.
		DispatchQueue.global(qos: .background).async {
			self.fetchFeedPosts()
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

	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Feed", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get feed list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.comment())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Fetch feed posts for the current section.
	func fetchFeedPosts() {
		guard let sectionID = sectionID else { return }

		KService.getFeedPosts(forSection: sectionID, page: pageNumber, withSuccess: { (feed) in
			DispatchQueue.main.async {
				if let feedPages = feed?.feedPages {
					self.totalPages = feedPages
				}

				if self.pageNumber == 0 {
					self.feedPostElements = feed?.posts
					self.pageNumber += 1
				} else if self.pageNumber <= self.totalPages - 1 {
					for feedPostsElement in (feed?.posts)! {
						self.feedPostElements?.append(feedPostsElement)
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
	}
}

// MARK: - UITableViewDataSource
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let threadsCount = feedPostElements?.count else { return 0 }
		return threadsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let feedPostCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedPostCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.feedPostCell.identifier)")
		}
		return feedPostCell
	}
}

// MARK: - UITableViewDelegate
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

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
