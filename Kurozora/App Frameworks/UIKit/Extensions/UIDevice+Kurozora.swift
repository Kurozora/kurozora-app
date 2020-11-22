//
//  UIDevice+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/06/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import LocalAuthentication

// MARK: - Model
extension UIDevice {
	// MARK: - Properties
	/// The device's model name in a readable form.
	static let modelName: String = {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}

		/**
			Maps the given identifier to a device name.

			- Parameter identifier: The identifier used to map to a device name.

			- Returns: the mapped device name. If no device with the given identifier is found then the `identifier` is returned.
		*/
		func mapToDevice(identifier: String) -> String {
			#if os(iOS)
			switch identifier {
			// iPod
			case "iPod1,1":                                 return "iPod Touch 1"
			case "iPod2,1":                                 return "iPod Touch 2"
			case "iPod3,1":                                 return "iPod Touch 3"
			case "iPod4,1":                                 return "iPod Touch 4"
			case "iPod5,1":                                 return "iPod Touch 5"
			case "iPod7,1":                                 return "iPod Touch 6"
			case "iPod9,1":                                 return "iPod Touch 7"
			// iPhone
			case "iPhone1,1":								return "iPhone 2G"
			case "iPhone1,2":								return "iPhone 3G"
			case "iPhone2,1":								return "iPhone 3GS"
			case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
			case "iPhone4,1":                               return "iPhone 4s"
			case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
			case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
			case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
			case "iPhone7,2":                               return "iPhone 6"
			case "iPhone7,1":                               return "iPhone 6 Plus"
			case "iPhone8,1":                               return "iPhone 6s"
			case "iPhone8,2":                               return "iPhone 6s Plus"
			case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
			case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
			case "iPhone8,4":                               return "iPhone SE"
			case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
			case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
			case "iPhone10,3", "iPhone10,6":                return "iPhone X"
			case "iPhone11,2":                              return "iPhone XS"
			case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
			case "iPhone11,8":                              return "iPhone XR"
			case "iPhone12,1":                              return "iPhone 11"
			case "iPhone12,3":                              return "iPhone 11 Pro"
			case "iPhone12,5":                              return "iPhone 11 Pro Max"
			// iPad
			case "iPad1,1", "iPad1,2":						return "iPad"
			case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
			case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
			case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
			case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
			case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
			case "iPad6,11", "iPad6,12":                    return "iPad 5"
			case "iPad7,5", "iPad7,6":                      return "iPad 6"
			case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
			case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
			case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
			case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
			case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
			case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
			case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
			case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
			case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
			case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
			case "iPad11,1", "iPad11,2":					return "iPad Mini 5"
			case "iPad11,3", "iPad11,4":					return "iPad Air 3"
			// Apple TV
			case "AppleTV1,1":								return "Apple TV 1G"
			case "AppleTV2,1":								return "Apple TV 2G"
			case "AppleTV3,1":								return "Apple TV 3G"
			case "AppleTV3,2":								return "Apple TV 3G rev A"
			case "AppleTV5,3":                              return "Apple TV 4G"
			case "AppleTV6,2":                              return "Apple TV 4K"
			// HomePod
			case "AudioAccessory1,1":                       return "HomePod"
			// Simulator
			case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
			default:                                        return identifier
			}
			#elseif os(watchOS)
			switch identifier {
			// Apple Watch
			case "Watch1,1", "Watch1,2":					return "Apple Watch"
			case "Watch2,3", "Watch2,4":					return "Apple Watch Series 2"
			case "Watch2,6", "Watch2,7":					return "Apple Watch Series 1"
			case "Watch3,1", "Watch3,2":					return "Apple Watch Series 3 Cellular"
			case "Watch3,3", "Watch3,4":					return "Apple Watch Series 3"
			case "Watch4,1", "Watch4,2":					return "Apple Watch Series 4"
			case "Watch4,3", "Watch4,4":					return "Apple Watch Series 4 Cellular"
			case "Watch5,1", "Watch5,2":					return "Apple Watch Series 5"
			case "Watch5,3", "Watch5,4":					return "Apple Watch Series 5 Cellular"
			default:										return identifier
			}
			#elseif os(tvOS)
			switch identifier {
			case "AppleTV5,3": 								return "Apple TV 4"
			case "AppleTV6,2": 								return "Apple TV 4K"
			case "i386", "x86_64": 							return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
			default: 										return identifier
			}
			#endif
		}

