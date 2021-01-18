//
//  TitleHeaderCollectionReusableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol TitleHeaderCollectionReusableViewDelegate: class {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton)
}

protocol ServiceFooterTableViewCellDelegate: class {
	func serviceFooterTableViewCell(_ cell: ServiceFooterTableViewCell, didPressButton button: UIButton)
}
