//
//  NSLayoutManager+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension NSLayoutManager {
	var numberOfLines: Int {
		guard textStorage != nil else { return 0 }

		var count = 0
		enumerateLineFragments(forGlyphRange: NSMakeRange(0, numberOfGlyphs)) { _, _, _, _, _ in
			count += 1
		}
		return count
	}
}
