//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SCLAlertView
import SwiftyJSON

class HomeCollectionViewController: UICollectionViewController {
	// Search bar controller
	var searchResultsViewController: SearchResultsTableViewController?
	var placeholderTimer: Timer?
	let placeholderArray = ["One Piece", "Shaman Asakaura", "a young girl with big ambitions", "Massively Multiplayer Online Role-Playing Game", "Vampires"]

	var exploreCategories: [ExploreCategory]? {
		didSet {
			collectionView.reloadData()
		}
	}
    var showID:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		let storyboard: UIStoryboard = UIStoryboard(name: "search", bundle: nil)
		searchResultsViewController = storyboard.instantiateViewController(withIdentifier: "Search") as? SearchResultsTableViewController

        if #available(iOS 11.0, *) {
			let searchController = SearchController(searchResultsController: searchResultsViewController)
			searchController.delegate = self
			searchController.searchResultsUpdater = searchResultsViewController

			let searchControllerBar = searchController.searchBar
			startPlaceholderTimer(for: searchControllerBar)
			searchControllerBar.delegate = searchResultsViewController

			navigationItem.searchController = searchController
			searchController.homeCollectionViewController = self
        }

        // Validate session
        Service.shared.validateSession(withSuccess: { (success) in
            if !success {
                let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                self.present(vc, animated: true, completion: nil)
            }
            NotificationCenter.default.post(name: heartAttackNotification, object: nil)
        })

        Service.shared.getExplore(withSuccess: { (explore) in
			DispatchQueue.main.async {
				self.exploreCategories = explore?.categories
			}
        })
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
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
			placeholderTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateSearchPlaceholder(_:)), userInfo: searchControllerBar, repeats: true)
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
			if let currentCell = sender as? ExploreCollectionViewCell, let showTabBarController = segue.destination as? ShowDetailTabBarController {
				showTabBarController.exploreCollectionViewCell = currentCell
				showTabBarController.showID = currentCell.showElement?.id
				if let showTitle = currentCell.showElement?.title {
					showTabBarController.heroID = "explore_\(showTitle)"
				}
			}
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		guard let categoriesCount = exploreCategories?.count else { return 0 }
		return categoriesCount + 2
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section < (exploreCategories?.count)! {
			let categorySection = exploreCategories?[section]
			if let categoryShows = categorySection?.shows?.count, categoryShows != 0 {
				return 1
			} else if let categoryGenres = categorySection?.genres?.count, categoryGenres != 0 {
				return 1
			} else {
				return 0
			}
		}

		return 1
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.section < (exploreCategories?.count)! {
			if let categoryType = exploreCategories?[indexPath.section].size {
				var exploreCellStyle = ExploreCellStyle(rawValue: categoryType)
				var horizontalCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalExploreCollectionViewCell", for: indexPath) as! HorizontalExploreCollectionViewCell

				if indexPath.section == 0 {
					horizontalCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalBannerExploreCollectionViewCell", for: indexPath) as! HorizontalExploreCollectionViewCell
					horizontalCell.collectionView.collectionViewLayout = BannerCollectionViewFlowLayout()
					exploreCellStyle = .large
				} else if exploreCellStyle == .large {
					horizontalCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalBannerExploreCollectionViewCell", for: indexPath) as! HorizontalExploreCollectionViewCell
				}

				horizontalCell.section = indexPath.section
				horizontalCell.homeCollectionViewController = self
				horizontalCell.cellStyle = exploreCellStyle

				if exploreCategories?[indexPath.section].shows?.count != 0 {
					horizontalCell.shows = exploreCategories?[indexPath.section].shows
				} else {
					horizontalCell.genres = exploreCategories?[indexPath.section].genres
				}

				return horizontalCell
			}
		}

		if indexPath.section == (exploreCategories?.count)! {
			let actionExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionExploreCollectionViewCell", for: indexPath) as! ActionExploreCollectionViewCell

			return actionExploreCollectionViewCell
		}

		let legalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LegalExploreCollectionViewCell", for: indexPath) as! LegalExploreCollectionViewCell

		return legalExploreCollectionViewCell
	}
}

// MARK: - UICollectionViewDelegate
extension HomeCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.section == collectionView.lastSection, ((collectionView.cellForItem(at: indexPath) as? LegalExploreCollectionViewCell) != nil) {
			performSegue(withIdentifier: "LegalSegue", sender: nil)
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		if section < (exploreCategories?.count)! {
			return (section != 0) ? CGSize(width: collectionView.width, height: 48) : .zero
		} else if section == (exploreCategories?.count)! {
			return CGSize(width: collectionView.width, height: 48)
		}

		return .zero
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if indexPath.section < (exploreCategories?.count)! {
			if let categoryType = exploreCategories?[indexPath.section].size, let exploreCellStyle = ExploreCellStyle(rawValue: categoryType) {

				if indexPath.section == 0 {
					if UIDevice.isLandscape() {
						return CGSize(width: view.frame.width, height: view.frame.height * 0.6)
					}
					return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
				}

				switch exploreCellStyle {
				case .large:
					if UIDevice.isLandscape() {
						return CGSize(width: view.frame.width, height: view.frame.height * 0.6)
					}
					return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
				case .medium:
					if UIDevice.isLandscape() {
						return CGSize(width: view.frame.width, height: view.frame.height * 0.4)
					}
					return CGSize(width: view.frame.width, height: view.frame.height * 0.2)
				case .small:
					if UIDevice.isLandscape() {
						return CGSize(width: view.frame.width, height: view.frame.height * 0.6)
					}
					return CGSize(width: view.frame.width, height: view.frame.height * 0.2)
				}
			}
		}

		if indexPath.section == (exploreCategories?.count)! {
			return CGSize(width: view.frame.width, height: 172)
		}

		return CGSize(width: view.frame.width, height: 44)
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExploreSectionHeader", for: indexPath) as? ExploreSectionHeaderCell else {
			return UICollectionReusableView()
		}

		if indexPath.section == (exploreCategories?.count)! {
			sectionHeader.title = "Quick Links"
		} else {
			sectionHeader.category = exploreCategories?[indexPath.section]
			sectionHeader.homeCollectionViewController = self
		}

		return sectionHeader
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		if section == 0 || section == collectionView.lastSection {
			return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
		}
		
		return UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
	}
}

// MARK: - UISearchControllerDelegate
extension HomeCollectionViewController: UISearchControllerDelegate {
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
