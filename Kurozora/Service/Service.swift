//
//  Service.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import TRON
import SwiftyJSON
import SCLAlertView

struct Service {
    let tron = TRON(baseURL: "https://kurozora.app/api/v1/")
    static let shared = Service()
    
//    MARK: - User

    // Login user
    func login(_ username:String, _ password:String, _ device:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/login")

        try? GlobalVariables().KDefaults.set(username, key: "username")

        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "username": username,
            "password": password,
            "device": device
        ]

        request.perform(withSuccess: { user in
            if let success = user.success {
                if success {
                    if let userId = user.id {
                        try? GlobalVariables().KDefaults.set(String(userId), key: "user_id")
                    }
                    
                    if let sessionSecret = user.sessionSecret {
                        try? GlobalVariables().KDefaults.set(sessionSecret, key: "session_secret")
                    }

					if let sessionId = user.sessionId {
						try? GlobalVariables().KDefaults.set(String(sessionId), key: "session_id")
					}
                    
                    if let role = user.role {
                        try? GlobalVariables().KDefaults.set(String(role), key: "user_role")
                    }
                    successHandler(success)
                } else {
                    if let responseMessage = user.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            failureHandler("There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received login error: \(error)")
        })
    }
    
    // Reset password
    func resetPassword(_ email:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/reset_password")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "email": email,
        ]
        
        request.perform(withSuccess: { reset in
            if let success = reset.success {
                if success {
                    successHandler(success)
                } else {
                    if let responseMessage = reset.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            failureHandler("There was an error while requesting the reset link. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received reset password error: \(error)")
        })
    }
    
    // Logout user
    func logout(withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }

		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/logout")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
			"user_id": userId!,
            "session_secret": sessionSecret!
        ]
        
        request.perform(withSuccess: { user in
             if let success = user.success {
                if success {
                    WorkflowController.logoutUser()
                    successHandler(success)
                } else {
                    if let responseMessage = user.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error logging out", subTitle: "There was an error while logging out to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received logout error: \(error)")
        })
    }
    
    // User details
    func getUserProfile(_ userId:Int?, withSuccess successHandler:@escaping (User?) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
		guard let id = userId else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }

        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/\(id)/profile")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "user_id": userId!,
            "session_secret": sessionSecret!
        ]
        
        request.perform(withSuccess: { userProfile in
            if let success = userProfile.success {
                if success {
                    successHandler(userProfile)
                } else {
                    if let responseMessage = userProfile.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error getting user", subTitle: "There was an error while getting user details. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received user profile error: \(error)")
        })
    }
    
//    MARK: - Sessions
    
    // Validate session
    func validateSession(withSuccess successHandler:@escaping (Bool) -> Void) {
        if User.currentSessionSecret() != nil && User.currentId() != nil {
			guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }
			guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }

			let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("session/validate")

            request.headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            request.authorizationRequirement = .required
            request.method = .post
            request.parameters = [
				"user_id": userId!,
				"session_secret": sessionSecret!
            ]
            
            request.perform(withSuccess: { user in
                if let success = user.success {
                    if success {
                        successHandler(success)
                    } else {
                        successHandler(success)
                    }
                }
            }, failure: { error in
                SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                
                print("Received validate session error: \(error)")
            })
        } else {
            successHandler(false)
        }
    }
    
    // Get sessions
    func getSessions(withSuccess successHandler:@escaping (Session?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }

        let request : APIRequest<Session,JSONError> = tron.swiftyJSON.request("user/get_sessions")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
			"user_id": userId!,
			"session_secret": sessionSecret!
        ]
        
        request.perform(withSuccess: { session in
            if let success = session.success {
                if success {
                    successHandler(session)
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error logging in", subTitle: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get session error: \(error)")
        })
    }
    
    // Delete session
    func deleteSession(_ id: Int, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		let delSessionId = id
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }

