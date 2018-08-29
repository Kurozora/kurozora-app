//
//  RateViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import Cosmos
import KDatabaseKit
import KCommonKit
import SCLAlertView

class RateViewController: UIViewController {
    
    @IBOutlet weak var cosmosView: CosmosView!
    
    var show: Show?

    var sessionSecret = GlobalVariables().KDefaults["session_secret"]
    var userId = User.currentId()
    
    func updateShow(withId id: Int?, withRating rating: Double?) {
        Request.rate(showId: id, score: rating, withSuccess: { (success) in
            if !success {
                SCLAlertView().showWarning("Error rating", subTitle: "There was an error while rating")
            }
        }) { (err) in
            SCLAlertView().showWarning("Error rating", subTitle: "There was an error while rating: \(err)")
            NSLog("------- Rating error: \(err)")
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        cosmosView.didFinishTouchingCosmos = { rating in
            let id = self.show?.id ?? 1
            self.updateShow(withId: id, withRating: rating)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.cosmosView.transform = .identity
        }) { (completed) -> Void in

        }
    }

    // MARK: - IBActions

//    @IBAction func dismissViewController(sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
//    }
}
