//
//  StudioAttributesMedia.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/12/2020.
//

extension Studio.Attributes {
	/**
		A root object that stores information about a media resource.
	*/
	public struct Media: Codable {
		// MARK: - Properties
		/// The url of the media.
		public let url: String
	}
}
