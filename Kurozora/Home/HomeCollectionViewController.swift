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
	let placeholderArray: [String] = ["One Piece", "Shaman Asakaura", "a young girl with big ambitions", "massively multiplayer online role-playing game", "vampires"]
	let actionUrlList: [[String: String]] = [["title": "About In-App Purchases", "url": "https://kurozora.app/"], ["title": "About Personalization", "url": "https://kurozora.app/api/v1"], ["title": "Welcome to Kurozora", "url": "https://kurozora.app/"]]
	let actionButtonList = [["title": "Redeem", "segueId": "IAPSegue"], ["title": "Become a Pro User", "segueId": "IAPSegue"]]

	var exploreCategories: [ExploreCategory]? {
		didSet {
			collectionView.reloadData()
		}
	}
    var showID: Int?

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
			searchController.viewController = self
        }

        // Validate session
        Service.shared.validateSession(withSuccess: { (success) in
            if !success {
                let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
				if let vc = storyboard.instantiateInitialViewController() {
                	self.present(vc, animated: true, completion: nil)
				}
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
				if let showTitle = currentCell.showElement?.title, let section = currentCell.indexPath?.section {
					showTabBarController.heroID = "explore_\(showTitle)_\(section)"
				}
			}
		}
    }
}

// MARK: - UICollectionViewDataSource
extension HomeCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		guard let categoriesCount = exploreCategories?.count else { return 0 }
		return categoriesCount + 3
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let exploreCategoriesCount = exploreCategories?.count {
			if section < exploreCategoriesCount {
				let categorySection = exploreCategories?[section]
				if categorySection?.shows?.count != 0 {
					return 1
				} else if categorySection?.genres?.count != 0 {
					return 1
				}
				return 0
			}

			if section == exploreCategoriesCount {
				if actionUrlList.count != 0 {
					return actionUrlList.count
				}
			}

			if section == exploreCategoriesCount + 1 {
				if actionButtonList.count != 0 {
					return actionButtonList.count
				}
			}
		}

		return 1
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let exploreCategoriesCount = exploreCategories?.count {
			if indexPath.section < exploreCategoriesCount {
				if let categoryType = exploreCategories?[indexPath.section].size, var exploreCellStyle = ExploreCellStyle(rawValue: categoryType) {
					var horizontalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalExploreCollectionViewCell", for: indexPath) as! HorizontalExploreCollectionViewCell

					if indexPath.section == 0 {
						horizontalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreBannerCollectionViewCell", for: indexPath) as! HorizontalExploreCollectionViewCell
						horizontalExploreCollectionViewCell.collectionView.collectionViewLayout = BannerCollectionViewFlowLayout()
						exploreCellStyle = .large
					}

					horizontalExploreCollectionViewCell.section = indexPath.section
					horizontalExploreCollectionViewCell.homeCollectionViewController = self
					horizontalExploreCollectionViewCell.cellStyle = exploreCellStyle

					if indexPath.section != 0 {
						switch exploreCellStyle {
						case .large:
							horizontalExploreCollectionViewCell.collectionView.collectionViewLayout = ExploreLargeCollectionViewFlowLayout()
						case .medium:
							horizontalExploreCollectionViewCell.collectionView.collectionViewLayout = ExploreMediumCollectionViewFlowLayout()
						case .small:
							horizontalExploreCollectionViewCell.collectionView.collectionViewLayout = ExploreSmallCollectionViewFlowLayout()
						case .video:
							horizontalExploreCollectionViewCell.collectionView.collectionViewLayout = ExploreVideoCollectionViewFlowLayout()
						}
					}

					if exploreCategories?[indexPath.section].shows?.count != 0 {
						horizontalExploreCollectionViewCell.shows = exploreCategories?[indexPath.section].shows
					} else {
						horizontalExploreCollectionViewCell.genres = exploreCategories?[indexPath.section].genres
					}

					return horizontalExploreCollectionViewCell
				}
			}

			if indexPath.section == exploreCategoriesCount {
				let actionListExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionListExploreCollectionViewCell", for: indexPath) as! ActionListExploreCollectionViewCell
				actionListExploreCollectionViewCell.actionUrlItem = actionUrlList[indexPath.item]
				actionListExploreCollectionViewCell.homeCollectionViewController = self
				return actionListExploreCollectionViewCell
			}

			if indexPath.section == exploreCategoriesCount + 1 {
				let actionButtonExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionButtonExploreCollectionViewCell", for: indexPath) as! ActionButtonExploreCollectionViewCell
				actionButtonExploreCollectionViewCell.actionButtonItem = actionButtonList[indexPath.item]
				actionButtonExploreCollectionViewCell.homeCollectionViewController = self
				return actionButtonExploreCollectionViewCell
			}
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

		if let exploreCategoriesCount = exploreCategories?.count {
			if section < exploreCategoriesCount {
				if section != 0 {
					return (exploreCategories?[section].shows?.count != 0 || exploreCategories?[section].genres?.count != 0) ? CGSize(width: collectionView.width, height: 48) : .zero
				}
			} else if section == exploreCategoriesCount {
				return CGSize(width: collectionView.width, height: 48)
			}
		}

		return .zero
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if let exploreCategoriesCount = exploreCategories?.count {
			if indexPath.section < exploreCategoriesCount {
				if let categoryType = exploreCategories?[indexPath.section].size, let exploreCellStyle = ExploreCellStyle(rawValue: categoryType) {

					if indexPath.section == 0 {
						if UIDevice.isPad() {
							if UIDevice.isLandscape() {
								return CGSize(width: view.frame.width, height: view.frame.height * 0.4)
							}
							return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
						}

						if UIDevice.isLandscape() {
							return CGSize(width: view.frame.width, height: view.frame.height * 0.6)
						}
						return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
					}

					switch exploreCellStyle {
					case .large:
						if UIDevice.isPad() {
							if UIDevice.isLandscape() {
								return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
							}
							return CGSize(width: view.frame.width, height: view.frame.height * 0.2)
						}

						if UIDevice.isLandscape() {
							return CGSize(width: view.frame.width, height: view.frame.height * 0.6)
						}
						return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
					case .medium:
						if UIDevice.isPad() {
							if UIDevice.isLandscape() {
								return CGSize(width: view.frame.width, height: view.frame.height * 0.2)
							}
							return CGSize(width: view.frame.width, height: view.frame.height * 0.15)
						}

						if UIDevice.isLandscape() {
							return CGSize(width: view.frame.width, height: view.frame.height * 0.4)
						}
						return CGSize(width: view.frame.width, height: view.frame.height * 0.2)
					case .small:
						if UIDevice.isPad() {
							if UIDevice.isLandscape() {
								return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
							}
							return CGSize(width: view.frame.width, height: view.frame.height * 0.2)
						}

						if UIDevice.isLandscape() {
							return CGSize(width: view.frame.width, height: view.frame.height * 0.6)
						}

						if UIDevice.hasTopNotch {
							return CGSize(width: view.frame.width, height: view.frame.height * 0.2)
						}

						return CGSize(width: view.frame.width, height: view.frame.height * 0.24)
					case .video:
						if UIDevice.isPad() {
							if UIDevice.isLandscape() {
								return CGSize(width: view.frame.width, height: view.frame.height * 0.39)
							}
							return CGSize(width: view.frame.width, height: view.frame.width * 0.38)
						}

						if UIDevice.isLandscape() {
							return CGSize(width: view.frame.width, height: view.frame.height * 0.8)
						}
						return CGSize(width: view.frame.width, height: view.frame.height * 0.43)
					}
				}
			}

			if indexPath.section == exploreCategoriesCount || indexPath.section == exploreCategoriesCount + 1 {
				if UIDevice.isPad() {
					if UIDevice.isLandscape() {
						return CGSize(width: view.frame.width / 3, height: 44.5)
					}
					return CGSize(width: view.frame.width / 2, height: 44.5)
				}

				if UIDevice.isLandscape() {
					return CGSize(width: view.frame.width / 2, height: 44.5)
				}
				return CGSize(width: view.frame.width, height: 44.5)
			}
		}

		return CGSize(width: view.frame.width, height: 44)
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExploreSectionHeader", for: indexPath) as? ExploreSectionHeaderCell else {
			return UICollectionReusableView()
		}

		if let exploreCategoriesCount = exploreCategories?.count, indexPath.section == exploreCategoriesCount {
			sectionHeader.title = "Quick Links"
		} else {
			sectionHeader.category = exploreCategories?[indexPath.section]
			sectionHeader.homeCollectionViewController = self
		}

		return sectionHeader
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		if let exploreCategoriesCount = exploreCategories?.count {
			if section < exploreCategoriesCount {
				if section != 0 {
					if section != 0 {
						return (exploreCategories?[section].shows?.count != 0 || exploreCategories?[section].genres?.count != 0) ? UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0) : .zero
					}
				}
			}

			if section == 0 || section >= exploreCategoriesCount {
				return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
			}
		}
		return .zero
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
