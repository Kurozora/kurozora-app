//
//  ForumsListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ForumsListViewController: KTableViewController {
	// MARK: - Properties
	var refreshController = UIRefreshControl()

	var sectionTitle: String = ""
	var sectionID: Int?
	var sectionIndex: Int?
	var forumThreadsElements: [ForumsThreadElement] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var nextPageURL: String?
	var forumOrder: ForumOrder = .top

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

		// Add bottom inset to avoid the tabbar obscuring the view
		tableView.contentInset.bottom = 50

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
		self.nextPageURL = nil
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

		KService.getForumsThreads(forSection: sectionID, orderedBy: forumOrder, next: nextPageURL) {[weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let threads):
				DispatchQueue.main.async {
					// Prepare `forumThreadsElements` if necessary
					if self.nextPageURL == nil {
						self.forumThreadsElements = []
					}

					// Append new threads data and save next page url
					if let forumThreadsElements = threads.threads {
						self.forumThreadsElements.append(contentsOf: forumThreadsElements)
					}
					self.nextPageURL = threads.nextPageURL

					// Reset refresh controller title
					self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
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
		if segue.identifier == R.segue.forumsListViewController.threadSegue.identifier {
			let threadViewController = segue.destination as? ThreadTableViewController
			threadViewController?.hidesBottomBarWhenPushed = true
			threadViewController?.sectionTitle = sectionTitle
			threadViewController?.forumsThreadElement = sender as? ForumsThreadElement
		}
	}
}

// MARK: - UITableViewDataSource
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.forumThreadsElements.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let forumsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.forumsCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.forumsCell.identifier)")
		}
		forumsCell.forumsThreadElement = self.forumThreadsElements[indexPath.row]
		forumsCell.forumsChildViewController = self
		return forumsCell
	}
}

// MARK: - UITableViewDelegate
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: R.segue.forumsListViewController.threadSegue, sender: self.forumThreadsElements[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 5 {
			if nextPageURL != "" {
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
			self.forumThreadsElements.prepend(thread)
		}
	}
}
