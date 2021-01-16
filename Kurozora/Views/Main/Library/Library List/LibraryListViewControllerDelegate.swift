//
//  LibraryListViewControllerDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol LibraryListViewControllerDelegate: class {
	func updateChangeLayoutButton(with cellStyle: KKLibrary.CellStyle)
	func updateSortTypeButton(with sortType: KKLibrary.SortType)
}
