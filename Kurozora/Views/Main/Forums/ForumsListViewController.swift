//
//  ForumsListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ForumsListViewControllerDelegate: class {
	func updateForumOrderButton(with orderType: ForumOrder)
}

class ForumsListViewController: KTableViewController {
	// MARK: - Properties
	var refreshController = UIRefreshControl()

	var sectionTitle: String = ""
	var sectionID: Int!
	var sectionIndex: Int!
	var forumsThreads: [ForumsThread] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var nextPageURL: String?
	var forumOrder: ForumOrder = .best
	weak var delegate: ForumsListViewControllerDelegate?

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
		// Save current page index
		UserSettings.set(sectionIndex, forKey: .forumsPage)

		// Setup library view controller delegate
		(tabmanParent as? ForumsViewController)?.forumsViewControllerDelegate = self

		// Update forum order button to reflect page settings
		delegate?.updateForumOrderButton(with: forumOrder)
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
		tableView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }

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
		KService.getForumsThreads(forSection: sectionID, orderedBy: forumOrder, next: nextPageURL) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let forumsThreadResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.forumsThreads = []
				}

				// Append new data and save next page url
				self.forumsThreads.append(contentsOf: forumsThreadResponse.data)
				self.nextPageURL = forumsThreadResponse.next

				// Reset refresh controller title
				self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
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
			threadViewController?.forumsThread = sender as? ForumsThread
		}
	}
}

// MARK: - UITableViewDataSource
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.forumsThreads.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let forumsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.forumsCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.forumsCell.identifier)")
		}
		forumsCell.forumsThread = self.forumsThreads[indexPath.row]
		forumsCell.forumsChildViewController = self
		return forumsCell
	}
}

// MARK: - UITableViewDelegate
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: R.segue.forumsListViewController.threadSegue, sender: self.forumsThreads[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 5 {
			if self.nextPageURL != nil {
				self.fetchThreads()
			}
		}
	}
}

// MARK: - LibraryViewControllerDelegate
extension ForumsListViewController: ForumsViewControllerDelegate {
	func orderForums(by forumOrder: ForumOrder) {
		self.forumOrder = forumOrder
		self.fetchThreads()
	}

	func orderValue() -> ForumOrder {
		return self.forumOrder
	}
}

// MARK: - KRichTextEditorViewDelegate
extension ForumsListViewController: KRichTextEditorViewDelegate {
	func updateThreadsList(with forumsThreads: [ForumsThread]) {
		DispatchQueue.main.async {
			for forumsThread in forumsThreads {
				self.forumsThreads.prepend(forumsThread)
			}
		}
	}
}
