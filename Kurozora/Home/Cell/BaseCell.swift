//
//  BaseCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {}
}
