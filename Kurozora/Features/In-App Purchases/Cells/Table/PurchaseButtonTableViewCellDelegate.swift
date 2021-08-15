//
//  PurchaseButtonTableViewCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol PurchaseButtonTableViewCellDelegate: AnyObject {
	func purchaseButtonTableViewCell(_ cell: PurchaseButtonTableViewCell, didPressButton button: UIButton) async
}
