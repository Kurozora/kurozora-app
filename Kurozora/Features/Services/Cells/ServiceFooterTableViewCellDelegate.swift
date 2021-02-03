//
//  ServiceFooterTableViewCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol ServiceFooterTableViewCellDelegate: AnyObject {
	func serviceFooterTableViewCell(_ cell: ServiceFooterTableViewCell, didPressButton button: UIButton)
}
