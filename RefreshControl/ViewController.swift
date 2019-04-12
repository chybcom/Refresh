//
//  ViewController.swift
//  RefreshControl
//
//  Created by apple on 2019/4/12.
//  Copyright © 2019 apple. All rights reserved.
//  ....

import UIKit

class ViewController: UIViewController {
    
    
    lazy var refreshControl: RefreshControl = RefreshControl()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        loadData()
    }
    
    
    @objc func loadData() -> () {
        
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            print("结束刷新")
            self.refreshControl.endRefreshing()
        }
        
        
    }
    
    
}



