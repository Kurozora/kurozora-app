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
			return UIImage(systemName: "bell.fill")!
		case .notReminded, .disabled:
			return UIImage(systemName: "bell")!
		}
	}
}
