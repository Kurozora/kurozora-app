//
//  Characters.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/06/2020.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of characters.
*/
public class Characters: JSONDecodable {
	// MARK: - Properties
	/// The single character object.
	public let characterElement: CharacterElement?

	/// The collection of characters.
    public let characters: [CharacterElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
		self.characterElement = try? CharacterElement(json: json["character"])
        var characters = [CharacterElement]()

		let charactersArray = json["characters"].arrayValue
		for characterItem in charactersArray {
			if let characterElement = try? CharacterElement(json: characterItem) {
				characters.append(characterElement)
			}
		}

		self.characters = characters
    }
}
