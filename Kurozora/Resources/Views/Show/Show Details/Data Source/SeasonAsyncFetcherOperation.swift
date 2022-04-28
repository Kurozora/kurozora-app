//
//  SeasonAsyncFetcherOperation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

// import Foundation
// import KurozoraKit
//
// class SeasonAsyncFetcherOperation: Operation {
//	// MARK: Properties
//	/// The `Int` that the operation is fetching data for.
//	let identifier: Int
//
//	/// The `DisplayData` that has been fetched by this operation.
//	private(set) var fetchedData: Season?
//
//	// MARK: Initialization
//	init(identifier: Int) {
//		self.identifier = identifier
//	}
//
//	// MARK: Operation overrides
//	override func main() {
//		// Check if the operation was cancelled and is no longer needed
//		if self.isCancelled { return }
//
//		// Fetch data
//		let getSeasonDetails = KService.getDetails(forSeasonID: self.identifier) { result in
//			switch result {
//			case .success(let season):
//				// Save data
//				self.fetchedData = season.first
//			case .failure:
//				break
//			}
//		}
//
//		// Make sure the operation wasn't cancelled
//		if self.isCancelled {
//			// Cancel request
//			getSeasonDetails.cancelRequest()
//			return
//		}
//	}
// }
