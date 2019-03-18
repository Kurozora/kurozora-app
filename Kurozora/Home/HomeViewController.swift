//
//  HomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SCLAlertView
import SwiftyJSON
import EmptyDataSet_Swift

class HomeViewController: UITableViewController, EmptyDataSetDelegate, EmptyDataSetSource {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var tableHeaderView: UIView!
	@IBOutlet weak var separatorView: UIView!

	// Search bar controller
	var searchResultsViewController: SearchResultsViewController?
	let placeholderArray = ["One Piece", "Shaman Asakaura", "a young girl with big ambitions", "Massively Multiplayer Online Role-Playing Game", "Vampires"]
	var placeholderTimer: Timer?

	// Header collection variables
	var headerTimer: Timer?
	var onceOnly = false
	var itemSize = CGSize(width: 0, height: 0)

    var categories: [ExploreCategory]?
    var banners: [ExploreBanner]?
    var showID:Int?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		separatorView.theme_backgroundColor = "Global.separatorColor"
		
		let storyboard: UIStoryboard = UIStoryboard(name: "search", bundle: nil)
		searchResultsViewController = storyboard.instantiateViewController(withIdentifier: "Search") as? SearchResultsViewController

        if #available(iOS 11.0, *) {
			let searchController = SearchController(searchResultsController: searchResultsViewController)
			searchController.delegate = self
			searchController.searchResultsUpdater = searchResultsViewController

			let searchControllerBar = searchController.searchBar
			startPlaceholderTimer(for: searchControllerBar)
			searchControllerBar.delegate = searchResultsViewController

			navigationItem.searchController = searchController
        }
        
        // Validate session
        Service.shared.validateSession(withSuccess: { (success) in
            if !success {
                let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                self.present(vc, animated: true, completion: nil)
            }
            NotificationCenter.default.post(name: heartAttackNotification, object: nil)
        })

        Service.shared.getExplore(withSuccess: { (explore) in
			DispatchQueue.main.async {
				self.categories = explore?.categories
				self.banners = explore?.banners

				self.tableView.reloadData()
				self.collectionView.reloadData()
			}
        })

        // Setup collection view
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
		startHeaderCollectionTimer()

		let width = collectionView.bounds.size.width - 20
		let height = width * (9/16)
		itemSize = CGSize(width: width, height: height - 20)

		// Register cells
		let exploreSectionHeaderCellNib = UINib(nibName: "ExploreSectionHeaderCell", bundle: nil)
		tableView.register(exploreSectionHeaderCellNib, forHeaderFooterViewReuseIdentifier: "ExploreSectionHeader")

        // Setup table view
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setup empty table view
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }

    // MARK: - Functions
	@objc func updateSearchPlaceholder(_ timer: Timer) {
		if let searchControllerBar = timer.userInfo as? UISearchBar {
			UIView.animate(withDuration: 1, delay: 0, options: .transitionCrossDissolve, animations: {
				searchControllerBar.placeholder = self.placeholderArray.randomElement()
			}, completion: nil)
		}
	}

	func startPlaceholderTimer(for searchControllerBar: UISearchBar) {
		if placeholderTimer == nil {
			placeholderTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateSearchPlaceholder), userInfo: searchControllerBar, repeats: true)
		}
	}

	func stopPlacholderTimer() {
		if placeholderTimer != nil {
			placeholderTimer?.invalidate()
			placeholderTimer = nil
		}
	}

	// MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailsSegue" {
            // Show detail for explore cell
			if let currentCell = sender as? ExploreCell, let showTabBarController = segue.destination as? ShowTabBarController {
				showTabBarController.showID = currentCell.showElement?.id
				showTabBarController.showTitle = currentCell.showElement?.title
				showTabBarController.heroID = "explore"
			}
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let categoriesCount = categories?.count else { return 0 }
		return categoriesCount + 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section < (categories?.count)! {
			if let categorySection = categories?[section] {
				return (categorySection.shows?.count != 0) ? 1 : 0
			}
		}

		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section < (categories?.count)! {
			if let categoryType = categories?[indexPath.section].type, categoryType == "large" {
				let largeCell = tableView.dequeueReusableCell(withIdentifier: "LargeCategoryCell") as! LargeCategoryCell

				if let shows = categories?[indexPath.section].shows {
					largeCell.shows = shows
				}

				return largeCell
			} else if let categoryType = categories?[indexPath.section].type, categoryType == "normal"  {
				let showCell = tableView.dequeueReusableCell(withIdentifier: "ShowCategoryCell") as! ShowCategoryCell

				if let shows = categories?[indexPath.section].shows {
					showCell.shows = shows
				}

				return showCell
			}
		}

		let footnoteCell: FootnoteCell = tableView.dequeueReusableCell(withIdentifier: "FootnoteCell") as! FootnoteCell

		return footnoteCell
	}
}

// MARK: - UITableViewDelegate
extension HomeViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section < (categories?.count)! {
			return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? 54 : 1
		}

		return 1
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section < (categories?.count)! {
			if let categoryShowCount = categories?[section].shows?.count, categoryShowCount != 0 {
				if let headerView: ExploreSectionHeaderCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ExploreSectionHeader") as? ExploreSectionHeaderCell {

					headerView.separatorView.theme_backgroundColor = "Global.separatorColor"
					headerView.titleLabel.theme_textColor = "Global.textColor"
					headerView.titleLabel.text = categories?[section].title

					return headerView
				}
			}
		}

		return ExploreSectionHeaderCell()
	}
}

// MARK: - UISearchControllerDelegate
extension HomeViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.frame = tabBarFrame
				self.stopPlacholderTimer()
			})
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.frame = tabBarFrame
				self.startPlaceholderTimer(for: searchController.searchBar)
			})
		}
	}
}
