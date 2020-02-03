//
//  ForumsListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftTheme
import SwiftyJSON

class ForumsListViewController: KTableViewController {
	// MARK: - Properties
	var refreshController = UIRefreshControl()

	var sectionTitle: String = ""
	var sectionID: Int?
	var sectionIndex: Int?
	var forumThreadsElements: [ForumsThreadElement]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var threadOrder: String?

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

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UserSettings.set(sectionIndex, forKey: .forumsPage)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add Refresh Control to Table View
		tableView.refreshControl = refreshController
		refreshController.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshController.addTarget(self, action: #selector(refreshThreadsData(_:)), for: .valueChanged)

		// Fetch threads
		DispatchQueue.global(qos: .background).async {
			self.fetchThreads()
		}
	}

	// MARK: - Functions
	/**
		Refresh the threads data by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshThreadsData(_ sender: Any) {
		refreshController.attributedTitle = NSAttributedString(string: "Refreshing \(sectionTitle) threads...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		currentPage = 0
		fetchThreads()
	}

	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Threads", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Be the first to post in the \(self.sectionTitle.lowercased()) forums!", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.comment())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Fetch threads list for the current section.
	func fetchThreads() {
		guard let sectionID = sectionID else { return }

		if threadOrder == nil {
			threadOrder = "top"
		}

		KService.shared.getForumsThreads(for: sectionID, order: threadOrder, page: currentPage, withSuccess: { (threads) in
			DispatchQueue.main.async {
				self.currentPage = threads?.currentPage ?? 1
				self.lastPage = threads?.lastPage ?? 1

				if self.currentPage == 1 {
					self.forumThreadsElements = threads?.threads
				} else {
					for forumThreadElement in threads?.threads ?? [] {
						self.forumThreadsElements?.append(forumThreadElement)
					}
				}

				self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
			}
		})

		DispatchQueue.main.async {
			self.refreshController.endRefreshing()
		}
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
		guard let threadsCount = forumThreadsElements?.count else { return 0 }
		return threadsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let forumsCell = tableView.dequeueReusableCell(withIdentifier: "ForumsCell") as! ForumsCell
		forumsCell.forumThreadsElement = forumThreadsElements?[indexPath.row]
		forumsCell.forumsChildViewController = self
		return forumsCell
	}
}

// MARK: - UITableViewDelegate
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "ThreadSegue", sender: forumThreadsElements?[indexPath.row])
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
extension ForumsListViewController: KRichTextEditorViewDelegate {
//	func updateFeedPosts(with thread: FeedPostsElement) {
//	}

	func updateThreadsList(with thread: ForumsThreadElement) {
		DispatchQueue.main.async {
			if self.forumThreadsElements == nil {
				self.forumThreadsElements = [thread]
			} else {
				self.forumThreadsElements?.prepend(thread)
			}
		}
	}
}
