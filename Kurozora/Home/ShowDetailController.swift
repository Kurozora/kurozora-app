//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class ShowDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var show: Show?
    
    private let headerId = "headerId"
    private let cellId = "cellId"
    private let descriptionCellId = "descriptionCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
        collectionView?.register(ShowDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(ScreenShotsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(ShowDetailDescriptionCell.self, forCellWithReuseIdentifier: descriptionCellId)
        if let id = show?.id {
            fetchShowDetailsFor(id) { (showWithDetails) in
                self.show = showWithDetails
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func fetchShowDetailsFor(_ id: String, completionHandler: @escaping (Show) -> ()) {
        let urlString = "https://api.letsbuildthatapp.com/appstore/appdetail?id=\(id)"
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            guard let data = data else { return }
            do {
                let showWithDetails = try JSONDecoder().decode(Show.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(showWithDetails)
                }
            } catch let err{
                print(err)
            }
            }.resume()
    }
    
    private func descriptionAttributedText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Description\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSMakeRange(0, attributedText.string.count)
        attributedText.addAttributes([NSAttributedStringKey.paragraphStyle: style], range: range)
        
        if let description = show?.desc {
            attributedText.append(NSAttributedString(string: description, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.darkGray]))
        }
        
        return attributedText
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! ShowDetailDescriptionCell
            cell.textView.attributedText = descriptionAttributedText()
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenShotsCell
        cell.show = show
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 1 {
            let dummySize = CGSize(width: view.frame.width - 8 - 8, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let rect = descriptionAttributedText().boundingRect(with: dummySize, options: options, context: nil)
            return CGSize(width: view.frame.width, height: rect.height + 30)
        }
        return CGSize(width: view.frame.width, height: 170)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ShowDetailHeader
        header.show = show
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 170)
    }
    
}

