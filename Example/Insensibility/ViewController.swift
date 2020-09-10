//
//  ViewController.swift
//  Insensibility
//
//  Created by andrew020 on 09/03/2020.
//  Copyright (c) 2020 andrew020. All rights reserved.
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
            let url: String = "testurl"
            ChainCaller.shared().startChain(
                identifier: nil, parameter: url
            ).addProcess { (value, completion) in
                // 模拟检查url
                let url = value.parameters as! String
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
                    completion((nil, false, url + ". is correct"))
                }
            }.addProcess { (value, completion) in
                // 模拟拼装url
                let url = value.parameters as! String
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
                    completion((nil, false, url + ". this path extention"))
                }
            }.result { (value) in
                // 完成之后刷新
                let url = value.parameters
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let label = UILabel()
        label.text = "\(indexPath.row)"
        
        let vc = FadePresentationViewController()
        vc.presentingBlock = { isShow in
            if isShow {
                vc.view.addSubview(label)
                label.snp.makeConstraints { (maker) in
                    maker.center.equalToSuperview()
                }
            }
        }
        vc.view.backgroundColor = UIColor(white: 0, alpha: 0.4);
        
        present(vc, animated: true, completion: nil)
    }

}

