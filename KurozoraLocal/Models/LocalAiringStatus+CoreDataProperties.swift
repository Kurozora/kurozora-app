//
//  LocalAiringStatus+CoreDataProperties.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

nonisolated extension LocalAiringStatus {
	@nonobjc class func fetchRequest() -> NSFetchRequest<LocalAiringStatus> {
		return NSFetchRequest<LocalAiringStatus>(entityName: "LocalAiringStatus")
	}

	/// The name of the airing or publishing status.
	@NSManaged var name: String

	/// The color of the status as a hex string.
	@NSManaged var colorHex: String
}
