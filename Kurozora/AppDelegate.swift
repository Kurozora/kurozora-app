//
//  AppDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import KCommonKit
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])

//        IQKeyoardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100.0
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        let storyboard : UIStoryboard = UIStoryboard(name: "login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as? WelcomeViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
//        User session manager
        if GlobalVariables().KDefaults["session_id"] != nil &&  GlobalVariables().KDefaults["user_id"] != nil {
            
            let sessionId = GlobalVariables().KDefaults["session_id"]!
            let userId = GlobalVariables().KDefaults["user_id"]!
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let parameters:Parameters = [
                "session_id": sessionId,
                "user_id": userId
            ]
            
            let endpoint = GlobalVariables().BaseURLString + "validate_session"
            
            Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success/*(let data)*/:
                        if response.result.value != nil{
                            let swiftyJsonVar = JSON(response.result.value!)

                            let responseSuccess = swiftyJsonVar["success"]

                        if responseSuccess.boolValue {
                            let storyboard : UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileNavigation") as? UINavigationController
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            self.window?.rootViewController = vc
                            self.window?.makeKeyAndVisible()
                        }else{
                            let storyboard : UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as? WelcomeViewController
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            self.window?.rootViewController = vc
                            self.window?.makeKeyAndVisible()
                        }
                    }
                    case .failure(let err):
                        NSLog("------------------DATA START-------------------")
                        NSLog("Response String: \(String(describing: err))")
                        let storyboard : UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as? WelcomeViewController
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = vc
                        self.window?.makeKeyAndVisible()
                        NSLog("------------------DATA END-------------------")
                    }
                }
            }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

