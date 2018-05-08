//
//  DropDownListViewController.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

public protocol DropDownListDelegate: class {
    func selectedAction(sender: UIView, action: String, indexPath: IndexPath)
    func dropDownDidDismissed(selectedAction: Bool)
}

public class DropDownListViewController: UIViewController {
    
    let CellHeight: Int = 44
    
    @IBOutlet weak var clipTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    public weak var delegate: DropDownListDelegate?
    var dataSource = [[String]]()
    var imageDataSource = [[String]]()
    var yPosition: CGFloat = 0
    var showTableView = true
    var trigger: UIView!
    var viewController: UIViewController!
    
    public class func showDropDownListWith(
        sender: UIView,
        viewController: UIViewController,
        delegate: DropDownListDelegate?,
        dataSource: [[String]],
        imageDataSource: [[String]] = []) {
        
        let frameRelativeToViewController = sender.convert(sender.bounds, to: viewController.view)
        
        let controller = KCommonKit.dropDownListViewController()
        controller.delegate = delegate
        controller.setDataSource(trigger: sender, viewController: viewController, dataSource: dataSource, yPosition: frameRelativeToViewController.maxY, imageDataSource: imageDataSource)
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        viewController.present(controller, animated: false, completion: nil)
        
    }
    
    public func setDataSource(trigger: UIView, viewController: UIViewController, dataSource: [[String]], yPosition: CGFloat, imageDataSource: [[String]] = [[]]) {
        self.trigger = trigger
        self.viewController = viewController
        self.dataSource = dataSource
        self.yPosition = yPosition
        self.imageDataSource = imageDataSource
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        var tableHeight: CGFloat = 0
        
        for array in dataSource {
            tableHeight += CGFloat(array.count*CellHeight) + 22
        }
        
        tableHeight -= 22
        
        let heightLeft = viewController.view.bounds.height - yPosition
        if tableHeight > heightLeft {
            tableHeight = heightLeft
            self.tableView.isScrollEnabled = true
        }
        
        self.tableTopSpaceConstraint.constant = -tableHeight
        self.tableHeightConstraint.constant = tableHeight
        
        self.clipTopSpaceConstraint.constant = yPosition
        
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if showTableView {
            showTableView = false
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
                
                self.tableTopSpaceConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }) { (finished) -> Void in
                
            }
        }
    }
    
    @IBAction func dismissPressed(sender: AnyObject) {
        dismiss(animated: true, completion: { () in
            if let _ = sender as? DropDownListViewController {
                self.delegate?.dropDownDidDismissed(selectedAction: true)
            } else {
                self.delegate?.dropDownDidDismissed(selectedAction: false)
            }
        })
    }
}

extension DropDownListViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !touch.view!.isDescendant(of: tableView)
    }
}

extension DropDownListViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = (imageDataSource.count != 0) ? "OptionCell2" : "OptionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! BasicTableCell
        let title = dataSource[indexPath.section][indexPath.row]
        cell.titleLabel.text = title
        if imageDataSource.count != 0 {
            cell.titleimageView.image = UIImage(named: imageDataSource[indexPath.section][indexPath.row])
        }
        
        // TODO: Refactor this
        if indexPath.section == 2 {
            cell.titleLabel.textColor = UIColor.watching()
        } else {
            cell.titleLabel.textColor = UIColor.white
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 22
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell") as! BasicTableCell
        return cell.contentView
    }
}

extension DropDownListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let action = dataSource[indexPath.section][indexPath.row]
        delegate?.selectedAction(sender: trigger, action: action, indexPath: indexPath as IndexPath)
        dismissPressed(sender: self)
        
    }
}
