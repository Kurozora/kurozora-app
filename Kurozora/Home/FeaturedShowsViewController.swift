//
//  FeaturedShowsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit

class FeaturedShowsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var showCategories: [ShowCategory]?
    private var bannersCategory: FeaturedShows?
    var window: UIWindow?
    
    private let headerId = "headerId"
    private let cellId = "cellId"
    private let largeCellId = "largeCellId"
    
    let autoScrollDuration: TimeInterval = 4
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        Service.shared.validateSession(withSuccess: { (success) in
            if !success {
                let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                self.present(vc, animated: true, completion: nil)
            }
            NotificationCenter.default.post(name: heartAttackNotification, object: nil)
        })
        
        collectionView?.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
        
        // Register cells
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(LargeCategoryCell.self, forCellWithReuseIdentifier: largeCellId)
        collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)

        // Fetch shows
        fetchFeaturedShows { (featuredShows) in
            self.showCategories = featuredShows.categories
            self.bannersCategory = featuredShows
            
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: - Reachabiltiy functions
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            if !UIAccessibilityIsReduceTransparencyEnabled() {
                let storyboard: UIStoryboard = UIStoryboard(name: "reachability", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Reachability")
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
            } else {
                view.backgroundColor = .white
            }
        case .wifi:
            view.backgroundColor = .green
        case .wwan:
            view.backgroundColor = .yellow
        }
    }
    
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    // MARK: - Show functions
    private func fetchFeaturedShows(completionHandler: @escaping (FeaturedShows) -> ()) {
        let urlString = GlobalVariables().baseUrlString + "anime/explore"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, _, _) in
            guard let data = data else { return }
            
            do {
                let featuredShows = try JSONDecoder().decode(FeaturedShows.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(featuredShows)
                }
            } catch let err{
                NSLog("------ EXPLORE ERROR: \(err)")
            }
        }.resume()
    }
    
    func showDetailFor(_ show: Show) {
        let storyboard = UIStoryboard(name: "details", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ShowDetail") as? ShowDetailViewController
        controller?.show = show
        let customTabBar = ShowTabBarController()
        self.window?.rootViewController = customTabBar
        
        self.present(controller!, animated: true, completion: nil)
    }
    
    // Colletion view number of sections
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = showCategories?.count {
            return count
        }
        
        return 0
    }
    
    // Collection view item cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if showCategories?[indexPath.item].type == "large" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeCellId, for: indexPath) as! LargeCategoryCell
            
            cell.showCategory = showCategories?[indexPath.item]
            cell.featuredShowsViewController = self
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
        
        cell.showCategory = showCategories?[indexPath.item]
        cell.featuredShowsViewController = self
        
        return cell
    }
    
    // Collection view view item size/type
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if showCategories?[indexPath.item].type == "large" {
            return CGSize(width: view.frame.width, height: 160)
        }
        
        return CGSize(width: view.frame.width, height: 230)
    }
    
    // Collection header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! Header

        header.featuredShows = bannersCategory?.banners

        return header
    }
    
    // Collection view header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if UIDevice.isLandscape() {
            if UIDevice.isPad() {
//                return CGSize(width: view.frame.width, height: 264)
                return CGSize(width: view.frame.width, height: view.frame.height / 2.5)
            }
        }
        
        if UIDevice.isPad() {
            return CGSize(width: view.frame.width, height: 264)
        }
        
        return CGSize(width: view.frame.width, height: 144)
    }
    
    // Reload collection to fix layout - NEEDS A BETTER FIX IF POSSIBLE
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super .viewWillTransition(to: size, with: coordinator)
        collectionView?.reloadData()
    }
}
