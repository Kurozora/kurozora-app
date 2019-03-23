//
//  ShowTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class ShowTabBarController: ESTabBarController {
    var showID: Int?
	var showTitle: String?
	var heroID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

		self.tabBar.isTranslucent = true
		self.tabBar.itemPositioning = .centered
		self.tabBar.backgroundColor = .clear
		self.tabBar.barStyle = .default
		self.tabBar.theme_tintColor = "Global.tintColor"
		self.tabBar.theme_barTintColor = "Global.barTintColor"

        let storyboard = UIStoryboard(name: "details", bundle: nil)

        // Instantiate views
        let showDetail = storyboard.instantiateViewController(withIdentifier: "ShowDetail") as! ShowDetailViewController
        showDetail.showID = showID
		showDetail.showTitle = showTitle
		showDetail.heroID = heroID
        
        let seasons = storyboard.instantiateViewController(withIdentifier: "Season") as! SeasonsCollectionViewController
        
        // Setup animation, title and image
        showDetail.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Details", image: UIImage(named: "details_icon"), selectedImage: UIImage(named: "details_icon"))
        seasons.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Seasons", image: UIImage(named: "list"), selectedImage: UIImage(named: "list"))

        // Setup navigation and title
        let n1 = KurozoraNavigationController.init(rootViewController: seasons)
        
        seasons.title = "Seasons"
        
        // Initialize views
        viewControllers = [showDetail, n1]
    }
}
