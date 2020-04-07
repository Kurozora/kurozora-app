//
//  SearchHistory.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import Foundation
import SwiftyJSON

class SearchHistory {
	// MARK: - Initializers
	private init() { }

	// MARK: - Poperties
	fileprivate static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	fileprivate static let filePathURL = documentsDirectory?.appendingPathComponent("Search History.json")

	// MARK: - Functions
	/**
		Fetches the contents of the search history file.

		Fetching of the content is ran on a background thread for best performance. The fetched content is then returned on the main thread to allow for UI changes.

		- Parameter successHandler: A closure returning a ShowDetailsElement array.
		- Parameter showDetailsElement: The returned  ShowDetailsElement array.
	*/
	static func getContent(_ successHandler: @escaping (_ showDetailsElement: [ShowDetailsElement]) -> Void) {
		guard let filePathURL = filePathURL else { return }

		if fileExists() {
			DispatchQueue.global(qos: .background).async {
				do {
					let contentsOfFile = try Data(contentsOf: filePathURL)
					let jsonFromFile = try JSON(data: contentsOfFile)
					var showDetails: ShowDetails?

					DispatchQueue.main.async {
						showDetails = try? ShowDetails(json: jsonFromFile)
						if let showDetailsElements = showDetails?.showDetailsElements {
							successHandler(showDetailsElements)
						}
					}
				} catch {
				}
			}
		}
	}

	/**
		Writes the specified `ShowDetailsElement` to the search history file.

		- Parameter showDetailsElement: The specified `ShowDetailsElement` to be saved.
	*/
	static func saveContentsOf(_ showDetailsElement: ShowDetailsElement?) {
		if let showDetailsElement = showDetailsElement, fileExists() {
			getContent { (showDetailsElements) in
				var fileShowDetailsElements = showDetailsElements
				fileShowDetailsElements.removeFirst(where: { $0.id == showDetailsElement.id })
				fileShowDetailsElements.prepend(showDetailsElement)
				save(getJSON(from: fileShowDetailsElements)) { _ in
				}
			}
		}
	}

	/**
		Check if search history file exists, otherwise calls the `createFile` function.

		- Returns: Boolean indicating whether search history file exists.
	*/
	fileprivate static func fileExists() -> Bool {
		guard let filePathURL = filePathURL else { return false }

		do {
			return try filePathURL.checkResourceIsReachable()
		} catch {
			save(["anime": []]) { _ in
			}
			return false
		}
	}

	/**
		Returns a JSON from the specified `ShowDetailsElement` array.

		- Parameter showDetailsElements: The specified `showDetailsElements` array from which a JSON is created.

		- Returns: a JSON from the specified `ShowDetailsElement` array.
	*/
	fileprivate static func getJSON(from showDetailsElements: [ShowDetailsElement]) -> [String: Any] {
		var showDetailsElements = showDetailsElements
		if showDetailsElements.count > 10 {
			showDetailsElements.removeLast()
		}
		var showJSON = ["anime": []]
		for showDetailsElement in showDetailsElements {
			showJSON["anime"]?.append([
				"id": showDetailsElement.id ?? 0,
				"title": showDetailsElement.title ?? "",
				"poster_thumbnail": showDetailsElement.posterThumbnail ?? ""
			])
		}
		return showJSON
	}

	/**
		Writes the specified object to the search history file as JSON and returns a boolean indicating weather the write was successful.

		- Parameter object: The specified object to be written to the search history file.
		- Parameter successHandler: A closure returning a boolean indicating whether the writing is successful.
		- Parameter isSuccess: A boolean value indicating whether the writing is successful.
	*/
	fileprivate static func save(_ object: [String: Any], _ successHandler: ((_ isSuccess: Bool) -> Void)? = nil) {
		guard let filePathURL = filePathURL else { return }

		DispatchQueue.global(qos: .background).async {
			do {
				let jsonFromObject = JSON(object)
				let dataFromJSON = try jsonFromObject.rawData()
				try dataFromJSON.write(to: filePathURL)

				successHandler?(true)
			} catch {
				successHandler?(false)
			}
		}
	}
}
