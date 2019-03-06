//
//  KurozoraThemes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftTheme
import TRON
import Alamofire

let cachesURL = FileManager.SearchPathDirectory.cachesDirectory
let libraryURL = FileManager.SearchPathDomainMask.userDomainMask
let libraryDirectoryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

enum KurozoraThemes: Int {
	case `default` 	= 0
	case day 		= 1
	case night 		= 2
	case other		= 3

	static var current = KurozoraThemes.default
	static var before  = KurozoraThemes.default
	static let tron = TRON(baseURL: "", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])
	static let themesDirectoryUrl: URL = libraryDirectoryUrl.appendingPathComponent("Themes/")

	// MARK: - Switch Theme
	static func switchTo(_ theme: KurozoraThemes) {
		before  = current
		current = theme

		switch theme {
			case .default:
				ThemeManager.setTheme(plistName: "Default", path: .mainBundle)
				changeIcon(to: nil)
				GlobalVariables().KUserDefaults?.set("Default", forKey: "currentTheme")
			case .day:
				ThemeManager.setTheme(plistName: "Day", path: .mainBundle)
				changeIcon(to: "Day")
				GlobalVariables().KUserDefaults?.set("Day", forKey: "currentTheme")
			case .night:
				ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
				changeIcon(to: "Night")
				GlobalVariables().KUserDefaults?.set("Night", forKey: "currentTheme")
			case .other: break
		}
	}

	static func switchTo(theme themeID: Int) {
		before  = current
		current = .other

		ThemeManager.setTheme(plistName: "theme-\(themeID)", path: .sandbox(themesDirectoryUrl))
		GlobalVariables().KUserDefaults?.set("\(themeID)", forKey: "currentTheme")
	}

	static func switchToNext(theme themeID: Int) {
		var next = current.rawValue + 1
		var max  = 1 // without Night

		if themeExist(for: themeID) { max += 1 }
		if next >= max { next = 0 }

		switchTo(KurozoraThemes(rawValue: next)!)
	}

	// MARK: - Switch Night
	static func switchNight(_ isToNight: Bool) {
		switchTo(isToNight ? .night : before)
	}

	static func isNight() -> Bool {
		return current == .night
	}

	// MARK: - Download
	static func downloadThemeTask(for theme: ThemesElement?, _ handler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let urlString = theme?.downloadLink, urlString != "" else {
			DispatchQueue.main.async {
				handler(false)
			}
			return
		}
//		guard let themeName = theme?.name else {
//			DispatchQueue.main.async {
//				handler(false)
//			}
//			return
//		}
		guard let themeID = theme?.id else {
			DispatchQueue.main.async {
				handler(false)
			}
			return
		}

		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig)
		let request = try! URLRequest(url: urlString, method: .get)

		let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
			if let tempLocalUrl = tempLocalUrl, error == nil {
				// Reponse code
				if let statusCode = (response as? HTTPURLResponse)?.statusCode {
					print("Success: \(statusCode)")
				}

				// Create Themes folder if it doesn't exist
				if !directoryExist(atPath: themesDirectoryUrl.path) {
					do {
						try FileManager.default.createDirectory(atPath: libraryDirectoryUrl.appendingPathComponent("Themes/").path, withIntermediateDirectories: true, attributes: nil)
					} catch (let createError) {
						DispatchQueue.main.async {
							handler(themeExist(for: themeID))
						}
						print("error creating directory \(libraryDirectoryUrl) : \(createError)")
					}
				}

				// Move file to Themes folder
				do {
					try FileManager.default.copyItem(at: tempLocalUrl, to: themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist"))
					DispatchQueue.main.async {
						handler(themeExist(for: themeID))
					}
				} catch (let writeError) {
					DispatchQueue.main.async {
						handler(themeExist(for: themeID))
					}
					print("error writing file \(themesDirectoryUrl) : \(writeError)")
				}
			} else {
				print("Failure: \(String(describing: error?.localizedDescription))")
				DispatchQueue.main.async {
					handler(themeExist(for: themeID))
				}
			}
		}
		task.resume()
	}

	static func directoryExist(atPath path: String) -> Bool {
		var isDirectory = ObjCBool(true)
		let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		return exists && isDirectory.boolValue
	}

	static func themeExist(for themeID: Int) -> Bool {
		let themeFileDirectoryUrl: URL = themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist")
		return FileManager.default.fileExists(atPath: themeFileDirectoryUrl.path)
	}

	static func changeIcon(to iconName: String?) {
		if #available(iOS 10.3, *) {
			// Check if app supports alternate icons
			guard UIApplication.shared.supportsAlternateIcons else { return }

			// Set alternate icon
			UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in

				if let error = error {
					print("App icon failed to change due to \(error.localizedDescription)")
				} else {
					print("App icon changed successfully")
				}
			})
		} else {
			// Fallback on earlier versions
		}
	}
}
