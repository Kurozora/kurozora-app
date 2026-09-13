//
//  LibrarySearchIndex.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import Foundation
import KurozoraKit
import os.log

private nonisolated let searchIndexLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibrarySearchIndex")

/// Serves typo-tolerant search over the locally-cached library.
@MainActor
final class LibrarySearchIndex {
	// MARK: - Properties
	/// Returns the singleton `LibrarySearchIndex` instance.
	static let shared = LibrarySearchIndex()

	/// The built index of every account.
	private var indexesByUserSlug: [String: Index] = [:]

	private var viewContext: NSManagedObjectContext {
		return PersistenceController.shared.viewContext
	}

	/// The relevance awarded to a token the entry contains verbatim.
	private static let exactQuality = 300

	/// The relevance awarded to a token the entry extends.
	private static let prefixQuality = 200

	/// The relevance awarded to a token the entry contains.
	private static let containsQuality = 150

	/// The relevance awarded to a token one edit away.
	private static let typoQuality = 100

	/// The relevance lost per additional edit.
	private static let typoPenalty = 30

	/// The relevance a field weight is worth.
	private static let fieldWeightScale = 8

	/// The relevance awarded to a token at the start of a field.
	private static let positionBonus = 8

	/// The weight of a match in the title.
	private static let titleWeight = 4

	/// The weight of a match in the sort title.
	private static let sortTitleWeight = 3

	/// The weight of a match in the tagline.
	private static let taglineWeight = 2

	/// The weight of a match in the genres.
	private static let genresWeight = 1

	// MARK: - Initializers
	private init() {}

	// MARK: - Types
	/// An account's token index.
	private struct Index {
		// MARK: - Properties
		/// The indexed entries.
		var documents: [NSManagedObjectID: Document] = [:]

		/// The entries every token appears in.
		var postings: [String: [Posting]] = [:]

		// MARK: - Functions
		/// Indexes the given entry.
		///
		/// - Parameter entry: The entry to index.
		mutating func insert(_ entry: LocalLibraryEntry) {
			self.remove(entry.objectID)

			let trackable = entry.trackable
			let fields: [(String?, Int)] = [
				(trackable?.title, LibrarySearchIndex.titleWeight),
				(trackable?.sortTitle, LibrarySearchIndex.sortTitleWeight),
				(trackable?.tagline, LibrarySearchIndex.taglineWeight),
				(trackable?.genresLocalized, LibrarySearchIndex.genresWeight)
			]
			var indexedTokens: Set<String> = []

			for (text, fieldWeight) in fields {
				guard let text = text else { continue }

				for (position, token) in LibrarySearchIndex.tokens(in: text).enumerated() {
					self.postings[token, default: []].append(Posting(objectID: entry.objectID, fieldWeight: fieldWeight, position: position))
					indexedTokens.insert(token)
				}
			}

			guard !indexedTokens.isEmpty else { return }

			self.documents[entry.objectID] = Document(
				kindRaw: entry.kindRaw,
				popularityRank: trackable?.popularityRank?.intValue ?? Int.max,
				sortTitle: trackable?.sortTitle ?? trackable?.title ?? "",
				tokens: indexedTokens
			)
		}

		/// Drops the entry with the given identifier.
		///
		/// - Parameter objectID: The identifier of the entry to drop.
		mutating func remove(_ objectID: NSManagedObjectID) {
			guard let document = self.documents.removeValue(forKey: objectID) else { return }

			for token in document.tokens {
				self.postings[token]?.removeAll { $0.objectID == objectID }

				guard self.postings[token]?.isEmpty == true else { continue }

				self.postings.removeValue(forKey: token)
			}
		}
	}

	/// An indexed library entry.
	private struct Document {
		/// The raw value of the entry's library kind.
		let kindRaw: Int64

		/// The entry's popularity rank.
		let popularityRank: Int

		/// The entry's sort key.
		let sortTitle: String

		/// The tokens the entry contributed.
		let tokens: Set<String>
	}

	/// A token occurrence inside an entry.
	private struct Posting {
		/// The identifier of the entry holding the token.
		let objectID: NSManagedObjectID

		/// The weight of the field holding the token.
		let fieldWeight: Int

		/// The token's index within its field.
		let position: Int
	}

