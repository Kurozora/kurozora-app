//
//  Global+Swift.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

func print(items: Any..., separator: String = " ", terminator: String = "\n") {
	#if DEBUG
	var idx = items.startIndex
	let endIdx = items.endIndex

	repeat {
		Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
		idx += 1
	} while idx < endIdx
	#endif
}
