//
//  ParamsTableViewController.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 4/7/22.
//  Copyright © 2022 Infrared5. All rights reserved.
//

import Foundation
import UIKit

protocol ParamCellDelegate: class {
    func addNewCell()
    func updateParamAt(param: Param, index: Int)
}

class ParamsTableViewController: UITableViewController, ParamCellDelegate {
    
    @IBOutlet var paramTable: UITableView!
    
    func addNewCell() {
        Testbed.getConnectionParams()?.add(Param(name: "", value: ""))
        self.tableView.reloadData()
    }
    
    func updateParamAt(param: Param, index: Int) {
        Testbed.getConnectionParams()?[index] = param
        // Don't need to refresh table as editing is inline.
//        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paramTable.rowHeight = 120.0
        paramTable.register(UINib(nibName: "ParamCell", bundle: nil), forCellReuseIdentifier: "ParamCell")
        paramTable.register(UINib(nibName: "ParamAddCell", bundle: nil), forCellReuseIdentifier: "ParamAddCell")
//        paramTable.register(ParamCell.self, forCellReuseIdentifier: "ParamCell")
        paramTable.delegate = self
        paramTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var index: Int = Testbed.getConnectionParams()!.count - 1
        while (index > -1) {
            let param: Param = Testbed.getConnectionParams()?[index] as! Param
            if (param.name.isEmpty || param.value.isEmpty) {
                Testbed.getConnectionParams()?.removeObject(at: index)
            }
            index = index - 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        let p = Testbed.getConnectionParams()
        if (p != nil) {
            count += p!.count
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        let index = indexPath.row
        let len = Testbed.getConnectionParams()?.count
        if (len == nil || index == len) {
            cell = tableView.dequeueReusableCell(withIdentifier: "ParamAddCell", for: indexPath as IndexPath) as? ParamAddCell
            (cell as! ParamAddCell).configure(self)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "ParamCell", for: indexPath as IndexPath) as? ParamCell
            let p = Testbed.getConnectionParams()?[indexPath.row] as! Param
            (cell as! ParamCell).configure(self, name: p.name, value: p.value, index: index)
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            Testbed.getConnectionParams()?.removeObject(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }

}
