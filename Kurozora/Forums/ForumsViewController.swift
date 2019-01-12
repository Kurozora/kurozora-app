//
//  ForumsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import Tabman
import Pageboy
import SCLAlertView

class ForumsViewController: TabmanViewController, PageboyViewControllerDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var createThreadButton: UIButton!
	@IBOutlet weak var sortingBarButtonItem: UIBarButtonItem!

	var sections: [ForumSectionsElement]?
	var sectionsCount: Int?
	var threadSorting: String?

    private var viewControllers = [UIViewController]()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Service.shared.getForumSections(withSuccess: { (sections) in
            DispatchQueue.main.async {
                self.sections = sections
                self.sectionsCount = sections?.count
                self.reloadPages()
            }
        })
        
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
            if let sectionTitle = sections?[index].name {
                viewController.sectionTitle = sectionTitle
                barItems.append(Item(title: sectionTitle))
            }

			if let sectionID = sections?[index].id, sectionID != 0 {
				viewController.sectionID = sectionID
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

	// MARK: - IBActions
	@IBAction func sortingButtonPressed(_ sender: UIBarButtonItem) {
		let action = UIAlertController.actionSheetWithItems(items: [("↑ Top", "top"),("◕ Recent","recent")], currentSelection: threadSorting, action: { (value)  in
			let currentSection = self.currentViewController as? ForumsChildViewController
			currentSection?.threadOrder = value
			self.sortingBarButtonItem.title = value.capitalized
			currentSection?.fetchThreads()
		})

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		self.present(action, animated: true, completion: nil)
	}

	@IBAction func createThreadButton(_ sender: Any) {
		let storyboard = UIStoryboard(name: "editor", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "RichEditor") as? KRichTextEditorControllerView
		vc?.delegate = viewControllers[currentIndex!] as! ForumsChildViewController
		vc?.sectionID = currentIndex! + 1

		let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: vc!)
		if #available(iOS 11.0, *) {
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		}

		present(kurozoraNavigationController, animated: true, completion: nil)
	}
}
