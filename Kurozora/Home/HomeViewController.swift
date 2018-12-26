//
//  HomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import KDatabaseKit
import SCLAlertView
import SwiftyJSON
import EmptyDataSet_Swift
import Kingfisher

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetDelegate, EmptyDataSetSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var tableHeaderView: UIView!

	// Search bar controller
	var searchResultsViewController: SearchResultsViewController?
	let placeholderArray = ["One Piece", "Shaman Asakaura", "a young girl with big ambitions", "Massively Multiplayer Online Role-Palying Game", "Vampires"]
	var placeholderTimer: Timer?

	// Header collection variables
	var headerTimer: Timer?
	var onceOnly = false
	var itemSize = CGSize(width: 0, height: 0)

    var categories: [JSON]?
    var banners: [JSON]?
    var showId:Int?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		let storyboard: UIStoryboard = UIStoryboard(name: "search", bundle: nil)
		searchResultsViewController = storyboard.instantiateViewController(withIdentifier: "Search") as? SearchResultsViewController

        if #available(iOS 11.0, *) {
			let searchController = SearchController(searchResultsController: searchResultsViewController)
			searchController.delegate = self
			searchController.searchResultsUpdater = searchResultsViewController

			let searchControllerBar = searchController.searchBar
			startPlaceholderTimer(for: searchControllerBar)
			searchControllerBar.delegate = searchResultsViewController

			if let textfield = searchControllerBar.value(forKey: "searchField") as? UITextField {
				textfield.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
			}

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

        Service.shared.getExplore(withSuccess: { (show) in
            if let categories = show.categories, categories != [] {
                self.categories = categories
            }
            if let banners = show.banners, banners != [] {
                self.banners = banners
            }

            self.tableView.reloadData()
            self.collectionView.reloadData()
        })

        // Setup collection view
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
		startHeaderCollectionTimer()

		let width = collectionView.bounds.size.width - 20
		let height = width * (9/16)
		itemSize = CGSize(width: width, height: height - 20)

        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setup empty table view
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Functions
	func showDetailFor(_ showID: Int) {
        let storyboard = UIStoryboard(name: "details", bundle: nil)
        let showTabBarController = storyboard.instantiateViewController(withIdentifier: "ShowTabBarController") as? ShowTabBarController
        showTabBarController?.showID = showID

        self.present(showTabBarController!, animated: true, completion: nil)
    }

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

    // MARK: - Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        if let categoriesCount = categories?.count, categoriesCount != 0 {
            return categoriesCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? 38 : 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIFont(name: "System", size: 22)
            headerView.textLabel?.textColor = .white
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let categoryTitle = categories?[section]["title"].stringValue else { return "" }

		if let categoryShowCount = categories?[section]["shows"].count, categoryShowCount != 0 {
            return categoryTitle
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (categories?[section]["shows"].count != 0) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let categoryType = categories?[indexPath.section]["type"].stringValue, categoryType == "large" {
            let largeCell = tableView.dequeueReusableCell(withIdentifier: "LargeCategoryCell") as! LargeCategoryCell
            
            if let shows = categories?[indexPath.section]["shows"].arrayValue, shows != [] {
                largeCell.shows = shows
            }
            
            return largeCell
        } else {
            let showCell = tableView.dequeueReusableCell(withIdentifier: "ShowCategoryCell") as! ShowCategoryCell
            if let shows = categories?[indexPath.section]["shows"].arrayValue, shows != [] {
                showCell.shows = shows
            }
            return showCell
        }
    }

	// MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailsSegue" {
            // Show detail for header cell
            if let sender = sender as? Int {
                let vc = segue.destination as! ShowTabBarController
                vc.showID = sender
            }
            
            // Show detail for show cell
            if let collectionCell: ShowCell = sender as? ShowCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let view: UIView = collectionView.superview {
                        if let tableViewCell: ShowCategoryCell = view.superview as? ShowCategoryCell {
                            if let destination = segue.destination as? ShowTabBarController {
                                if let indexPathRow = collectionView.indexPath(for: collectionCell)?.row {
                                    destination.showID = tableViewCell.shows?[indexPathRow]["id"].intValue
                                }
                            }
                        }
                    }
                }
            }
            
            // Show detail for large Cell
            if let collectionCell: LargeCell = sender as? LargeCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let view: UIView = collectionView.superview {
                        if let tableViewCell: LargeCategoryCell = view.superview as? LargeCategoryCell {
                            if let destination = segue.destination as? ShowTabBarController {
                                if let indexPathRow = collectionView.indexPath(for: collectionCell)?.row {
                                    destination.showID = tableViewCell.shows?[indexPathRow]["id"].intValue
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

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