        let request : APIRequest<Session,JSONError> = tron.swiftyJSON.request("user/delete_session")

        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!,
            "del_session_id": delSessionId
        ]
        
        request.perform(withSuccess: { session in
            if let success = session.success {
                if success {
                    successHandler(success)
                } else {
                    if let responseMessage = session.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received delete session error: \(error)")
        })
    }
    
//    MARK: - Theme Store
    
    // Get Themes
    func getThemes(withSuccess successHandler:@escaping ([JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void){
//        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/login")
//
//        let delSessionId = id
//        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
//        let userId = try? GlobalVariables().KDefaults.getString("user_id")!
//
//        request.headers = [
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
//        request.authorizationRequirement = .required
//        request.method = .post
//        request.parameters = [
//            "session_secret": sessionSecret!,
//            "user_id": userId!,
//            "del_session_id": delSessionId
//        ]
//
//        request.perform(withSuccess: { user in
//            if let success = user.success {
//                if success {
//                    successHandler(responseThemes)
//                } else {
//                    failureHandler("Themes aren't available at this time!")
//                }
//            }
//        }, failure: { error in
//            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
//
//            print("Received delete session error: \(error)")
//        })
//        let endpoint = "https://api.jsonbin.io/b/5b758d1be013915146d55c8f"
//
//        Alamofire.request(endpoint, method: .get /*, parameters: parameters, headers: headers*/)
//            .responseJSON { response in
//                switch response.result {
//                case .success/*(let data)*/:
//                    if response.result.value != nil{
//                        let swiftyJsonVar = JSON(response.result.value!)
//
//                        let responseSuccess = swiftyJsonVar["success"]
//                        let responseMessage = swiftyJsonVar["error_message"]
//                        let responseThemes = swiftyJsonVar["themes"].array!
//
//                        if responseSuccess.boolValue {
//                            if responseThemes.isEmpty {
//                                failureHandler("Themes aren't available at this time!")
//                            }else{
//                                successHandler(responseThemes)
//                            }
//                        }else{
//                            failureHandler(responseMessage.stringValue)
//                        }
//                    }
//                case .failure(let err):
//                    NSLog("------------------DATA START-------------------")
//                    NSLog("Get Theme Response String: \(String(describing: err))")
//                    failureHandler("There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
//                    NSLog("------------------DATA END-------------------")
//                }
//        }
    }
    
//    MARK: - Settings
    
    // Legal
    func getPrivacyPolicy(withSuccess successHandler:@escaping (Privacy?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        let request: APIRequest<Privacy,JSONError> = tron.swiftyJSON.request("misc/get_privacy_policy")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.method = .get
        
        request.perform(withSuccess: { privacyPolicy in
            if let success = privacyPolicy.success {
                if success {
                    successHandler(privacyPolicy)
                } else {
                    if let responseMessage = privacyPolicy.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received privacy policy error: \(error)")
        })
    }
    
//    MARK: - Show
    
    // Get explore
    func getExplore(withSuccess successHandler: @escaping (Show) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        let request: APIRequest<Show,JSONError> = tron.swiftyJSON.request("anime/explore")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.method = .get
        
        request.perform(withSuccess: { show in
            if let success = show.success {
                if success {
                    if let category = show.categories, category != [] {
                        successHandler(show)
                    }
                } else {
                    if let responseMessage = show.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received explore error: \(error)")
        })
    }
    
    // Get show detail
    func getDetailsFor(_ showId: Int?, completionHandler: @escaping (ShowDetails) -> Void) {
        guard let id = showId else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }
        
        let request : APIRequest<ShowDetails,JSONError> = tron.swiftyJSON.request("anime/\(id)/details")

        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!
        ]
        
        request.perform(withSuccess: { showDetails in
            DispatchQueue.main.async {
                completionHandler(showDetails)
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get details error: \(error)")
        })
    }
    
    // Get cast
    func getCastFor(_ id: Int?, withSuccess successHandler:@escaping (CastDetails, [JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        guard let id = id else { return }
        
        let request: APIRequest<CastDetails,JSONError> = tron.swiftyJSON.request("anime/\(id)/actors")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.method = .get
        
        request.perform(withSuccess: { cast in
            if let success = cast.success {
                if success {
                    guard let castActors = cast.actors else {return}
                    
                    if let castActorsCount = cast.actors?.count, castActorsCount > 0 {
                        successHandler(cast, castActors)
                    }
                } else {
                    if let responseMessage = cast.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received cast error: \(error)")
        })
    }
    
    // Show season
    func getSeasonFor(_ id: Int?, withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        guard let id = id else { return }

        let request : APIRequest<Seasons,JSONError> = tron.swiftyJSON.request("anime/\(id)/seasons")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .get
        
        request.perform(withSuccess: { seasons in
            if let success = seasons.success {
                if success {
                    if let seasons = seasons.seasons, seasons != [] {
                        successHandler(seasons)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error getting seasons", subTitle: "There was an error while getting show seaosns. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get show seasons error: \(error)")
        })
    }
    
    // Show episodes
    func getEpisodesFor(_ id: Int?, _ seasonId:Int?, withSuccess successHandler:@escaping (Episodes?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        guard let id = id else { return }
        guard let seasonId = seasonId else { return }
        
        let request : APIRequest<Episodes,JSONError> = tron.swiftyJSON.request("anime/\(id)/episodes")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .get
        request.parameters = [
            "season": seasonId
        ]
        
        request.perform(withSuccess: { episodes in
            if let success = episodes.success {
                if success {
                    if let episodesExist = episodes.episodes, episodesExist != [] {
                        successHandler(episodes)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Error getting seasons", subTitle: "There was an error while getting show seaosns. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get show seasons error: \(error)")
        })
    }
    
    // Rate show
    func rate(showId: Int?, score: Double?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        let rating = score
        guard let id = showId else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }
        
        let request: APIRequest<User,JSONError> = tron.swiftyJSON.request("anime/\(id)/rate")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!,
            "rating": rating!
        ]
        
        request.perform(withSuccess: { user in
            if let success = user.success {
                if success {
                    successHandler(success)
                } else {
                    if let responseMessage = user.message {
                        failureHandler(responseMessage)
                    }
                }
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received rating error: \(error)")
        })
    }

//	MARK: - Library

	// Get library
	func getLibraryFor(status: String?, withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let status = status else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("user/get_library")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"session_secret": sessionSecret!,
			"user_id": userId!,
			"status": status
		]

		request.perform(withSuccess: { library in
			if let success = library.success {
				if success {
					if let library = library.library, library != [] {
						successHandler(library)
					}
				} else {
					if let responseMessage = library.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received get library error: \(error)")
		})
	}

	// Add to library
	func addToLibraryWith(status: String?, showId: Int?,withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let status = status else { return }
		guard let showId = showId else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("user/add_library")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"session_secret": sessionSecret!,
			"user_id": userId!,
			"status": status,
			"anime_id": showId
		]

		request.perform(withSuccess: { library in
			if let success = library.success {
				if success {
					successHandler(success)
				} else {
					if let responseMessage = library.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received add library error: \(error)")
		})
	}

	// Remove from library
	func removeFromLibraryWith(showId: Int?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let showId = showId else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("user/remove_library")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"session_secret": sessionSecret!,
			"user_id": userId!,
			"anime_id": showId
		]

		request.perform(withSuccess: { library in
			if let success = library.success {
				if success {
					successHandler(success)
				} else {
					if let responseMessage = library.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received remove library error: \(error)")
		})
	}

//  MARK: - Notifications
    
    // Get notifications
    func getNotifications(withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let userId = try? GlobalVariables().KDefaults.getString("user_id") else {return}
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else {return}

        let request : APIRequest<UserNotification,JSONError> = tron.swiftyJSON.request("user/get_notifications")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "user_id": userId!,
            "session_secret": sessionSecret!
        ]
        
        request.perform(withSuccess: { notification in
            if let success = notification.success {
                if success {
                    if let notifications = notification.notifications, notifications != [] {
                        successHandler(notifications)
                    }
				} else {
					if let responseMessage = notification.message {
						failureHandler(responseMessage)
					}
				}
			}
        }, failure: { error in
            SCLAlertView().showError("Error getting notifications", subTitle: "There was an error while getting notifications. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get notifications error: \(error)")
        })
    }
    
//    MARK: - Forums
    
    // Get forum sections
    func getForumSections(withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
        let request : APIRequest<ForumSections,JSONError> = tron.swiftyJSON.request("forum/get_sections")
        
        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .get
        
        request.perform(withSuccess: { sections in
            if let success = sections.success {
                if success {
                    if let sections = sections.sections, sections != [] {
                        successHandler(sections)
                    }
				}  else {
					if let responseMessage = sections.message {
						failureHandler(responseMessage)
					}
				}
			}
        }, failure: { error in
            SCLAlertView().showError("Error getting sections", subTitle: "There was an error while getting forum sections. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get forum sections error: \(error)")
        })
    }

	// Get forum posts
	func getForumPosts(forSection sectionId: Int?, order: String?, page: Int?, withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let sectionId = sectionId else { return }
		guard let order = order else { return }
		guard let page = page else { return }

		let request : APIRequest<ForumPosts,JSONError> = tron.swiftyJSON.request("forum/get_posts")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"section_id": sectionId,
			"order": order,
			"page": page,
		]

		request.perform(withSuccess: { posts in
			if let success = posts.success {
				if success {
					if let posts = posts.posts, posts != [] {
						successHandler(posts)
					}
				} else {
					if let responseMessage = posts.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Error getting posts", subTitle: "There was an error while getting forum sections. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received get forum posts error: \(error)")
		})
	}
    
//    Throw json error
    class JSONError: JSONDecodable {
        required init(json: JSON) throws {
            print("JSON ERROR \(json)")
        }
    }
}
