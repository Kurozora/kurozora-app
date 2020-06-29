//
//  KurozoraKit+Characters.swift
//  Alamofire
//
//  Created by Khoren Katklian on 27/06/2020.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the list of characters.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCharacters(completion completionHandler: @escaping (_ result: Result<[CharacterElement], KKError>) -> Void) {
		let characters = self.kurozoraKitEndpoints.characters
		let request: APIRequest<Characters, KKError> = tron.swiftyJSON.request(characters)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { characters in
			completionHandler(.success(characters.characters ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get characters list 😔", subTitle: error.message)
			}
			print("Received get characters error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the character details for the given character id.

		- Parameter characterID: The id of the character for which the details should be fetched.
		- Parameter includesShows: Set to `true` to include show data.
		- Parameter limit: The number of shows to get. Set to `nil` to get all shows.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forCharacterID characterID: Int, includesShows: Bool? = nil, limit: Int? = nil, completion completionHandler: @escaping (_ result: Result<CharacterElement, KKError>) -> Void) {
		let character = self.kurozoraKitEndpoints.character.replacingOccurrences(of: "?", with: "\(characterID)")
		let request: APIRequest<Characters, KKError> = tron.swiftyJSON.request(character)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if includesShows != nil, let includesShows = includesShows {
			request.parameters["anime"] = includesShows ? 1 : 0
		}
		if limit != nil, let limit = limit {
			request.parameters["limit"] = limit
		}

		request.method = .get
		request.perform(withSuccess: { characters in
			completionHandler(.success(characters.characterElement ?? CharacterElement()))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get character details 😔", subTitle: error.message)
			}
			print("Received get character details error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
