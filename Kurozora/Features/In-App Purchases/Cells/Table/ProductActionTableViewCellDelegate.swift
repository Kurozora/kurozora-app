//
//  ProductActionTableViewCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol ProductActionTableViewCellDelegate: class {
	func productActionTableViewCell(_ cell: ProductActionTableViewCell, didPressButton button: UIButton)
}
