//
//  CalendarViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
//import Bolts

class CalendarViewController: UIViewController {
//    
//    var weekdayStrings: [String] = []
//    
//    var dayViewControllers: [DayViewController] = []
//    
//    var airingDataSource: [[Anime]] = [] {
//        didSet {
//            updateControllersDataSource()
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        buttonBarView.selectedBar.backgroundColor = UIColor.peterRiver()
//
//        fetchAiring()
//    }
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        
//        for controller in dayViewControllers {
//            controller.updateLayout(withSize: size)
//        }
//        
//    }
//    
//    func updateControllersDataSource() {
//        
//        for index in 0..<7 {
//            let controller = dayViewControllers[index]
//            let dayDataSource = airingDataSource[index]
//            
//            controller.updateDataSource(dataSource: dayDataSource)
//        }
//        
//    }
//    
//    func fetchAiring() {
//        
//        let query = Anime.query()!
//        query.whereKeyExists("startDateTime")
//        query.whereKey("status", equalTo: "currently airing")
//        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
//            
//            if let result = result as? [Anime] {
//                
//                var animeByWeekday: [[Anime]] = [[],[],[],[],[],[],[]]
//                
//                let calendar = NSCalendar.currentCalendar()
//                let unitFlags: NSCalendarUnit = .Weekday
//                
//                for anime in result {
//                    let startDateTime = anime.nextEpisodeDate ?? NSDate()
//                    let dateComponents = calendar.components(unitFlags, fromDate: startDateTime)
//                    let weekday = dateComponents.weekday-1
//                    animeByWeekday[weekday].append(anime)
//                    
//                }
//                
//                var todayWeekday = calendar.components(unitFlags, fromDate: NSDate()).weekday - 1
//                while (todayWeekday > 0) {
//                    let currentFirstWeekdays = animeByWeekday[0]
//                    animeByWeekday.removeAtIndex(0)
//                    animeByWeekday.append(currentFirstWeekdays)
//                    todayWeekday -= 1
//                }
//                
//                self.airingDataSource = animeByWeekday
//            }
//            
//        })
//        
//    }
//    
//    // MARK: - PagerTabStripViewControllerDataSource
//    
//    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController!) -> [AnyObject]! {
//        
//        let storyboard = UIStoryboard(name: "Season", bundle: nil)
//        
//        // Set weekday strings
//        let calendar = Calendar.current
//        let today = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "eeee, MMM dd"
//        for daysAhead in 0..<7 {
//            let date = calendar.date(byAdding: Calendar.Component.day, value: daysAhead, to: today)
//            let dateString = dateFormatter.string(from: date!)
//            weekdayStrings.append(dateString)
//            
//            // Instatiate view controller
//            let controller = storyboard.instantiateViewController(withIdentifier: "DayList") as! DayViewController
//            controller.initWithTitle(title: dateString, section: daysAhead)
//            dayViewControllers.append(controller)
//        }
//        
//        return dayViewControllers
//    }
//    
//    // MARK: - IBActions
//    
//    @IBAction func dismissViewControllerPressed(sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//
//extension CalendarViewController: UINavigationBarDelegate {
//    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
//        return UIBarPosition.topAttached
//    }
}
