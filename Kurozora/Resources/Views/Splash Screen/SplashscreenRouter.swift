//
//  SplashscreenRouter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenRoutingLogic {
	func routeToSomewhere()
}

protocol SplashscreenDataPassing {
	var dataStore: SplashscreenDataStore? { get }
}

// MARK: - Router
final class SplashscreenRouter: SplashscreenDataPassing {
	weak var viewController: SplashscreenViewController?
	var dataStore: SplashscreenDataStore?
}

// MARK: - RoutingLogic
extension SplashscreenRouter: SplashscreenRoutingLogic {
	func routeToSomewhere() {
//        let destinationVC = SplashscreenViewController()
//		if let sourceDS = self.dataStore, let destinationDS = destinationVC.router?.dataStore {
//            passData(from: sourceDS, to: destinationDS)
//        }
//
//		self.viewController?.present(destinationVC, animated: true, completion: nil)
	}
}

// MARK: - PassData
extension SplashscreenRouter {
//	/// Provide the destination dataStore with data from the source dataStore.
//	func passData(from source: SplashscreenDataStore, to destination: SplashscreenDataStore) {
//		destination.name = source.name
//	}
}
