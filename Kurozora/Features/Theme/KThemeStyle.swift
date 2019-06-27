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
	static let calendar = Calendar.current
	static let automaticDarkThemeSchedule = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
		KThemeStyle.checkAutomaticSchedule()
	}

	/// Return a string value for a given KThemeStyle
	var stringValue: String {
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
		before = current
		current = style

		switch style {
		case .default:
			ThemeManager.setTheme(plistName: "Default", path: .mainBundle)
			UserSettings.set("Default", forKey: .currentTheme)
		case .day:
			ThemeManager.setTheme(plistName: "Day", path: .mainBundle)
			UserSettings.set("Day", forKey: .currentTheme)
		case .night:
			if UserSettings.trueBlackEnabled {
				ThemeManager.setTheme(plistName: "Black", path: .mainBundle)
				UserSettings.set("Black", forKey: .currentTheme)
			} else {
				ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
				UserSettings.set("Night", forKey: .currentTheme)
			}
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
	/// Whether the specified custom `start` and `end` time is in daytime on `date`
	static var isCustomDaytime: Bool {
		let startTime = UserSettings.darkThemeOptionStart
		let startHour = calendar.component(.hour, from: startTime)
		let startMinute = calendar.component(.minute, from: startTime)

		let endTime = UserSettings.darkThemeOptionEnd
		let endHour = calendar.component(.hour, from: endTime)
		let endMinute = calendar.component(.minute, from: endTime)

		guard let calendarStartTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: Date()) else { return false }
		guard let calendarEndTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: Date()) else { return false }

		let beginningOfDay = calendarStartTime.timeIntervalSince1970
		let endOfDay = calendarEndTime.timeIntervalSince1970
		let currentTime = Date().timeIntervalSince1970

		let isStartOrLater = currentTime >= beginningOfDay
		let isBeforeEnd = currentTime < endOfDay

		return isStartOrLater && isBeforeEnd
	}

	/// Whether the specified custom `start` and `end` time is in nighttime on `date`
	static var isCustomNighttime: Bool {
		return !isCustomDaytime
	}

	/// Switch between Night them and the theme before
	static func switchNight(_ isToNight: Bool) {
		if before == .night && current == .night {
			switchTo(.day)
		} else {
			switchTo(isToNight ? .night : before)
		}
	}

	/// Return a boolean indicating if current theme is the Night theme
	static func isNightTheme() -> Bool {
		return current == .night
	}

	/// Wheather the specified
	static var isSolarNighttime: Bool {
		guard let solar = Solar(coordinate: CLLocationCoordinate2D(latitude: User.latitude, longitude: User.longitude)) else { return false }
		let isNighttime = solar.isNighttime

		return isNighttime
	}

	/// Switch between Light and Dark theme according to `sunrise` and `sunset` or custom `start` and `end` time
	static func checkAutomaticSchedule() {
		if UserSettings.automaticDarkTheme, let darkThemeOption = DarkThemeOption(rawValue: UserSettings.darkThemeOption) {
			before = current

			if isSolarNighttime && darkThemeOption == .automatic || isCustomNighttime && darkThemeOption == .custom {
				ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
				current = .night
			} else {
				ThemeManager.setTheme(plistName: "Day", path: .mainBundle)
				current = .day
			}
		}
	}
}
