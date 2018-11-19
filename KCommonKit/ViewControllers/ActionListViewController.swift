//
//  ActionListViewController.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
public protocol ActionListDelegate: class {
    func selectedAction(action: String)
}
public class ActionListViewController: UIViewController {
    
    let CellHeight: Int = 44
    
    @IBOutlet weak var tableTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: ActionListDelegate?
    var dataSource = [String]()
    var actionTitle = ""
    var showTableView = true
    func setDataSource(dataSource: [String], title: String) {
        self.dataSource = dataSource
        actionTitle = title
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set variables
        titleLabel.text = actionTitle
        
        // Set header height
        var headerRect = tableView.tableHeaderView?.bounds ?? CGRect.zero
        let space = (dataSource.count+1)*CellHeight
        headerRect.size.height = view.bounds.height - CGFloat(space)
        tableView.tableHeaderView?.bounds = headerRect
    }
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if showTableView {
            showTableView = false
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                
                self.tableTopSpaceConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }) { (finished) -> Void in
                
            }
        }
    }
    
    @IBAction func dismissPressed(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

extension ActionListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")
        let title = dataSource[indexPath.row]
//        cell.titleLabel.text = title
        return cell!
    }
}

extension ActionListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let action = dataSource[indexPath.row]
        delegate?.selectedAction(action: action)
        dismissPressed(sender: self)
    }
}
