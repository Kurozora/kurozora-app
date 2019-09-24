//
//  ForumsListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import SCLAlertView
import SwiftTheme
import SwiftyJSON

class ForumsListViewController: UITableViewController {
	// MARK: - Properties
	var refresh = UIRefreshControl()

	var sectionTitle: String = ""
	var sectionID: Int?
	var sectionIndex: Int?
	var forumThreads: [ForumsThreadElement]? {
		didSet {
			tableView.reloadData()
		}
	}
	var threadOrder: String?

	// Pagination
	var currentPage = 1
	var lastPage = 1

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UserSettings.set(sectionIndex, forKey: .forumsPage)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Add Refresh Control to Table View
		tableView.refreshControl = refresh
		refresh.theme_tintColor = KThemePicker.tintColor.rawValue
		refresh.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refresh.addTarget(self, action: #selector(refreshThreadsData(_:)), for: .valueChanged)

		// Fetch threads
		fetchThreads()

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Threads", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Be the first to post in the \(self.sectionTitle.lowercased()) forums!", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_comment"))
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	// MARK: - Functions
	/**
		Refresh the threads data by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshThreadsData(_ sender: Any) {
		refresh.attributedTitle = NSAttributedString(string: "Refreshing \(sectionTitle) threads...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		currentPage = 0
		fetchThreads()
	}

	/// Fetch threads list for the current section.
	func fetchThreads() {
		guard let sectionID = sectionID else { return }

		if threadOrder == nil {
			threadOrder = "top"
		}

		Service.shared.getForumsThreads(for: sectionID, order: threadOrder, page: currentPage, withSuccess: { (threads) in
			DispatchQueue.main.async {
				self.currentPage = threads?.currentPage ?? 1
				self.lastPage = threads?.lastPage ?? 1

				if self.currentPage == 1 {
					self.forumThreads = threads?.threads
				} else {
					for forumThreadElement in threads?.threads ?? [] {
						self.forumThreads?.append(forumThreadElement)
					}
				}

				self.refresh.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
			}
		})

		self.refresh.endRefreshing()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ThreadSegue" {
			let threadViewController = segue.destination as? ThreadTableViewController
			threadViewController?.hidesBottomBarWhenPushed = true
			threadViewController?.forumsThreadElement = sender as? ForumsThreadElement
		}
	}
}

// MARK: - UITableViewDataSource
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let threadsCount = forumThreads?.count else { return 0 }
		return threadsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let forumsCell = tableView.dequeueReusableCell(withIdentifier: "ForumsCell") as! ForumsCell
		forumsCell.forumThreadsElement = forumThreads?[indexPath.row]
		forumsCell.forumsChildViewController = self
		return forumsCell
	}
}

// MARK: - UITableViewDelegate
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "ThreadSegue", sender: forumThreads?[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 2 {
			if currentPage != lastPage {
				currentPage += 1
				fetchThreads()
			}
		}
	}
}

// MARK: - KRichTextEditorViewDelegate
//extension ForumsListViewController: KRichTextEditorViewDelegate {
//	func updateFeedPosts(with thread: FeedPostsElement) {
//	}
//
//	func updateThreadsList(with thread: ForumsThreadElement) {
//		DispatchQueue.main.async {
//			if self.forumThreads == nil {
//				self.forumThreads = [thread]
//			} else {
//				self.forumThreads?.prepend(thread)
//			}
//		}
//	}
//}
