//
//  ThemesCollectionViewCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol ThemesCollectionViewCellDelegate: AnyObject {
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressGetButton button: UIButton)
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressMoreButton button: UIButton)
}
