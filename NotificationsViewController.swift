//
//  NotificationsViewController.swift
//  MyApp
//
//  Created by Ayobami Kolawole on 06/04/2020.
//  Copyright © 2020 Ayobami Kolawole. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var allNotifications: [FBNotification] = []
    
    @IBOutlet weak var noNotificationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNotification()

    }
    
    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
        
        cell.bibdData(notification: allNotifications[indexPath.row])
        return cell
        
    }
    
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        print("Delete")
        deleteNotification(fbNotification: allNotifications[indexPath.row])
        self.allNotifications.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    //MARK: IBAction
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: LoadNotifications
    
    func loadNotification() {
        
        fetchAgentNotification(agentId: FUser.currentId()) { (allNotif) in
            
            self.allNotifications = allNotif
            
            if self.allNotifications.count == 0 {
                self.noNotificationLabel.isHidden = false
                print("No notifications")
            }
            
            self.tableView.reloadData()
        }
    }
}
