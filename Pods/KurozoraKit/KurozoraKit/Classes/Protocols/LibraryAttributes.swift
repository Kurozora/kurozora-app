//
//  LibraryAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/// A type that holds the value of library attributes.
///
/// Use the `LibraryAttributes` protocol to provide a library attributes to a class or value type. For example, you could define a Show type with a library status property that is stable across your app and your app’s database storage. You could use the library status property to identify a particular show's library status even if other data fields change, such as the show's title.
public protocol LibraryAttributes: Codable {
	/// The rating given to the item.
	var givenRating: Double? { get set }

	/// The review given to the item.
	var givenReview: String? { get set }

	/// Whether the item is favorited.
	var isFavorited: Bool? { get }

	/// The favorite status of the item.
	var _favoriteStatus: FavoriteStatus? { get set }

	/// Whether the reminder for the item is turned on.
	var isReminded: Bool? { get set }

	/// The reminder status of the item.
	var _reminderStatus: ReminderStatus? { get set }

	/// The library status of the item.
	var libraryStatus: KKLibrary.Status? { get set }
}

// MARK: - Helpers
extension LibraryAttributes {
	// MARK: - Properties
	/// The favorite status of the show.
	public var favoriteStatus: FavoriteStatus {
		get {
			return self._favoriteStatus ?? FavoriteStatus(isFavorited)
		}
		set {
			self._favoriteStatus = newValue
		}
	}

	/// The reminder status of the show.
	public var reminderStatus: ReminderStatus {
		get {
			return self._reminderStatus ?? ReminderStatus(isReminded)
		}
		set {
			self._reminderStatus = newValue
		}
	}

	// MARK: - Functions
	/// Updates the attributes with the given `LibraryUpdate` object.
	///
	/// - Parameter libraryUpdate: The `LibraryUpdate` object used to update the attributes.
	public mutating func update(using libraryUpdate: LibraryUpdate) {
		self.favoriteStatus = libraryUpdate.favoriteStatus
		self.reminderStatus = libraryUpdate.reminderStatus
		self.libraryStatus = libraryUpdate.libraryStatus
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
		libraryAttributes.libraryStatus = libraryUpdate.libraryStatus
		return libraryAttributes
	}
}
