//
//  ManageThemesController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit
import KDatabaseKit
import Alamofire
import SwiftyJSON
import SCLAlertView

class ManageThemesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    @IBOutlet var collectionView: UICollectionView!
    
    var themeArray:[JSON] = []
    
    override func viewWillAppear(_ animated: Bool) {
        Request.getThemes( withSuccess: { (array) in
            self.themeArray = array
            
//            Update collection with new information
            DispatchQueue.main.async() {
                self.collectionView.reloadData()
            }
        }) { (errorMsg) in
            SCLAlertView().showError("Themes", subTitle: errorMsg)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "ThemeCell", bundle: nil), forCellWithReuseIdentifier: "ThemeCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    //    MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let themeCell: ThemeCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCell", for: indexPath as IndexPath) as! ThemeCell
        
        themeCell.themeTitle.text = themeArray[indexPath.row]["title"].stringValue
        themeCell.themeCount.text = "Count: \(themeArray[indexPath.row]["count"].intValue)"
        
        do {
            let themeUrl = themeArray[indexPath.row]["theme_poster"].stringValue
            let url = URL(string: themeUrl)
            let data = try Data(contentsOf: url!)
            
            themeCell.themeScreenshot.image = UIImage(data: data)
        }
        catch{
            print(error)
        }
        //            NSLog("------------------DATA START-------------------")
        //            NSLog("Response String: \(String(describing: indexPath.row))")
        //            NSLog("------------------DATA END-------------------")
    
        return themeCell
    }
}
