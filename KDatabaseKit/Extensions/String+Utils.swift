//
//  String+Utils.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

// Check if string ends with substring.
//
// "Hello World!".ends(with: "!") -> true
// "Hello World!".ends(with: "WoRld!", caseInsensitive: true) -> true
//
// - Parameters:
//   - suffix: substring to search if string ends with.
//   - caseInsensitive: set true for case insensitive search (default is true).
// - Returns: true if string ends with substring.

extension String {
    func ends(with suffix: String, caseInsensitive: Bool = true) -> Bool {
        if !caseInsensitive {
            return lowercased().hasSuffix(suffix.lowercased())
        }
        return hasSuffix(suffix)
    }
}
