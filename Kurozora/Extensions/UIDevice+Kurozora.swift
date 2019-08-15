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
	/// The device's model name in a readable form.
	static let modelName: String = {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}

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
			case "AppleTV5,3":                              return "Apple TV"
			case "AppleTV6,2":                              return "Apple TV 4K"
			// HomePod
			case "AudioAccessory1,1":                       return "HomePod"
			// Simulator
			case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
			default:                                        return identifier
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
	/// A boolean indicating if the device has a `Top Notch`™.
	static let hasTopNotch: Bool = {
		if #available(iOS 11.0,  *) {
			return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
		}
		return false
	}()

	/// The type of biometric the current device supports.
	static let supportedBiomtetric: BiometricType = {
		let context = LAContext.init()
		var error: NSError?

		if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			if #available(iOS 11.0, *) {
				switch context.biometryType {
				case .faceID:
					return .faceID
				case .touchID:
					return .touchID
				default:
					return .none
				}
			} else {
				// Fallback on earlier versions
				return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
			}
		} else {
			return .none
		}
	}()
}

// MARK: - Screen
extension UIDevice {
	public enum `Type` {
		// iPhone
		case iPhone_5_5S_5C_SE
		case iPhone_6_6S_7_8
		case iPhone_6_6S_7_8_PLUS
		case iPhone_X_Xs
		case iPhone_Xs_Max
		case iPhone_Xr

		// iPad
		case iPad
		case iPadAir3
		case iPadPro11
		case iPadPro12
	 }

	static var type: Type {
		switch UIDevice().userInterfaceIdiom {
		case .phone:
			switch UIScreen.main.nativeBounds.height {
			case 1136:		return .iPhone_5_5S_5C_SE
			case 1334:		return .iPhone_6_6S_7_8
			case 1920, 2208:return .iPhone_6_6S_7_8_PLUS
			case 1792:		return .iPhone_Xr
			case 2436:		return .iPhone_X_Xs
			case 2688:		return .iPhone_Xs_Max
			default:		return .iPhone_6_6S_7_8
			}
		case .pad:
			switch UIScreen.main.nativeBounds.height {
			case 2048:		return .iPad
			case 2224:		return .iPadAir3
			case 2388:		return .iPadPro11
			case 2732:		return .iPadPro12
			default:		return .iPadAir3
			}
		default: 			return .iPhone_6_6S_7_8
		}
	}
}
