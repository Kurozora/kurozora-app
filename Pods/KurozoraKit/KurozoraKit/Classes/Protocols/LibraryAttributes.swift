//
//  LibraryAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/// A root object that stores information about a library update resource.
public typealias LibraryUpdate = LibraryAttributes

/// A root object that stores information about a single library item, such as the item's rating, favorite status, and library status.
public struct LibraryAttributes: Codable {
	/// The rating given to the item.
	public var rating: Double?

	/// The review given to the item.
	public var review: String?

	/// Whether the item is favorited.
	public var isFavorited: Bool?

	/// The favorite status of the item.
	public var _favoriteStatus: FavoriteStatus?

	/// Whether the reminder for the item is turned on.
	public var isReminded: Bool?

	/// The reminder status of the item.
	public var _reminderStatus: ReminderStatus?

	/// Whether the item is marked as hidden.
	public var isHidden: Bool?

	/// The hidden status of the item.
	public var _hiddenStatus: HiddenStatus?

	/// The library status of the item.
	public var status: KKLibrary.Status?

	/// The rewatch count of the item.
	public var rewathCount: Int?
}

// MARK: - Helpers
extension LibraryAttributes {
	// MARK: - Properties
	/// The favorite status of the library item.
	public var favoriteStatus: FavoriteStatus {
		get {
			return self._favoriteStatus ?? FavoriteStatus(self.isFavorited)
		}
		set {
			self._favoriteStatus = newValue
		}
	}

	/// The reminder status of the library item.
	public var reminderStatus: ReminderStatus {
		get {
			return self._reminderStatus ?? ReminderStatus(self.isReminded)
		}
		set {
			self._reminderStatus = newValue
		}
	}

	/// The hidden status of the library item.
	public var hiddenStatus: HiddenStatus {
		get {
			return self.hiddenStatus ?? HiddenStatus(self.isHidden)
		}
		set {
			self._hiddenStatus = newValue
		}
	}

	// MARK: - Functions
	/// Updates the attributes with the given `LibraryUpdate` object.
	///
	/// - Parameter libraryUpdate: The `LibraryUpdate` object used to update the attributes.
	public mutating func update(using libraryUpdate: LibraryUpdate) {
		self.favoriteStatus = libraryUpdate.favoriteStatus
		self.reminderStatus = libraryUpdate.reminderStatus
		self.status = libraryUpdate.status
	}

	/// Returns a copy of the object with the updated attributes from the given `LibraryUpdate` object.
	///
	/// - Parameter libraryUpdate: The `LibraryUpdate` object used to update the attributes.
	///
	/// - Returns: a copy of the object with the updated attributes from the given `LibraryUpdate` object.
	public mutating func updated(using libraryUpdate: LibraryUpdate) -> Self {
		var libraryAttributes = self
		libraryAttributes.favoriteStatus = libraryUpdate.favoriteStatus
		libraryAttributes.reminderStatus = libraryUpdate.reminderStatus
		libraryAttributes.status = libraryUpdate.status
		return libraryAttributes
	}
}
