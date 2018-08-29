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
    override func viewDidLoad() {
        super.viewDidLoad()

        let showDetailStoryboard = UIStoryboard(name: "details", bundle: nil)
        let showDetail = showDetailStoryboard.instantiateViewController(withIdentifier: "ShowDetail") as! ShowDetailViewController
        
//        let castStoryboard = UIStoryboard(name: "details", bundle: nil)
//        let cast = castStoryboard.instantiateViewController(withIdentifier: "Cast") as! EpisodesViewController
        
        let episodesStoryboard = UIStoryboard(name: "details", bundle: nil)
        let episodes = episodesStoryboard.instantiateViewController(withIdentifier: "Episodes") as! EpisodesViewController

        showDetail.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "DETAILS")
//        cast.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "CAST")
        episodes.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "EPISODES")
        
        viewControllers = [showDetail, episodes]
    }
}