		return mapToDevice(identifier: identifier)
	}()
}

// MARK: - Orientation
extension UIDevice {
	// MARK: - Properties
	/// Returns true if the current device is an iPad
	static var isPad: Bool {
		return UIDevice.current.userInterfaceIdiom == .pad
	}

	/// Returns true if the current device is an iPhone
	static var isPhone: Bool {
		return UIDevice.current.userInterfaceIdiom == .phone
	}

	/// Returns true if the current device is an Apple TV
	static var isTV: Bool {
		return UIDevice.current.userInterfaceIdiom == .tv
	}

	/// Returns true if the current device is an Apple CarPlay
	static var isCarPlay: Bool {
		return UIDevice.current.userInterfaceIdiom == .carPlay
	}

	/// Returns true if the current device is an unspecified device
	static var isUnspecified: Bool {
		return UIDevice.current.userInterfaceIdiom == .unspecified
	}

	/// Returns true if the current device orientation is landscape
	static var isLandscape: Bool {
		return UIDevice.current.orientation.isLandscape
	}

	/// Returns true if the current device orientation is portrait
	static var isPortrait: Bool {
		return UIDevice.current.orientation.isPortrait
	}

	/// Returns true if the current device orientation is face up or face down
	static var isFlat: Bool {
		return UIDevice.current.orientation.isFlat
	}

	/// Returns true if the current device orientation portrait or landscape
	static var isValidInterfaceOrientation: Bool {
		return UIDevice.current.orientation.isValidInterfaceOrientation
	}
}

// MARK: - Capabilities
extension UIDevice {
	// MARK: - Properties
	/// A boolean indicating if the device has a `Top Notch`™.
	static let hasTopNotch: Bool = {
		return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
	}()

	/// The type of biometric the current device supports.
	static let supportedBiomtetric: LABiometryType = {
		let context = LAContext.init()
		var error: NSError?

		if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			switch context.biometryType {
			case .faceID:
				return .faceID
			case .touchID:
				return .touchID
			default:
				return .none
			}
		}

		return .none
	}()
}

// MARK: - Screen
extension UIDevice {
	// MARK: - Enums
	/**
		A set of available device types.

		```
		case iPhone5SSE
		case iPhone66S78
		case iPhone66S78PLUS
		case iPhoneXXs
		...
		```
	*/
	enum `Type` {
		// MARK: - Cases
		// iPhone
		/// The device is an iPhone 5, iPhone 5S or iPhone SE.
		case iPhone5SSE

		/// The device is an iPhone 6, iPhone 6S, iPhone 7 or iPhone 8.
		case iPhone66S78

		/// The device is an iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus.
		case iPhone66S78PLUS

		/// The device is an iPhone X or iPhone Xs.
		case iPhoneXXs

		/// The device is an iPhone Xs Max.
		case iPhoneXsMax

		/// The device is an iPhone Xr.
		case iPhoneXr

		// iPad
		/// The device is an iPad.
		case iPad

		/// The device is an iPad Air 3.
		case iPadAir3

		/// The device is an iPad Pro 11".
		case iPadPro11

		/// The device is an iPad Pro 12".
		case iPadPro12
	}

	// MARK: - Properties
	/// The type of the current device.
	static var type: Type {
		switch UIDevice().userInterfaceIdiom {
		case .phone:
			switch UIScreen.main.nativeBounds.height {
			case 1136:		return .iPhone5SSE
			case 1334:		return .iPhone66S78
			case 1920, 2208:return .iPhone66S78PLUS
			case 1792:		return .iPhoneXr
			case 2436:		return .iPhoneXXs
			case 2688:		return .iPhoneXsMax
			default:		return .iPhone66S78
			}
		case .pad:
			switch UIScreen.main.nativeBounds.height {
			case 2048:		return .iPad
			case 2224:		return .iPadAir3
			case 2388:		return .iPadPro11
			case 2732:		return .iPadPro12
			default:		return .iPadAir3
			}
		default: 			return .iPhone66S78
		}
	}
}
