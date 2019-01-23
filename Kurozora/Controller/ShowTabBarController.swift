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
    
    override func viewDidLoad() {
        super.viewDidLoad()
		tabBar.itemPositioning = .centered
		tabBar.backgroundColor = .clear

        let storyboard = UIStoryboard(name: "details", bundle: nil)

        // Instantiate views
        let showDetail = storyboard.instantiateViewController(withIdentifier: "ShowDetail") as! ShowDetailViewController
        showDetail.showID = showID
        
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
