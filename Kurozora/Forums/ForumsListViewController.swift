//
//  ForumsListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import SwiftTheme

class ForumsListViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	var refresh = UIRefreshControl()

    var sectionTitle: String?
	var sectionID: Int?
	var sectionIndex: Int?
	var forumThreads: [ForumThreadsElement]? {
		didSet {
			tableView.reloadData()
		}
	}
	var threadOrder: String?

	// Pagination
	var totalPages = 0
	var pageNumber = 0

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UserSettings.set(sectionIndex, forKey: .forumsPage)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		
		guard let sectionTitle = sectionTitle else { return }

		// Add Refresh Control to Table View
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refresh
		} else {
			tableView.addSubview(refresh)
		}

		refresh.theme_tintColor = KThemePicker.tintColor.rawValue
		refresh.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads!", attributes: [NSAttributedString.Key.foregroundColor : KThemePicker.tintColor.colorValue])
		refresh.addTarget(self, action: #selector(refreshThreadsData(_:)), for: .valueChanged)

		fetchThreads()
        
        // Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
        
        // Setup empty table view
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: sectionTitle))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
        }
    }

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if #available(iOS 11.0, *) {
			let offset = scrollView.contentOffset
			if let tabmanVC = tabmanParent as? ForumsViewController {
				tabmanVC.scrollView.contentOffset = offset
				tabmanVC.scrollView.panGestureRecognizer.state = scrollView.panGestureRecognizer.state
			}
		}
	}

	// MARK: - Functions
	@objc private func refreshThreadsData(_ sender: Any) {
		guard let sectionTitle = sectionTitle else {return}
		refresh.attributedTitle = NSAttributedString(string: "Refreshing \(sectionTitle) threads...", attributes: [NSAttributedString.Key.foregroundColor : KThemePicker.tintColor.colorValue])
		pageNumber = 0
		fetchThreads()
	}

	// Fetch threads list for the current section
	func fetchThreads() {
		guard let sectionTitle = sectionTitle else { return }
		guard let sectionID = sectionID else { return }
		if let _ = threadOrder { } else { threadOrder = "top" }

		Service.shared.getForumThreads(for: sectionID, order: threadOrder, page: pageNumber, withSuccess: { (threads) in
			DispatchQueue.main.async {
				if let threadPages = threads?.threadPages {
					self.totalPages = threadPages
				}

				if self.pageNumber == 0 {
					self.forumThreads = threads?.threads
					self.pageNumber += 1
				} else if self.pageNumber <= self.totalPages-1 {
					for forumThreadElement in (threads?.threads)! {
						self.forumThreads?.append(forumThreadElement)
					}
					self.pageNumber += 1
				}

				self.refresh.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads!", attributes: [NSAttributedString.Key.foregroundColor : KThemePicker.tintColor.colorValue])
			}
		})

		self.refresh.endRefreshing()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ThreadSegue" {
			let threadViewController = segue.destination as? ThreadViewController
			threadViewController?.hidesBottomBarWhenPushed = true
			threadViewController?.forumThreadID = sender as? Int
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
		if let forumThreadID = forumThreads?[indexPath.row].id {
			performSegue(withIdentifier: "ThreadSegue", sender: forumThreadID)
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 1 {
			if pageNumber <= totalPages - 1 {
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
//	func updateThreadsList(with thread: ForumThreadsElement) {
//		DispatchQueue.main.async {
//			if self.forumThreads == nil {
//				self.forumThreads = [thread]
//			} else {
//				self.forumThreads?.prepend(thread)
//			}
//		}
//	}
//}
