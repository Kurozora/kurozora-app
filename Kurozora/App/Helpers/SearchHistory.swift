//
//  SearchHistory.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import Foundation

struct SearchHistory {
	// MARK: - Poperties
	fileprivate static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	fileprivate static let filePathURL = documentsDirectory?.appendingPathComponent("Search History.json")

	// MARK: - Functions
	/// Fetches the contents of the search history file.
	///
	/// Fetching of the content is ran on a background thread for best performance. The fetched content is then returned on the main thread to allow for UI changes.
	///
	/// - Parameters:
	///    - successHandler: A closure returning a `Show` array.
	///    - shows: The returned  `Show` array.
	static func getContent(_ successHandler: @escaping (_ shows: [Show]) -> Void) {
		guard let filePathURL = self.filePathURL else { return }

		if self.fileExists() {
			DispatchQueue.global(qos: .utility).async {
				do {
					let contentsOfFile = try Data(contentsOf: filePathURL)

					DispatchQueue.main.async {
						if let showResponse = ShowResponse(from: contentsOfFile) {
							successHandler(showResponse.data)
						}
					}
				} catch {
				}
			}
		}
	}

	/// Writes the specified `Show` to the search history file.
	///
	/// - Parameter show: The specified `Show` to be saved.
	static func saveContentsOf(_ show: Show) {
		if self.fileExists() {
			self.getContent { shows in
				var fileShows = shows
				fileShows.removeFirst(where: { $0.id == show.id })
				fileShows.prepend(show)
				self.save(getDictionary(from: fileShows)) { _ in }
			}
		}
	}

	/// Check if search history file exists, otherwise calls the `createFile` function.
	///
	/// - Returns: Boolean indicating whether search history file exists.
	fileprivate static func fileExists() -> Bool {
		guard let filePathURL = self.filePathURL else { return false }

		do {
			return try filePathURL.checkResourceIsReachable()
		} catch {
			self.save(["data": []]) { _ in }
			return false
		}
	}

	/// Returns a Dictionary from the specified `Show` array.
	///
	/// - Parameter shows: The specified `shows` array from which a Dictionary is created.
	///
	/// - Returns: a Dictionary from the specified `Show` array.
	fileprivate static func getDictionary(from shows: [Show]) -> [String: Any] {
		var shows = shows
		if shows.count > 10 {
			shows.removeLast()
		}

		var showDictionary = ["data": []]
		do {
			let data = try JSONEncoder().encode(shows)
			let dictionary = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)

			showDictionary["data"] = dictionary as? [Any]
		} catch {
		}

		return showDictionary
	}

	/// Writes the specified dictionary to the search history file as JSON and returns a boolean indicating weather the write was successful.
	///
	/// - Parameters:
	///    - dictionary: The specified dictionary to be written to the search history file.
	///    - successHandler: A closure returning a boolean indicating whether the writing is successful.
	///    - isSuccess: A boolean value indicating whether the writing is successful.
	fileprivate static func save(_ dictionary: [String: Any], _ successHandler: ((_ isSuccess: Bool) -> Void)? = nil) {
		guard let filePathURL = self.filePathURL else { return }

		DispatchQueue.global(qos: .utility).async {
			do {
				try dictionary.jsonData()?.write(to: filePathURL)
				successHandler?(true)
			} catch {
				successHandler?(false)
			}
		}
	}
}
