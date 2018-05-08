//
//  UIDevice+Utils.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

extension UIDevice {
    public class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public class func isLandscape() -> Bool {
        return UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
    }
}
