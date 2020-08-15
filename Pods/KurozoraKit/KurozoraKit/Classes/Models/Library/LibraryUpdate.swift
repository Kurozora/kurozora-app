//
//  LibraryUpdate.swift
//  Alamofire
//
//  Created by Khoren Katklian on 14/08/2020.
//

/**
	A root object that stores information about a library update resource.
*/
public struct LibraryUpdate: LibraryAttributes {
	// MARK: - Properties
	public var givenRating: Double?

	public var libraryStatus: KKLibrary.Status?

	public var isFavorited: Bool?

	public var _favoriteStatus: FavoriteStatus?

	public var isReminded: Bool?

	public var _reminderStatus: ReminderStatus?
}
