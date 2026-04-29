//
//  SearchResultsCollectionViewController+Tokens.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

@available(iOS 16.0, *)
extension SearchResultsCollectionViewController {
	// MARK: - Functions
	/// Returns the list of types offered as token suggestions — scope-valid types that aren't already tokenized, filtered by the current typed prefix.
	func tokenSuggestionTypes() -> [SearchType] {
		let tokenizedTypes = Set(self.typesFromTokens())
		let prefix = self.currentTypedWord().lowercased()
		let types = self.availableTypesForCurrentScope().filter { !tokenizedTypes.contains($0) }

		guard !prefix.isEmpty else {
			return types
		}

		return types.filter { type in
			type.tokenKeywords.contains { $0.hasPrefix(prefix) } || type.stringValue.lowercased().hasPrefix(prefix)
		}
	}

	/// Returns the lowercase word currently being typed (text after the last space / token), empty if none.
	private func currentTypedWord() -> String {
		let text = self.kSearchController.searchBar.searchTextField.text ?? ""
		guard let lastSpace = text.lastIndex(of: " ") else {
			return text
		}
		return String(text[text.index(after: lastSpace)...])
	}

	/// Removes the in-progress typed word from the search field.
	func removeCurrentTypedWord() {
		let searchTextField = self.kSearchController.searchBar.searchTextField
		let text = searchTextField.text ?? ""

		if let lastSpace = text.lastIndex(of: " ") {
			searchTextField.text = String(text[...lastSpace])
		} else {
			searchTextField.text = ""
		}
	}

	/// Detects `keyword:` + trailing space — only when the keyword is the first non-whitespace text — and promotes it to a token.
	func tokenizeTypedKeywordIfNeeded() {
		let searchTextField = self.kSearchController.searchBar.searchTextField
		let text = searchTextField.text ?? ""

		guard text.hasSuffix(" "), let colonIndex = text.firstIndex(of: ":") else { return }

		let afterColon = text[text.index(after: colonIndex)...]
		guard afterColon.allSatisfy({ $0.isWhitespace }) else { return }

		let beforeColon = text[..<colonIndex]
		let keyword = beforeColon.trimmingCharacters(in: .whitespaces).lowercased()
		guard !keyword.isEmpty, !keyword.contains(where: { $0.isWhitespace }) else { return }

		let scopeTypes = self.availableTypesForCurrentScope()
		let alreadyTokenized = Set(self.typesFromTokens())
		guard let matched = scopeTypes.first(where: { type in
			!alreadyTokenized.contains(type) && type.tokenKeywords.contains(keyword)
		}) else { return }

		let token = UISearchToken(icon: nil, text: matched.stringValue)
		token.representedObject = matched
		searchTextField.insertToken(token, at: searchTextField.tokens.count)
		searchTextField.text = ""

		self.updateDataSource()
	}
}
