//
//  ReminderStatus+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension ReminderStatus {
	// MARK: - Properties
	/// The image value of a reminder status type.
	var imageValue: UIImage {
		switch self {
		case .reminded:
			return R.image.symbols.bell_fill()!
		case .notReminded, .disabled:
			return R.image.symbols.bell()!
		}
	}
}
