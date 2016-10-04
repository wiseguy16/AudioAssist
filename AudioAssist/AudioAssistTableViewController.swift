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
    let iconWordsArray = ["Bongos", "Click", "Drums", "left", "Less", "More", "Piano", "right", "Saxophone", "Track", "Trumpet", "Violin", "Bass", "Instrument", "Singer", "Aco_Guitar", "Elec_Guitar", "Keyboard", "Muted", "note"]
    
    let checkImage = UIImage(named: "CheckmarkFull_icon")
    let unCheckImage = UIImage(named: "CheckMarkEmpty_icon")
    
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
    
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if !AppState.sharedInstance.signedIn
        {
            performSegueWithIdentifier("ModalLoginSegue", sender: self)
        }
        
        
        
        
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
        
        
        cell.requestLabel.attributedText = makeImageFromString("\(thisRequest.request)")
        
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
         }
        //   tableView.reloadData()
    }

    

     // MARK: - Navigation
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "StageViewSegue"
        {
            configureDatabase()
//            if let indexPath = self.tableView.indexPathForSelectedRow
//            {
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
    
    @IBAction func signOut(sender: UIBarButtonItem)
    {
        do {
            try FIRAuth.auth()?.signOut()
            AppState.sharedInstance.signedIn = false
            print("Sign Out successfull")
            performSegueWithIdentifier("ModalLoginSegue", sender: self)
        } catch let signOutError as NSError
        {
            print("Error signing out: \(signOutError)")
        }
        
    }
    
    func makeImageFromString(newWord: String) -> NSMutableAttributedString
    {
        let offsetY: CGFloat = -8.0
        var image10String = NSAttributedString()
        let iconatedString = NSMutableAttributedString()
        let spaceString = NSAttributedString(string: " ")
        let storeArray = newWord.componentsSeparatedByString(" ")
        for checkWord in storeArray
        {
            if iconWordsArray.contains(checkWord)
            {
                let image10Attachment = NSTextAttachment()
                image10Attachment.image = UIImage(named: "\(checkWord)")
                image10Attachment.bounds = CGRectMake(0, offsetY, image10Attachment.image!.size.width, image10Attachment.image!.size.height)
                image10String = NSAttributedString(attachment: image10Attachment)
                //image10String.
            }
            else
            {
                image10String = NSAttributedString(string: "\(checkWord)")
            }
            iconatedString.appendAttributedString(image10String)
            iconatedString.appendAttributedString(spaceString)
        }
        
        return iconatedString
    }



   

    
}
