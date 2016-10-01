//
//  AudioAssistTableViewController.swift
//  AudioAssist
//
//  Created by Gregory Weiss on 9/29/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import Firebase

class AudioAssistTableViewController: UITableViewController, UISplitViewControllerDelegate
{
    var detailViewController: ChatViewController? 
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    var messages = Array<FIRDataSnapshot>()
    
    
    var arrayOfMessages: [Message] = []
    
    let checkImage = UIImage(named: "checkedRequest.png")
    let unCheckImage = UIImage(named: "uncheckedRequest.png")
    
//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(AudioAssistTableViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
//        
//        return refreshControl
//    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(AudioAssistTableViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
        
        tableView.tableFooterView = UIView()   //  tableview.tableFooterView = UIView()
        
        splitViewController?.delegate = self
       // splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
       // splitViewController?.preferredDisplayMode = .AllVisible
        
//        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
//        navigationItem.leftItemsSupplementBackButton = true
        
        splitViewController?.preferredDisplayMode = .AllVisible
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ChatViewController
        }
        
        self.tableView.addSubview(refreshControl)    //addSubview(self.refreshControl)
        
        configureDatabase()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        for deleteObject in arrayOfMessages
        {
            if deleteObject.completed == true
            {
                deleteObject.ref!.removeValue()
            }
        }
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureDatabase()
    {
        ref = FIRDatabase.database().reference()
        
        // Listen for new messages from Firebase
        //  refHandle = ref.child(uniqueSessionID).observeEventType(.ChildAdded, withBlock: {
        
        
        ref.child("messages").observeEventType(.Value, withBlock: {
            (snapshot) -> Void in
            var newArrayOfMessages: [Message] = []
            for item in snapshot.children
            {
                if let firebaseMessage = Message.convertSnapshotToMessage(item as! FIRDataSnapshot)
                {
                    newArrayOfMessages.append(firebaseMessage)
                }
            }
            self.arrayOfMessages = newArrayOfMessages
            self.tableView.reloadData()
            self.messages.append(snapshot)
            
            //    self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.arrayOfMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
            
        })
        
        
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return arrayOfMessages.count
    }
    
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
     {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        // Unpack message from Firebase DataSnapshot
        
        let thisRequest = self.arrayOfMessages[indexPath.row]
        
        
        cell.requestLabel.text = thisRequest.request
        
        if thisRequest.completed == true
        {
            cell.checkButton.setImage(checkImage, forState: .Normal)
        }
        else if thisRequest.completed == false
        {
            cell.checkButton.setImage(unCheckImage, forState: .Normal)
        }
        
        return cell

        
     }
    

    @IBAction func requestCompletedChecked(sender: UIButton)
    {
        //isChecked = !isChecked
        let contentView = sender.superview
        let cell = contentView?.superview as! MessageCell
        let thisIndexPath = tableView.indexPathForCell(cell)  //tableview.indexPathForCell(cell)
        
        let myDone = arrayOfMessages[thisIndexPath!.row]
        // var aSnap = messages[thisIndexPath!.row]
        
        // let aRequest = Message()
        //let updateRequest = aRequest.convertSnapshotToMessage(aSnap)
        
        myDone.completed = !myDone.completed
        if myDone.completed == true
        {
            sender.setImage(checkImage, forState: .Normal)
        }
        else if myDone.completed == false
        {
            sender.setImage(unCheckImage, forState: .Normal)
        }
        let updatedMessage = ["completed": myDone.completed]
        myDone.ref?.updateChildValues(updatedMessage)
        
        
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let reqToDelete = arrayOfMessages[indexPath.row]
            // let refToDelete = messages[indexPath.row]
            reqToDelete.ref!.removeValue()
            
            //            let messageSnapshot = self.messages[indexPath.row]
            //            let message = messageSnapshot.value as! Dictionary<String, String>
            //            refToDelete.ref.updateChildValues(message)
            // messages.removeAtIndex(indexPath.row)
            // tableView.reloadData()
        }
        //   tableView.reloadData()
    }

    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    
//     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
//     {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//        if segue.identifier == "StageViewSegue"
//        {
//            let nav = segue.destinationViewController as! UINavigationController
//            let vc = nav.viewControllers[0] as! ChatViewController
//        }
//     }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "StageViewSegue"
        {
//            if let indexPath = self.tableView.indexPathForSelectedRow
//            {
//                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ChatViewController
                //controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            //}
        }
    }

 

   
    
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
        return true
    }

   
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
}
