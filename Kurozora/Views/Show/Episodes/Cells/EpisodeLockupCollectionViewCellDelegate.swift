//
//  EpisodeLockupCollectionViewCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol EpisodeLockupCollectionViewCellDelegate: class {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressMoreButton button: UIButton)
}
