//
//  FeedTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FeedTableViewController: KTableViewController {
	// MARK: - Properties
	var refreshController = UIRefreshControl()

	var sectionTitle: String = ""
	var sectionID: Int?
	var sectionIndex: Int?
	var feedPosts: [FeedPost] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Turn off activity indicator for now
		_prefersActivityIndicatorHidden = true

		// Add Refresh Control to Table View
		tableView.refreshControl = refreshController
		refreshController.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh your \(sectionTitle) feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshController.addTarget(self, action: #selector(refreshFeedsData(_:)), for: .valueChanged)

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
		refreshController.attributedTitle = NSAttributedString(string: "Refreshing your \(sectionTitle) feed...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		self.nextPageURL = nil
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

		KService.getFeedPosts(forSection: sectionID, next: nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let feedPostResponse):
				DispatchQueue.main.async {
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.feedPosts = []
					}

					// Append new data and save next page url
					self.feedPosts.append(contentsOf: feedPostResponse.data)
					self.nextPageURL = feedPostResponse.next

					// Reset refresh controller title
					self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh your \(self.sectionTitle) feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
				}
			case .failure: break
			}
		}

		DispatchQueue.main.async {
			self.refreshController.endRefreshing()
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
}

// MARK: - UITableViewDataSource
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return feedPosts.count
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

		if indexPath.row == numberOfRows - 5 {
			if self.nextPageURL != nil {
				self.fetchFeedPosts()
			}
		}
	}
}

// MARK: - KRichTextEditorViewDelegate
//extension FeedTableViewController: KRichTextEditorViewDelegate {
//	func updateFeedPosts(with feedPosts: [FeedPost]) {
//		DispatchQueue.main.async {
//			for feedPost in feedPosts {
//				self.feedPosts.prepend(feedPost)
//			}
//		}
//	}
//}
