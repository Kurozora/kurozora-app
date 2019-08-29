//
//  ShowDetailTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class ShowDetailTabBarController: ESTabBarController {
    var showID: Int?
	var heroID: String?
	var exploreCollectionViewCell: ExploreCollectionViewCell? = nil
	var libraryCollectionViewCell: LibraryCollectionViewCell? = nil
	var showDetailViewControllerDelegate: ShowDetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

		self.tabBar.isTranslucent = true
		self.tabBar.itemPositioning = .centered
		self.tabBar.backgroundColor = .clear
		self.tabBar.barStyle = .default
		self.tabBar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.tabBar.theme_barTintColor = KThemePicker.barTintColor.rawValue

        // Instantiate views
		let showDetail = ShowDetailViewController.instantiateFromStoryboard() as! ShowDetailViewController
		showDetail.exploreCollectionViewCell = exploreCollectionViewCell
		showDetail.libraryCollectionViewCell = libraryCollectionViewCell
		showDetail.modalPresentationCapturesStatusBarAppearance = true
        showDetail.showID = showID
		showDetail.heroID = heroID
		showDetail.delegate = showDetailViewControllerDelegate
        
        let seasons = SeasonsCollectionViewController.instantiateFromStoryboard() as! SeasonsCollectionViewController
		seasons.modalPresentationCapturesStatusBarAppearance = true
		if let heroID = heroID {
			if (libraryCollectionViewCell as? LibraryDetailedColelctionViewCell)?.episodeImageView != nil || exploreCollectionViewCell?.bannerImageView != nil {
				seasons.heroID = "\(heroID)_banner"
			} else {
				seasons.heroID = "\(heroID)_poster"
			}
		}
        
        // Setup animation, title and image
        showDetail.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Details", image: UIImage(named: "details_icon"), selectedImage: UIImage(named: "details_icon"))
        seasons.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Seasons", image: UIImage(named: "list"), selectedImage: UIImage(named: "list"))

        // Setup navigation and title
        let n1 = KNavigationController.init(rootViewController: seasons)
        
        seasons.title = "Seasons"
        
        // Initialize views
        viewControllers = [showDetail, n1]
    }

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "details", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "ShowDetailTabBarController")
	}
}
