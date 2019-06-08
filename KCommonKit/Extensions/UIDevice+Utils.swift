//
//  UIDevice+Utils.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

extension UIDevice {
	/// Returns true if the current device is an iPad
    public class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

	/// Returns true if the current device is an iPhone
	public class func isPhone() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .phone
	}

	/// Returns true if the current device is an Apple TV
	public class func isTV() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .tv
	}

	/// Returns true if the current device is an Apple CarPlay
	public class func isCarPlay() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .carPlay
	}

	/// Returns true if the current device is an unspecified device
	public class func isUnspecified() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .unspecified
	}

	/// Returns true if the current device orientation is landscape
    public class func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }

	/// Returns true if the current device orientation is portrait
	public class func isPortrait() -> Bool {
		return UIDevice.current.orientation.isPortrait
	}

	/// Returns true if the current device orientation is face up or face down
	public class func isFlat() -> Bool {
		return UIDevice.current.orientation.isFlat
	}

	/// Returns true if the current device orientation portrait or landscape
	public class func isValidInterfaceOrientation() -> Bool {
		return UIDevice.current.orientation.isValidInterfaceOrientation
	}
}
