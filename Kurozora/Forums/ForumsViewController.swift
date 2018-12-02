//
//  ForumsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import KRichTextEditor
import SwiftyJSON
import Tabman
import Pageboy
import SCLAlertView

class ForumsViewController: TabmanViewController, PageboyViewControllerDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var createThreadButton: UIButton!

	var sections:[JSON]?
	var sectionsCount:Int?

    private var viewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Service.shared.getForumSections(withSuccess: { (sections) in
            DispatchQueue.main.async {
                self.sections = sections
                self.sectionsCount = sections?.count
                self.reloadPages()
            }
        }) { (errorMessage) in
            SCLAlertView().showError("Error getting sections", subTitle: errorMessage)
        }
        
        dataSource = self
        
        // configure the bar
        self.bar.location = .top
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            // State
            appearance.state.selectedColor = .white
            appearance.state.color =  UIColor.white.withAlphaComponent(0.5)
            
            // Style
            appearance.style.background = .blur(style: .light)
            appearance.style.showEdgeFade = true
            
            // Indicator
            appearance.indicator.bounces = true
            appearance.indicator.useRoundedCorners = true
            appearance.indicator.color = .orange
            
            // Layout
            appearance.layout.itemDistribution = .fill
            
        })
        
        self.bar.behaviors = [.autoHide(.never)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        if let sectionsCount = sections?.count, sectionsCount != 0 {
            initializeViewControllers(with: sectionsCount)
            return sectionsCount
        }
        return 0
    }
    
    private func initializeViewControllers(with count: Int) {
        let storyboard = UIStoryboard(name: "forums", bundle: nil)
        var viewControllers = [UIViewController]()
        var barItems = [Item]()
        
        for index in 0 ..< count {
            let viewController = storyboard.instantiateViewController(withIdentifier: "ForumsChild") as! ForumsChildViewController
            if let sectionTitle = sections?[index]["name"].stringValue, sectionTitle != "" {
                viewController.sectionTitle = sectionTitle
                barItems.append(Item(title: sectionTitle))
            }

			if let sectionId = sections?[index]["id"].intValue, sectionId != 0 {
				viewController.sectionId = sectionId
			}

            viewControllers.append(viewController)
        }
        
        self.bar.items = barItems
        self.viewControllers = viewControllers
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return self.viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
	@IBAction func createThreadButton(_ sender: Any) {
		let editorStoryboard = KRichTextEditor.editorStoryboard()
		let vc = editorStoryboard.instantiateInitialViewController()
		present(vc!, animated: true, completion: nil)
	}
}
