//
//  CastCollectionViewCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol CastCollectionViewCellDelegate: AnyObject {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressActorButton button: UIButton)
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton)
}
