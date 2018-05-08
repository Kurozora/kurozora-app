//
//  UIViewController+Navigation.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import JTSImageViewController

public protocol ModalTransitionScrollable {
    var transitionScrollView: UIScrollView? { get }
}

extension ModalTransitionScrollable {
    public func updateTransitionScrollView(animator: ZFModalTransitionAnimator) {
        if let transitionScrollView = transitionScrollView {
            animator.setContentScrollView(transitionScrollView)
        }
    }
}

// Allows to update the ScrollView
public protocol ModalTransitionMultiScrollable: ModalTransitionScrollable {
    var animator: ZFModalTransitionAnimator! { get set }
}

extension ModalTransitionMultiScrollable {
    public func updateTransitionScrollView() {
        if let transitionScrollView = transitionScrollView {
            animator.setContentScrollView(transitionScrollView)
        }
    }
}

extension UIViewController {
    
    public func presentViewControllerModal(controller: UIViewController) -> ZFModalTransitionAnimator {
        
        let animator = ZFModalTransitionAnimator(modalViewController: controller)
        animator?.isDragable = true
        animator?.direction = .bottom
        
        controller.transitioningDelegate = animator
        controller.modalPresentationStyle = .custom
        
        present(controller, animated: true) {
            var animatedController = controller
            if let navController = animatedController as? UINavigationController,
                let viewController = navController.viewControllers.last {
                animatedController = viewController
            }
            
            if let controller = animatedController as? ModalTransitionScrollable {
                controller.updateTransitionScrollView(animator: animator!)
                
                if var controller = controller as? ModalTransitionMultiScrollable {
                    controller.animator = animator
                }
            }
        }
        
        return animator!
    }
    
}
