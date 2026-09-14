//
//  LibrarySyncVerifier.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import CoreData
import KurozoraKit
import os.log

private nonisolated let verifierLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibrarySyncVerifier")

nonisolated enum LibrarySyncVerifier {
	// MARK: - Types
	/// The outcome of one comparison.
	struct Verdict: Sendable {
		/// The compared library kind.
		let kind: LibraryKind

		/// The server's entry count.
		let serverCount: Int

		/// The local entry count.
		let localCount: Int

		/// The differing fields.
		let differences: [String]

		/// Whether both sides match.
		var passed: Bool {
			return self.differences.isEmpty
		}

		/// A description of the verdict.
		var summary: String {
			let result = self.passed ? "PASS" : "FAIL"
			return "kind=\(self.kind.rawValue) \(result) server=\(self.serverCount) local=\(self.localCount) diffs=\(self.differences.count)"
		}
	}

	/// The compared fields of an entry.
	private struct EntryState: Equatable, Sendable {
		let status: Int
		let isFavorited: Bool
		let isReminded: Bool
		let isHidden: Bool
		let rewatchCount: Int
		let reviewScore: Double?
		let reviewText: String?
		let reviewIsSpoiler: Bool?
		let reviewRecommendation: Int?

		init(_ row: LibrarySyncEntry) {
			self.status = row.status
			self.isFavorited = row.isFavorited
			self.isReminded = row.isReminded
			self.isHidden = row.isHidden
			self.rewatchCount = row.rewatchCount
			self.reviewScore = row.review?.score
			self.reviewText = Self.normalized(row.review?.description)
			self.reviewIsSpoiler = row.review?.isSpoiler
			self.reviewRecommendation = row.review?.recommendation?.rawValue
		}

		init(_ entry: LocalLibraryEntry) {
			self.status = Int(entry.status)
			self.isFavorited = entry.isFavorited
			self.isReminded = entry.isReminded
			self.isHidden = entry.isHidden
			self.rewatchCount = Int(entry.rewatchCount)
			self.reviewScore = entry.review?.score?.doubleValue
			self.reviewText = Self.normalized(entry.review?.text)
			self.reviewIsSpoiler = entry.review?.isSpoiler?.boolValue
			self.reviewRecommendation = entry.review?.recommendation?.intValue
		}

		/// The compared review text.
		private static func normalized(_ text: String?) -> String? {
			guard let text, !text.isEmpty else { return nil }
			return text
		}

		/// The fields that differ from `other`.
		func differences(from other: EntryState) -> [String] {
			var lines: [String] = []

			if self.status != other.status {
				lines.append("status server=\(self.status) local=\(other.status)")
			}
			if self.isFavorited != other.isFavorited {
				lines.append("favorited server=\(self.isFavorited) local=\(other.isFavorited)")
			}
			if self.isReminded != other.isReminded {
				lines.append("reminded server=\(self.isReminded) local=\(other.isReminded)")
			}
			if self.isHidden != other.isHidden {
				lines.append("hidden server=\(self.isHidden) local=\(other.isHidden)")
			}
			if self.rewatchCount != other.rewatchCount {
				lines.append("rewatch server=\(self.rewatchCount) local=\(other.rewatchCount)")
			}
			if self.reviewScore != other.reviewScore {
				lines.append("score server=\(String(describing: self.reviewScore)) local=\(String(describing: other.reviewScore))")
			}
			if self.reviewText != other.reviewText {
				lines.append("review server=\(self.reviewText?.count ?? 0)ch local=\(other.reviewText?.count ?? 0)ch")
			}
			if self.reviewIsSpoiler != other.reviewIsSpoiler {
				lines.append("spoiler server=\(String(describing: self.reviewIsSpoiler)) local=\(String(describing: other.reviewIsSpoiler))")
			}
			if self.reviewRecommendation != other.reviewRecommendation {
				lines.append("recommendation server=\(String(describing: self.reviewRecommendation)) local=\(String(describing: other.reviewRecommendation))")
			}

			return lines
		}
	}

	/// A local entry's compared fields.
	private struct LocalRow: Sendable {
		let trackableID: String
		let isPlaceholder: Bool
		let state: EntryState
	}

	/// The most differences logged per verdict.
	private static let loggedDifferenceLimit = 20

	// MARK: - Functions
	/// Compares the kind's local store with the server.
	///
	/// - Parameters:
	///    - kind: The library kind to compare.
	///    - userSlug: The user's account slug.
	///
	/// - Returns: The verdict.
	static func verify(_ kind: LibraryKind, forUserSlug userSlug: String) async throws -> Verdict {
		let serverStates = try await Self.fetchServerStates(kind)
		let localRows = await Self.fetchLocalRows(forUserSlug: userSlug, kind: kind)
		let localByTrackableID = Dictionary(localRows.map { ($0.trackableID, $0) }, uniquingKeysWith: { first, _ in first })

		var differences: [String] = []

		for trackableID in serverStates.keys.sorted(by: Self.numericallyAscending) {
			guard let serverState = serverStates[trackableID] else { continue }
			guard let localRow = localByTrackableID[trackableID] else {
				differences.append("\(trackableID): missing locally")
				continue
			}

			for line in serverState.differences(from: localRow.state) {
				differences.append("\(trackableID): \(line)")
			}
		}

		for localRow in localRows where serverStates[localRow.trackableID] == nil {
			let origin = localRow.isPlaceholder ? "placeholder" : "server row"
			differences.append("\(localRow.trackableID): only local (\(origin))")
		}

		let verdict = Verdict(kind: kind, serverCount: serverStates.count, localCount: localRows.count, differences: differences)
		Self.log(verdict)
		return verdict
	}

	/// The kind's entries on the server.
	private static func fetchServerStates(_ kind: LibraryKind) async throws -> [String: EntryState] {
		var states: [String: EntryState] = [:]
		var cursors: [LibrarySyncStream: SyncCursor] = [:]

		while true {
			let response = try await KService
				.librarySync()
				.since(cursors)
				.limit(500)
				.response()

			for row in response.data.relationships.entries where row.kind == kind.rawValue {
				if row.deletedAt != nil {
					states.removeValue(forKey: row.trackableID)
				} else {
					states[row.trackableID] = EntryState(row)
				}
			}

			let hasMore = LibrarySyncStream.allCases.contains { response.data.attributes.state(of: $0)?.hasMore == true }
			guard hasMore else { break }

			for stream in LibrarySyncStream.allCases {
				guard let state = response.data.attributes.state(of: stream) else { continue }
				cursors[stream] = state.nextSince
			}
		}

		return states
	}

	/// The kind's entries in the local store.
	private static func fetchLocalRows(forUserSlug userSlug: String, kind: LibraryKind) async -> [LocalRow] {
		let context = PersistenceController.shared.container.newBackgroundContext()

		return await context.perform {
			let request = LocalLibraryEntry.fetchRequest()
			request.predicate = NSPredicate(format: "userSlug == %@ AND kindRaw == %d", userSlug, Int64(kind.rawValue))
			let entries = (try? context.fetch(request)) ?? []

			return entries.map { entry in
				LocalRow(
					trackableID: entry.trackableID,
					isPlaceholder: entry.remoteID.hasPrefix(LocalLibraryEntry.localRemoteIDPrefix),
					state: EntryState(entry)
				)
			}
		}
	}

	/// Orders identifiers numerically.
	private static func numericallyAscending(_ lhs: String, _ rhs: String) -> Bool {
		if let lhsValue = Int(lhs), let rhsValue = Int(rhs) {
			return lhsValue < rhsValue
		}
		return lhs < rhs
	}

	private static func log(_ verdict: Verdict) {
		verifierLogger.notice("VERIFY \(verdict.summary, privacy: .public)")

		for line in verdict.differences.prefix(Self.loggedDifferenceLimit) {
			verifierLogger.notice("VERIFY DIFF kind=\(verdict.kind.rawValue) \(line, privacy: .public)")
		}
	}
}
#endif
