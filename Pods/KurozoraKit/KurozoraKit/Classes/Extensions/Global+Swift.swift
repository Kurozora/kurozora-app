//
//  Global+Swift.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/04/2020.
//

import Foundation

/// Writes the textual representations of the given items into the standard output which only prints in `Debug` configuration.
///
/// You can pass zero or more items to the `print(_:separator:terminator:)` function. The textual representation for each item is the same as that obtained by calling `String(item)`. The following example prints a string, a closed range of integers, and a group of floating-point values to standard output:
///
/// ```
/// print("One two three four five")
/// // Prints "One two three four five"
///
/// print(1...5)
/// // Prints "1...5"
///
/// print(1.0, 2.0, 3.0, 4.0, 5.0)
/// // Prints "1.0 2.0 3.0 4.0 5.0"
/// ```
///
/// To print the items separated by something other than a space, pass a string as `separator`.
///
/// ```
/// print(1.0, 2.0, 3.0, 4.0, 5.0, separator: " ... ")
/// // Prints "1.0 ... 2.0 ... 3.0 ... 4.0 ... 5.0"
/// ```
///
/// The output from each call to `print(_:separator:terminator:)` includes a newline by default. To print the items without a trailing newline, pass an empty string as `terminator`.
/// ```
/// for n in 1...5 {
///     print(n, terminator: "")
/// }
/// // Prints "12345"
/// ```
///
/// - Parameter items: Zero or more items to print.
/// - Parameter separator: A string to print between each item. The default is a single space (`" "`).
/// - Parameter terminator: The string to print after all items have been printed. The default is a newline (`"\n"`).
internal func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	#if DEBUG
	var idx = items.startIndex
	let endIdx = items.endIndex

	repeat {
		Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
		idx += 1
	} while idx < endIdx
	#endif
}