	// MARK: - Functions
	/// Returns the entries matching the query in relevance order.
	///
	/// - Parameters:
	///    - query: The user's typed query.
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to search.
	///    - status: The status to filter by.
	///    - filter: The filter the user applied.
	///
	/// - Returns: The matching entries, most relevant first.
	func search(_ query: String, forUserSlug userSlug: String, kind: LibraryKind, status: LibraryStatus, filter: SearchFilter? = nil) -> [LocalLibraryEntry] {
		let queryTokens = Self.tokens(in: query)
		guard !queryTokens.isEmpty else { return [] }

		self.buildIndexIfNeeded(forUserSlug: userSlug)
		guard let index = self.indexesByUserSlug[userSlug] else { return [] }

		var scores: [NSManagedObjectID: Int] = [:]
		var matchedTokenCounts: [NSManagedObjectID: Int] = [:]

		for queryToken in queryTokens {
			var bestScores: [NSManagedObjectID: Int] = [:]

			for (token, quality) in Self.candidates(for: queryToken, in: index) {
				for posting in index.postings[token] ?? [] {
					guard index.documents[posting.objectID]?.kindRaw == Int64(kind.rawValue) else { continue }

					let score = quality + posting.fieldWeight * Self.fieldWeightScale + max(0, Self.positionBonus - posting.position)
					bestScores[posting.objectID] = max(bestScores[posting.objectID] ?? 0, score)
				}
			}

			for (objectID, score) in bestScores {
				scores[objectID, default: 0] += score
				matchedTokenCounts[objectID, default: 0] += 1
			}
		}

		let ranked = scores.keys.sorted { lhs, rhs in
			return Self.isRanked(lhs, before: rhs, scores: scores, matchedTokenCounts: matchedTokenCounts, in: index)
		}

		return ranked.compactMap { objectID in
			guard let entry = try? self.viewContext.existingObject(with: objectID) as? LocalLibraryEntry else { return nil }
			guard status == .none || entry.libraryStatus == status else { return nil }
			if let filter = filter, entry.trackable?.matches(filter) != true { return nil }

			return entry
		}
	}

	/// Applies a save onto the built indexes.
	///
	/// - Parameter change: The save to apply.
	func apply(_ change: LibraryEntrySaveChange) {
		guard !self.indexesByUserSlug.isEmpty else { return }

		for objectID in change.changedEntryObjectIDs {
			guard let entry = try? self.viewContext.existingObject(with: objectID) as? LocalLibraryEntry else { continue }

			self.indexesByUserSlug[entry.userSlug]?.insert(entry)
		}

		for removed in change.removedEntries {
			self.indexesByUserSlug[removed.userSlug]?.remove(removed.objectID)
		}
	}

	/// Drops the account's index.
	///
	/// - Parameter userSlug: The user's account slug.
	func clear(forUserSlug userSlug: String) {
		self.indexesByUserSlug.removeValue(forKey: userSlug)
	}

	/// Returns the normalized tokens of the given text.
	///
	/// - Parameter text: The text to tokenize.
	///
	/// - Returns: The text's tokens in reading order.
	static func tokens(in text: String) -> [String] {
		let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
		var tokens: [String] = []

		folded.enumerateSubstrings(in: folded.startIndex ..< folded.endIndex, options: [.byWords, .localized]) { substring, _, _, _ in
			guard let substring = substring, !substring.isEmpty else { return }

			tokens.append(substring)
		}

		return tokens
	}

	/// Builds the account's index on first use.
	///
	/// - Parameter userSlug: The user's account slug.
	private func buildIndexIfNeeded(forUserSlug userSlug: String) {
		guard self.indexesByUserSlug[userSlug] == nil else { return }

		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@", userSlug)

		var index = Index()
		let entries = (try? self.viewContext.fetch(request)) ?? []

		for entry in entries {
			index.insert(entry)
		}

		self.indexesByUserSlug[userSlug] = index
		searchIndexLogger.info("INDEX entries=\(entries.count) tokens=\(index.postings.count)")
	}

	/// Returns the indexed tokens worth scoring for the given query token.
	///
	/// - Parameters:
	///    - queryToken: A normalized token of the user's query.
	///    - index: The account's index.
	///
	/// - Returns: Each candidate token paired with its match quality.
	private static func candidates(for queryToken: String, in index: Index) -> [(String, Int)] {
		var candidates: [(String, Int)] = []
		let queryCharacters = Array(queryToken)
		let maximumEdits = Self.maximumEdits(forTokenLength: queryCharacters.count)

		for token in index.postings.keys {
			if token == queryToken {
				candidates.append((token, Self.exactQuality))
				continue
			}
			if token.hasPrefix(queryToken) {
				candidates.append((token, Self.prefixQuality))
				continue
			}
			if token.contains(queryToken) {
				candidates.append((token, Self.containsQuality))
				continue
			}

			guard maximumEdits > 0, token.first == queryToken.first else { continue }

			let characters = Array(token)
			guard abs(characters.count - queryCharacters.count) <= maximumEdits else { continue }

			let distance = Self.editDistance(queryCharacters, characters, maximum: maximumEdits)
			guard distance <= maximumEdits else { continue }

			candidates.append((token, Self.typoQuality - (distance - 1) * Self.typoPenalty))
		}

		return candidates
	}

