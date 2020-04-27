//
//  ForumsThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single forums thread, such as the thred's last page number, and collection of threads it contains.
*/
public class ForumsThread: JSONDecodable {
	// MARK: - Properties
	/// The current page number of the forums thread.
	public let currentPage: Int?

	/// The last page of the forums thread.
	public let lastPage: Int?

	/// The thread object.
	public let thread: ForumsThreadElement?

	/// The collection of threads in the forums thread.
	public let threads: [ForumsThreadElement]?

	// MARK: - Initializers
	/// Initialize an empty instance of `ForumThreads`.
	internal init() {
		self.currentPage = nil
		self.lastPage = nil
		self.thread = nil
		self.threads = nil
	}

	required public init(json: JSON) throws {
		self.currentPage = json["page"].intValue
		self.lastPage = json["last_page"].intValue
		self.thread = try ForumsThreadElement(json: json["thread"])

		var threads = [ForumsThreadElement]()
		let threadsArray = json["threads"].arrayValue
		for thread in threadsArray {
			if let threadsElement = try? ForumsThreadElement(json: thread) {
				threads.append(threadsElement)
			}
		}
		self.threads = threads
	}
}
