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
    
    private let headerId = "headerId"
    private let cellId = "cellId"
    private let largeCellId = "largeCellId"
    
    let autoScrollDuration: TimeInterval = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func fetchFeaturedShows(completionHandler: @escaping (FeaturedShows) -> ()) {
        let urlString = GlobalVariables().BaseURLString + "anime/explore"
        
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
        let layout = UICollectionViewFlowLayout()
        let showDetailViewController = ShowDetailViewController(collectionViewLayout: layout)
        
        showDetailViewController.show = show
        
        navigationController?.pushViewController(showDetailViewController, animated: true)
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
