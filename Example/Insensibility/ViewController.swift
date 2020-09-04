//
//  ViewController.swift
//  Insensibility
//
//  Created by adx-developer on 09/03/2020.
//  Copyright (c) 2020 adx-developer. All rights reserved.
//

import UIKit
import Insensibility

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var dataSource: [String] = []
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshBlock = { [unowned self] completion in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.dataSource = Array(repeating: "", count: 10)
                self.tableView.reloadData()
                completion(false)
            }
        }
        tableView.loadmoreBlock = { completion in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.dataSource.append(contentsOf: Array(repeating: "", count: 10))
                self.tableView.reloadData()
                completion(self.dataSource.count > 200)
            }
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(view)
        }
        
        _ = tableView.refresh()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

}

