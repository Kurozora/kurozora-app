//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit

class ShowDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var showDetails: ShowDetails?
    var show: Show?

    private let headerId = "headerId"
    private let cellId = "cellId"
    private let descriptionCellId = "synopsisCellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }

        // Register cells
        collectionView?.register(ShowDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(ScreenShotsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(ShowDetailCell.self, forCellWithReuseIdentifier: descriptionCellId)

        // Fetch details
        if let id = show?.id {
            fetchShowDetailsFor(id) { (showDetails) in
                self.showDetails = showDetails
                self.collectionView?.reloadData()
            }
        }
    }

    private func fetchShowDetailsFor(_ id: Int, completionHandler: @escaping (ShowDetails) -> ()) {
        let urlString = GlobalVariables().BaseURLString + "anime/\(id)/details"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let showDetails = try JSONDecoder().decode(ShowDetails.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(showDetails)
                }
            } catch let err{
                NSLog("------ DETAILS ERROR: \(err)")
            }
        }.resume()
    }
    
    private func descriptionAttributedText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Synopsis\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSMakeRange(0, attributedText.string.count)
        attributedText.addAttributes([NSAttributedStringKey.paragraphStyle: style], range: range)
        
        if let description = show?.synopsis {
            attributedText.append(NSAttributedString(string: description, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.darkGray]))
        }
        
        return attributedText
    }
    
    // Colletion view number of sections
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    // Collection view item cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! ShowDetailCell
            cell.showDetails = showDetails?.anime
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenShotsCell
        cell.show = show
        return cell
    }
    
    // Collection view item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 1 {
            return CGSize(width: view.frame.width, height: view.frame.height)
        }
        return CGSize(width: view.frame.width, height: 170)
    }
    
    // Collection header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ShowDetailHeader
        
        header.showDetails = showDetails?.anime
        
        return header
    }
    
    // Collection view header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 170)
    }
    
}

