//
//  KThemeStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftTheme
import TRON
import Alamofire
import Solar
import CoreLocation

let cachesURL = FileManager.SearchPathDirectory.cachesDirectory
let libraryURL = FileManager.SearchPathDomainMask.userDomainMask
let libraryDirectoryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

enum KThemeStyle: Int {
	case `default` 	= 0
	case day 		= 1
	case night 		= 2
	case other		= 3

	static var current: KThemeStyle = .default
	static var before: KThemeStyle = .default
	static let tron = TRON(baseURL: "", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])
	static let themesDirectoryUrl: URL = libraryDirectoryUrl.appendingPathComponent("Themes/")

	/// Return a string value for a given KThemeStyle
	func stringValue() -> String {
		switch self {
		case .default:
			return "Default"
		case .day:
			return "Day"
		case .night:
			return "Night"
		case .other:
			return "Other"
		}
	}

	/// Return a KThemeStyle value for a given string
	static func themeValue(from string: String) -> KThemeStyle {
		switch string {
		case "Default":
			return .default
		case "Day":
			return .day
		case "Night":
			return .night
		default: // a.k.a "Other"
			return .other
		}
	}
}

// MARK: - Switch Theme
extension KThemeStyle {
	/// Switch theme to one of the default styles
	static func switchTo(_ style: KThemeStyle) {
		before  = current
		current = style

		switch style {
		case .default:
			ThemeManager.setTheme(plistName: "Default", path: .mainBundle)
			UserSettings.set("Default", forKey: .currentTheme)
		case .day:
			ThemeManager.setTheme(plistName: "Day", path: .mainBundle)
			UserSettings.set("Day", forKey: .currentTheme)
		case .night:
			ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
			UserSettings.set("Night", forKey: .currentTheme)
		case .other: break
		}
	}

	/// Switch theme based on the passed theme name
	static func switchTo(theme themeName: String) {
		before  = current
		current = themeValue(from: themeName)

		ThemeManager.setTheme(plistName: themeName, path: .mainBundle)
		UserSettings.set(themeName, forKey: .currentTheme)
	}

	/// Switch theme based on the passed theme id
	static func switchTo(theme themeID: Int) {
		before  = current
		current = .other

		ThemeManager.setTheme(plistName: "theme-\(themeID)", path: .sandbox(themesDirectoryUrl))
		UserSettings.set("\(themeID)", forKey: .currentTheme)
	}

	/// Switch to one of the next default styles while ommiting Night theme
	static func switchToNext(theme themeID: Int) {
		var next = current.rawValue + 1
		var max  = 1 // without Night

		if themeExist(for: themeID) { max += 1 }
		if next >= max { next = 0 }

		switchTo(KThemeStyle(rawValue: next)!)
	}
}

// MARK: - Download
extension KThemeStyle {
	static func downloadThemeTask(for theme: ThemesElement?, _ handler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let urlString = theme?.downloadLink, urlString != "" else {
			DispatchQueue.main.async {
				handler(false)
			}
			return
		}

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
}

// MARK: - Icon
extension KThemeStyle {
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

// MARK: - Night theme
extension KThemeStyle {
	/// Switch between Night them and the theme before
	static func switchNight(_ isToNight: Bool) {
		if before == .night && current == .night {
			switchTo(.day)
		} else {
			switchTo(isToNight ? .night : before)
		}
	}

	/// Return a boolean indicating if current theme is the Night theme
	static func isNight() -> Bool {
		return current == .night
	}

	/// Switch between Day and Night theme according to sunrise and sunset
	static func checkSunSchedule() {
		before  = current
		let solar = Solar(coordinate: CLLocationCoordinate2D(latitude: User.latitude, longitude: User.longitude))
		guard let isNighttime = solar?.isNighttime else {
			ThemeManager.setTheme(plistName: "Day", path: .mainBundle)
			current = .day
			return
		}

		if isNighttime {
			ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
			current = .night
		} else {
			ThemeManager.setTheme(plistName: "Day", path: .mainBundle)
			current = .day
		}
	}
}
