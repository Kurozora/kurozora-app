//
//  SplashscreenRouter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenRoutingLogic {}

protocol SplashscreenDataPassing {
	var dataStore: SplashscreenDataStore? { get }
}

// MARK: - Router
final class SplashscreenRouter: SplashscreenDataPassing {
	weak var viewController: SplashscreenViewController?
	var dataStore: SplashscreenDataStore?
}

// MARK: - RoutingLogic
extension SplashscreenRouter: SplashscreenRoutingLogic {}

// MARK: - PassData
extension SplashscreenRouter {}
