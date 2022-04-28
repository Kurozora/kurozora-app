//
//  SidebarItem.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension SidebarViewController {
	struct SidebarItem: Hashable, Identifiable {
		let id: UUID
		let title: String
		let image: UIImage?

		static func row(title: String, image: UIImage, id: UUID = UUID()) -> Self {
			return SidebarItem(id: id, title: title, image: image)
		}
	}
}
