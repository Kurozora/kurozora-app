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

	// Header collection variables
	var timer: Timer?
	var onceOnly = false
	let sectionInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
	var itemSize = CGSize(width: 0, height: 0)

    var categories: [JSON]?
    var banners: [JSON]?
    var showId:Int?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        if #available(iOS 11.0, *) {
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
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: nil) { _ in
//            self.tableView.beginUpdates()
//            if UIDevice.isLandscape() {
//                if UIDevice.isPad() {
//                    self.tableView.tableHeaderView?.frame = CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.height / 2.5))
//                }
//            } else {
//                if UIDevice.isPad() {
//                    self.tableView.tableHeaderView?.frame = CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 264))
//                } else {
//                    self.tableView.tableHeaderView?.frame = CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 144))
//                }
//            }
//            self.tableView.endUpdates()
//        }
//    }

    // MARK: - Functions
	func showDetailFor(_ showID: Int) {
        let storyboard = UIStoryboard(name: "details", bundle: nil)
        let showTabBarController = storyboard.instantiateViewController(withIdentifier: "ShowTabBarController") as? ShowTabBarController
        showTabBarController?.showID = showID

        self.present(showTabBarController!, animated: true, completion: nil)
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
