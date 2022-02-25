//
//  String+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension String {
	// MARK: - Properties
	/// Returns the initial characters (up to 2 characters) of the string separated by a whitespace or a dot. For example "John Appleseed" and "John.Appleseed" returns "JA". Returned value is case insensitive which means "john appleseed" will return "ja".
	var initials: String {
		let stringSeparatedByWhiteSpace = self.components(separatedBy: [".", " ", "-"])
		let initials = stringSeparatedByWhiteSpace.reduce("") { ($0 == "" ? "" : "\($0.first ?? " ")") + "\($1.first ?? " ")" }
		return initials
	}

	/// Returns a copy of the sequence with the first element capitalized.
	var capitalizedFirstLetter: String {
		return self.prefix(1).capitalized + self.dropFirst()
	}

	/// Returns HTML string as `NSAttributedString`.
	func htmlAttributedString() -> NSAttributedString? {
		let htmlTemplate = """
		<!doctype html>
		<html>
		  <head>
			<style>
			  body {
				font-family: -apple-system;
				font-size: 17px;
			  }
			</style>
		  </head>
		  <body>
			\(self.replacingOccurrences(of: "<hr />", with: "* * *"))
		  </body>
		</html>
		"""
		guard let data = htmlTemplate.data(using: .utf16) else {
			return nil
		}

		guard let attributedString = try? NSAttributedString(
			data: data,
			options: [.documentType: NSAttributedString.DocumentType.html],
			documentAttributes: nil
		) else {
			return nil
		}

		return attributedString
	}
}
