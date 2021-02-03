//
//  LibraryListViewControllerDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol LibraryListViewControllerDelegate: AnyObject {
	func libraryListViewController(updateLayoutWith cellStyle: KKLibrary.CellStyle)
	func libraryListViewController(updateSortWith sortType: KKLibrary.SortType)
}
