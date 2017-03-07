//
//  SettingFilterViewController.swift
//  WebKyu
//
//  Created by Leon.yan on 07/03/2017.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit

class SettingFilterViewController: UITableViewController {
    
    var isAllImageTypeEnable: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "Filter"
        if self.navigationController?.viewControllers.count == 1 {
            let item: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "unfold"),
                                                        style: UIBarButtonItemStyle.plain,
                                                        target: self,
                                                        action: #selector(dismiss(_:)))
            self.navigationItem.leftBarButtonItem = item
        }
    }
    
    func dismiss(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return isAllImageTypeEnable ? 1 : 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "image size"
        } else {
            return "image type"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "limitCell", for: indexPath) as! SettingLimitCell
            cell.textLabel?.text = "resolution limit"
            cell.detailTextLabel?.text = "10 x 10"
            return cell
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! SettingToggleCell
            cell.titleLabel.text = "all supported types"
            cell.toggleSwitch.isOn = isAllImageTypeEnable
            cell.toggleSwitch.addTarget(self,
                                        action: #selector(switchValueChange(_:)),
                                        for: UIControlEvents.valueChanged)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "checkCell", for: indexPath) as! SettingCheckCell
            if indexPath.row == 1 {
                cell.titleLabel.text = "JPG"
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "PNG"
            } else if indexPath.row == 3 {
                cell.titleLabel.text = "GIF"
            }
            cell.checkButton.tag = indexPath.row
            cell.checkButton.addTarget(self,
                                       action: #selector(imageTypeSupportChange(_:)),
                                       for: UIControlEvents.touchUpInside)
            
            return cell
        }
    }
    
    func switchValueChange(_ sender: UISwitch) {
        isAllImageTypeEnable = sender.isOn
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
    }
    
    func imageTypeSupportChange(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row == 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
