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

	fileprivate let headers = [
		"Content-Type": "application/x-www-form-urlencoded"
	]
	fileprivate let authHeaders = [
		"Content-Type": "application/x-www-form-urlencoded",
		"kuro-auth" : User.authToken()
	]

	static let shared = Service()
    
// MARK: - User
// All user related endpoints
    /// Reset password request
    func resetPassword(_ email: String?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
		guard let email = email else { return }

		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("users/reset-password")
        request.headers = headers
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

	/// Get a list of sessions for the current user
	func getSessions(withSuccess successHandler:@escaping (Session?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let userID = User.currentID() else { return }

		let request : APIRequest<Session,JSONError> = tron.swiftyJSON.request("users/\(userID)/sessions")
		request.headers = authHeaders
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { session in
			if let success = session.success {
				if success {
					successHandler(session)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Error getting session", subTitle: "There was an error while getting your sessions list. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received get session error: \(error)")
		})
	}

	/// Get a list of items for the current user's library
	func getLibrary(withStatus status: String?, withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let status = status else { return }
		guard let userID = User.currentID() else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = authHeaders
		request.authorizationRequirement = .required
		request.method = .get
		request.parameters = [
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

	/// Add an item to the current user's library
	func addToLibrary(withStatus status: String?, showId: Int?,withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let status = status else { return }
		guard let showId = showId else { return }
		guard let userID = User.currentID() else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = authHeaders
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
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

	/// Remove an item from the current user's library
	func removeFromLibrary(withID showID: Int?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let showID = showID else { return }
		guard let userID = User.currentID() else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("users/\(userID)/library/delete")
		request.headers = authHeaders
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"anime_id": showID
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
    
    /// User a user's profile details
    func getUserProfile(_ userID:Int?, withSuccess successHandler:@escaping (User?) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
		guard let userID = userID else { return }

        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("users/\(userID)/profile")
        request.headers = headers
        request.authorizationRequirement = .required
        request.method = .get
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

	/// Get a list of notifications for the current user
	func getNotifications(withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let userID = User.currentID() else { return }

		let request : APIRequest<UserNotification,JSONError> = tron.swiftyJSON.request("users/\(userID)/notifications")
		request.headers = authHeaders
		request.authorizationRequirement = .required
		request.method = .get
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

// MARK: - Sessions
// All sessions related endpoints
	/// Create a new session a.k.a login
	func login(_ username:String, _ password:String, _ device:String, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("sessions")

		try? GlobalVariables().KDefaults.set(username, key: "username")

		request.headers = headers
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
					if let authToken = user.authToken {
						try? GlobalVariables().KDefaults.set(authToken, key: "auth_token")
					}

					if let sessionID = user.sessionID {
						try? GlobalVariables().KDefaults.set(String(sessionID), key: "session_id")
					}

					if let userId = user.id {
						try? GlobalVariables().KDefaults.set(String(userId), key: "user_id")
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
    
    /// Check if the session is valid
    func validateSession(withSuccess successHandler:@escaping (Bool) -> Void) {
        if User.authToken() != nil && User.currentID() != nil {
			guard let sessionID = try? GlobalVariables().KDefaults.getString("session_id").unwrapped(or: "") else { return }
			let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/validate")

            request.headers = authHeaders
            request.authorizationRequirement = .required
            request.method = .post
            
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
    
    /// Delete a session according to its ID
    func deleteSession(_ id: Int?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let sessionID = id else { return }

        let request : APIRequest<Session,JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")

        request.headers = authHeaders
        request.authorizationRequirement = .required
        request.method = .post
        
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

	/// Logout the current user by deleting the current session
	func logout(withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void)  {
		guard let sessionID = User.currentSessionID() else { return }

		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")

		request.headers = authHeaders
		request.authorizationRequirement = .required
		request.method = .post

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
			SCLAlertView().showError("Error logging out", subTitle: "There was an error while logging out of your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received logout error: \(error)")
		})
	}
    
//    MARK: - Settings
    
    /// Legal
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
    
// MARK: - Show
// All show related endpoints
    /// Get explore page content
    func getExplore(withSuccess successHandler: @escaping (Show) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        let request: APIRequest<Show,JSONError> = tron.swiftyJSON.request("anime")
        request.headers = headers
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
    
    /// Get show detail
    func getDetailsFor(_ showID: Int?, completionHandler: @escaping (ShowDetails) -> Void) {
        guard let showID = showID else { return }

        let request : APIRequest<ShowDetails,JSONError> = tron.swiftyJSON.request("anime/\(showID)")
        request.headers = authHeaders
        request.authorizationRequirement = .required
        request.method = .get
        request.perform(withSuccess: { showDetails in
            DispatchQueue.main.async {
                completionHandler(showDetails)
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received get details error: \(error)")
        })
    }
    
    /// Get cast details for a show
    func getCastFor(_ showID: Int?, withSuccess successHandler:@escaping (CastDetails, [JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        guard let showID = showID else { return }
        
        let request: APIRequest<CastDetails,JSONError> = tron.swiftyJSON.request("anime/\(showID)/actors")
        request.headers = headers
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
            
            print("Received get cast error: \(error)")
        })
    }
    
    /// Get season details for a show
    func getSeasonFor(_ showID: Int?, withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        guard let showID = showID else { return }

        let request : APIRequest<Seasons,JSONError> = tron.swiftyJSON.request("anime/\(showID)/seasons")
        request.headers = headers
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
    
    /// Get episode details for a show season
    func getEpisodesFor(_ showID: Int?, _ seasonID: Int?, withSuccess successHandler:@escaping (Episodes?) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
        guard let showID = showID else { return }
        guard let seasonID = seasonID else { return }
        
        let request : APIRequest<Episodes,JSONError> = tron.swiftyJSON.request("anime/\(showID)/seasons/\(seasonID)/episodes")
        request.headers = headers
        request.authorizationRequirement = .required
        request.method = .get
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
    
    /// Rate a show
    func rate(showID: Int?, score: Double?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void) {
		guard let rating = score else { return }
        guard let showID = showID else { return }
        
        let request: APIRequest<User,JSONError> = tron.swiftyJSON.request("anime/\(showID)/rate")
        request.headers = authHeaders
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "rating": rating
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
    
// MARK: - Forums
// All forum related endpoints
    /// Get forum sections
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

	/// Get forum threads
	func getForumThreads(forSection sectionId: Int?, order: String?, page: Int?, withSuccess successHandler:@escaping ([JSON]?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let sectionId = sectionId else { return }
		guard let order = order else { return }
		guard let page = page else { return }

		let request : APIRequest<ForumThreads,JSONError> = tron.swiftyJSON.request("forum/get_threads")

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

		request.perform(withSuccess: { threads in
			if let success = threads.success {
				if success {
					if let threads = threads.threads, threads != [] {
						successHandler(threads)
					}
				} else {
					if let responseMessage = threads.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Error getting threads", subTitle: "There was an error while getting forum threads. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received get forum threads error: \(error)")
		})
	}

	/// Get forum thread
	func getForumThread(forThread threadId: Int?, withSuccess successHandler:@escaping (ForumThread?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let threadId = threadId else { return }

		let request : APIRequest<ForumThread,JSONError> = tron.swiftyJSON.request("forum/get_thread")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"thread_id": threadId,
		]

		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success {
						successHandler(thread)
				} else {
					if let responseMessage = thread.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Error getting thread", subTitle: "There was an error while getting this thread. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received get thread error: \(error)")
		})
	}

	/// Upvote or downvote a thread
	func voteFor(thread threadId: Int?, vote: Int?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let threadId = threadId else { return }
		guard let vote = vote else { return }
		guard let userId = User.currentID() else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }

		let request : APIRequest<VoteThread,JSONError> = tron.swiftyJSON.request("forum/vote_thread")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"user_id": userId,
			"session_secret": sessionSecret!,
			"thread_id": threadId,
			"vote": vote,
		]

		request.perform(withSuccess: { vote in
			if let success = vote.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Error voting", subTitle: "There was an error while voting on this threads. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received vote thread error: \(error)")
		})
	}

	/// Post thread
	func postThread(withTitle title: String?, content: String?, forSection sectionId: Int?, withSuccess successHandler:@escaping (Bool) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let title = title else { return }
		guard let content = content else { return }
		guard let sectionId = sectionId else { return }
		guard let userId = User.currentID() else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }

		let request : APIRequest<ThreadPost,JSONError> = tron.swiftyJSON.request("forum/post_thread")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"user_id": userId,
			"session_secret": sessionSecret!,
			"title": title,
			"content": content,
			"section_id": sectionId,
		]

		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success {
					successHandler(success)
				} else {
					if let responseMessage = thread.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Error submitting your thread", subTitle: "There was an error while posting your thread to this section. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received post thread error: \(error)")
		})
	}

	/// Post reply
	func postReply(withComment comment: String?, forThread threadId: Int?, withSuccess successHandler:@escaping (Int?) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		guard let comment = comment else { return }
		guard let threadId = threadId else { return }
		guard let userId = User.currentID() else { return }
		guard let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret") else { return }

		let request : APIRequest<ThreadReply,JSONError> = tron.swiftyJSON.request("forum/post_reply")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded"
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"user_id": userId,
			"session_secret": sessionSecret!,
			"content": comment,
			"thread_id": threadId,
		]

		request.perform(withSuccess: { reply in
			if let success = reply.success {
				if success {
					if let replyId = reply.replyId, replyId != 0 {
						successHandler(replyId)
					}
				} else {
					if let responseMessage = reply.message {
						failureHandler(responseMessage)
					}
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Error posting your comment", subTitle: "There was an error while posting your comment to this threads. If this error persists, check out our Twitter account @KurozoraApp for more information!")

			print("Received post reply error: \(error)")
		})
	}
    
	/// Throw json error
    class JSONError: JSONDecodable {
        required init(json: JSON) throws {
            print("JSON ERROR \(json)")
        }
    }

	//    MARK: - Theme Store

	/// Get Themes
	func getThemes(withSuccess successHandler:@escaping ([JSON]) -> Void, andFailure failureHandler:@escaping (String) -> Void){
		//        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("user/login")
		//
		//        let delSessionId = id
		//        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
		//        let userId = User.currentID()
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
}
