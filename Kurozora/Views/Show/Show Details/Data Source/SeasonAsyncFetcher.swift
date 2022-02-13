//
//  SeasonAsyncFetcher.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

// import Foundation
// import KurozoraKit
//
// /// - Tag: SeasonAsyncFetcher
// class SeasonAsyncFetcher {
//	// MARK: Types
//
//	/// A serial `OperationQueue` to lock access to the `fetchQueue` and `completionHandlers` properties.
//	private let serialAccessQueue = OperationQueue()
//
//	/// An `OperationQueue` that contains `SeasonAsyncFetcherOperation`s for requested data.
//	private let fetchQueue = OperationQueue()
//
//	/// A dictionary of arrays of closures to call when an object has been fetched for an id.
//	private var completionHandlers = [Int: [(Season?) -> Void]]()
//
//	/// An `NSCache` used to store fetched objects.
//	private var cache = NSCache<NSNumber, Season>()
//
//	// MARK: Initialization
//	init() {
//		serialAccessQueue.maxConcurrentOperationCount = 1
//	}
//
//	// MARK: Object fetching
//
//	/**
//		Asynchronously fetches data for a specified `Int`.
//
//		- Parameters:
//		- identifier: The `Int` to fetch data for.
//		- completion: An optional called when the data has been fetched.
//	*/
//	func fetchAsync(_ identifier: Int, completion: ((Season?) -> Void)? = nil) {
//		// Use the serial queue while we access the fetch queue and completion handlers.
//		serialAccessQueue.addOperation {
//			// If a completion block has been provided, store it.
//			if let completion = completion {
//				let handlers = self.completionHandlers[identifier, default: []]
//				self.completionHandlers[identifier] = handlers + [completion]
//			}
//
//			self.fetchData(for: identifier)
//		}
//	}
//
//	/**
//		Returns the previously fetched data for a specified `Int`.
//
//		- Parameter identifier: The `Int` of the object to return.
//		- Returns: The 'Season' that has previously been fetched or nil.
//	*/
//	func fetchedData(for identifier: Int) -> Season? {
//		return cache.object(forKey: identifier as NSNumber)
//	}
//
//	/**
//		Cancels any enqueued asychronous fetches for a specified `Int`. Completion
//		handlers are not called if a fetch is canceled.
//
//		- Parameter identifier: The `Int` to cancel fetches for.
//	*/
//	func cancelFetch(_ identifier: Int) {
//		serialAccessQueue.addOperation {
//			self.fetchQueue.isSuspended = true
//			defer {
//				self.fetchQueue.isSuspended = false
//			}
//
//			self.operation(for: identifier)?.cancel()
//			self.completionHandlers[identifier] = nil
//		}
//	}
// }
//
// // MARK: Convenience
// extension SeasonAsyncFetcher {
//	/**
//		Begins fetching data for the provided `identifier` invoking the associated
//		completion handler when complete.
//
//		- Parameter identifier: The `Int` to fetch data for.
//	*/
//	private func fetchData(for identifier: Int) {
//		// If a request has already been made for the object, do nothing more.
//		guard operation(for: identifier) == nil else { return }
//
//		if let data = fetchedData(for: identifier) {
//			// The object has already been cached; call the completion handler with that object.
//			self.invokeCompletionHandlers(for: identifier, with: data)
//		} else {
//			// Enqueue a request for the object.
//			let operation = SeasonAsyncFetcherOperation(identifier: identifier)
//
//			// Set the operation's completion block to cache the fetched object and call the associated completion blocks.
//			operation.completionBlock = { [weak operation] in
//				guard let fetchedData = operation?.fetchedData else { return }
//				self.cache.setObject(fetchedData, forKey: identifier as NSNumber)
//
//				self.serialAccessQueue.addOperation {
//					self.invokeCompletionHandlers(for: identifier, with: fetchedData)
//				}
//			}
//
//			fetchQueue.addOperation(operation)
//		}
//	}
//
//	/**
//		Returns any enqueued `ObjectFetcherOperation` for a specified `Int`.
//
//		- Parameter identifier: The `Int` of the operation to return.
//		- Returns: The enqueued `ObjectFetcherOperation` or nil.
//	*/
//	private func operation(for identifier: Int) -> SeasonAsyncFetcherOperation? {
//		for case let fetchOperation as SeasonAsyncFetcherOperation in fetchQueue.operations
//		where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
//			return fetchOperation
//		}
//
//		return nil
//	}
//
//	/**
//		Invokes any completion handlers for a specified `Int`. Once called,
//		the stored array of completion handlers for the `Int` is cleared.
//
//		- Parameters:
//		- identifier: The `Int` of the completion handlers to call.
//		- object: The fetched object to pass when calling a completion handler.
//	*/
//	private func invokeCompletionHandlers(for identifier: Int, with fetchedData: Season) {
//		let completionHandlers = self.completionHandlers[identifier, default: []]
//		self.completionHandlers[identifier] = nil
//
//		for completionHandler in completionHandlers {
//			completionHandler(fetchedData)
//		}
//	}
// }
