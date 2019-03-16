//
//  ThemeCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class ThemeCell: UICollectionViewCell {
    @IBOutlet weak var themeScreenshot: UIImageView!
    @IBOutlet weak var themeTitle: UILabel!
    @IBOutlet weak var themeCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let theme = themes?[indexPath.item] {
//            themesViewController?.showDetailFor(theme)
//        }
//    }
}
