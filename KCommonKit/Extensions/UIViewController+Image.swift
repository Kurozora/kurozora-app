//
//  UIViewController+Image.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import Lightbox

extension UIViewController {
    public func presentLightboxViewController(imageUrl: String?, text: String?, videoUrl: String?) {
        let image = [LightboxImage(imageURL: URL(fileURLWithPath: imageUrl!), text: text!, videoURL: URL(fileURLWithPath: videoUrl!))]
        let controller = LightboxController(images: image)
        
        // Set delegates.
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        
        // Use dynamic background.
        controller.dynamicBackground = true

    }
}

extension UIViewController: LightboxControllerPageDelegate {
    public func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        print(page)
    }
}

extension UIViewController: LightboxControllerDismissalDelegate {
    public func lightboxControllerWillDismiss(_ controller: LightboxController) {
        // ...
    }
}
