//
//  RateViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Cosmos
import SCLAlertView

protocol ShowRatingDelegate: class {
    func getRating(value: Double?)
}

class RateViewController: UIViewController {
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var rateTextLabel: UILabel!
    
    weak var showDetailsElement: ShowDetailsElement?
    var showRating: Double?
    var showRatingdelegate: ShowRatingDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func updateShow(withId id: Int?, withRating rating: Double?) {
        Service.shared.rate(showID: id, score: rating, withSuccess: { (success) in
            if success {
                if let showRating = rating {
                    self.showRatingdelegate?.getRating(value: showRating)
                }
                
                self.dismiss(animated: true, completion: nil)
            } else {
                SCLAlertView().showWarning("Error rating", subTitle: "There was an error while rating")
            }
        })
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        cosmosView.didFinishTouchingCosmos = { rating in
            if let id = self.showDetailsElement?.id, id != 0 {
                self.updateShow(withId: id, withRating: rating)
            }
        }
        
        if let rating = showRating {
            self.cosmosView.rating = rating
        } else {
            self.cosmosView.rating = 0.0
        }
        
        if let title = self.showDetailsElement?.title {
            self.rateTextLabel.text = "Rate \(title)"
        } else {
            self.rateTextLabel.text = "Rate this anime!"
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.cosmosView.transform = .identity
        }) { (completed) -> Void in
            
        }
    }

	// MARK:- Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "rate", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "RateViewController")
	}
    
    // MARK: - IBActions
    @IBAction func dismissViewController(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