	/// Returns the edits tolerated for a token of the given length.
	///
	/// - Parameter length: The length of the query token.
	///
	/// - Returns: The number of edits a match may differ by.
	private static func maximumEdits(forTokenLength length: Int) -> Int {
		if length >= 9 {
			return 2
		}
		if length >= 4 {
			return 1
		}

		return 0
	}

	/// Returns the Damerau-Levenshtein distance between the two tokens.
	///
	/// - Parameters:
	///    - lhs: The characters of the first token.
	///    - rhs: The characters of the second token.
	///    - maximum: The distance past which the exact value stops mattering.
	///
	/// - Returns: The distance, or a value above `maximum` once every alignment exceeds it.
	private static func editDistance(_ lhs: [Swift.Character], _ rhs: [Swift.Character], maximum: Int) -> Int {
		guard !lhs.isEmpty else { return rhs.count }
		guard !rhs.isEmpty else { return lhs.count }

		var beforePreviousRow = [Int](repeating: 0, count: rhs.count + 1)
		var previousRow = Array(0 ... rhs.count)
		var currentRow = [Int](repeating: 0, count: rhs.count + 1)

		for lhsIndex in 1 ... lhs.count {
			currentRow[0] = lhsIndex
			var rowMinimum = lhsIndex

			for rhsIndex in 1 ... rhs.count {
				let substitutionCost = lhs[lhsIndex - 1] == rhs[rhsIndex - 1] ? 0 : 1
				var value = min(
					previousRow[rhsIndex] + 1,
					currentRow[rhsIndex - 1] + 1,
					previousRow[rhsIndex - 1] + substitutionCost
				)

				if lhsIndex > 1, rhsIndex > 1, lhs[lhsIndex - 1] == rhs[rhsIndex - 2], lhs[lhsIndex - 2] == rhs[rhsIndex - 1] {
					value = min(value, beforePreviousRow[rhsIndex - 2] + 1)
				}

				currentRow[rhsIndex] = value
				rowMinimum = min(rowMinimum, value)
			}

			guard rowMinimum <= maximum else { return maximum + 1 }

			beforePreviousRow = previousRow
			previousRow = currentRow
		}

		return previousRow[rhs.count]
	}

	/// Returns whether the first entry outranks the second.
	///
	/// - Parameters:
	///    - lhs: The identifier of the first entry.
	///    - rhs: The identifier of the second entry.
	///    - scores: The relevance summed per entry.
	///    - matchedTokenCounts: The number of query tokens matched per entry.
	///    - index: The account's index.
	///
	/// - Returns: `true` when the first entry sorts ahead of the second.
	private static func isRanked(
		_ lhs: NSManagedObjectID,
		before rhs: NSManagedObjectID,
		scores: [NSManagedObjectID: Int],
		matchedTokenCounts: [NSManagedObjectID: Int],
		in index: Index
	) -> Bool {
		let lhsMatchedTokenCount = matchedTokenCounts[lhs] ?? 0
		let rhsMatchedTokenCount = matchedTokenCounts[rhs] ?? 0
		guard lhsMatchedTokenCount == rhsMatchedTokenCount else { return lhsMatchedTokenCount > rhsMatchedTokenCount }

		let lhsScore = scores[lhs] ?? 0
		let rhsScore = scores[rhs] ?? 0
		guard lhsScore == rhsScore else { return lhsScore > rhsScore }

		let lhsDocument = index.documents[lhs]
		let rhsDocument = index.documents[rhs]
		let lhsPopularityRank = lhsDocument?.popularityRank ?? Int.max
		let rhsPopularityRank = rhsDocument?.popularityRank ?? Int.max
		guard lhsPopularityRank == rhsPopularityRank else { return lhsPopularityRank < rhsPopularityRank }

		return (lhsDocument?.sortTitle ?? "").localizedCompare(rhsDocument?.sortTitle ?? "") == .orderedAscending
	}
}
