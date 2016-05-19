//
//  WineCellarViewController.swift
//  VineLog
//
//  Created by Patrick Cooke on 5/19/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class WineCellarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let backendless = Backendless.sharedInstance()
    var currentuser = BackendlessUser()
    var loginManager = LoginManager.sharedInstance
    var wineArray = [WineEntry]()
    @IBOutlet private weak var wineCellarTableView  :UITableView!
    
    //MARK: - InterActivity Methods
    
    @IBAction private func logoutButton(button: UIBarButtonItem) {
        self.navigationController!.popViewControllerAnimated(true)
        backendless.userService.logout(
            { ( user : AnyObject!) -> () in
                print("User logged out.")
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
        })
    }
    
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destController = segue.destinationViewController as! WineDetailViewController
        if segue.identifier == "editWine" {
            let indexPath = wineCellarTableView.indexPathForSelectedRow!
            let newWine = wineArray[indexPath.row]
            destController.newWine = newWine
            wineCellarTableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "newWine" {
            destController.newWine = nil
        }
    }
    
    //MARK: - FetchData
    
    private func fetchData() {
            let dataQuery = BackendlessDataQuery()
            let whereClause = "ownerId = '\(loginManager.currentuser.objectId)'"
            dataQuery.whereClause = whereClause
            
            var error: Fault?
            let bc = backendless.data.of(WineEntry.ofClass()).find(dataQuery, fault: &error)
            if error == nil {
                wineArray = bc.getCurrentPage() as! [WineEntry]
                print("Found \(wineArray.count)")
            } else {
                print("Find Error \(error)")
        }
    }
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wineArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let selectedWine = wineArray[indexPath.row]
        
        cell.textLabel?.text = ("\(selectedWine.wineVintage) \(selectedWine.wineName)")
        cell.detailTextLabel?.text = ("by \(selectedWine.wineWinery),")
        
        return cell
    }
    
    //MARK: - Reused Method
    
    func refetchAndReload() {
        fetchData()
        wineCellarTableView.reloadData()
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refetchAndReload()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refetchAndReload), name: "wineSaved", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
