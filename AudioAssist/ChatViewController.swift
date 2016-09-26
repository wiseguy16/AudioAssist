//
//  ChatViewController.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/16/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import Firebase


//protocol LoginViewControllerDelegate
//{
//    func didSetSessionID(sessionIDFromLogin: String?)
//}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate//, LoginViewControllerDelegate
{
    
    @IBOutlet weak var stageBackground: UIImageView!
    //var location = CGPoint(x: 0, y: 0)
     var start: CGPoint?
    var newCenter: CGPoint?
    
    @IBOutlet weak var pianoLabel: UILabel!
    
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var unlockLabel: UIButton!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var newLabel2: UILabel!
    
    @IBOutlet weak var newGuitarButton2: UIButton!
    
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    @IBOutlet var guitarPan: UIPanGestureRecognizer!
    
    @IBOutlet weak var handLeftButton: UIButton!
    @IBOutlet weak var drums: UIImageView!
    @IBOutlet weak var elecGuitar: UIImageView!
    @IBOutlet weak var keys: UIImageView!
    @IBOutlet weak var piano: UIImageView!
    @IBOutlet weak var click: UIImageView!
    @IBOutlet weak var acoGuitar: UIImageView!
    @IBOutlet weak var handUp: UIImageView!
    @IBOutlet weak var handDown: UIImageView!
    @IBOutlet weak var handLeft: UIImageView!
    @IBOutlet weak var handRight: UIImageView!
    
     @IBOutlet weak var singleTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var iconLabel: UILabel!
    var canMoveIcons = false
    var toggledCompletion = false
    
    var isChecked = false
    
    var handRightButton = UIButton()
    
    let checkImage = UIImage(named: "checkedRequest.png")
    let unCheckImage = UIImage(named: "uncheckedRequest.png")
    let checkImageName = "checkedRequest.png"
    let unCheckImageName = "uncheckedRequest.png"
    
    //var uniqueSessionID: String = "a"
    
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    var messages = Array<FIRDataSnapshot>()
    
    
    var arrayOfMessages: [Message] = []
     var messageRefHandles = Array<FIRDatabaseHandle>()
   
    
    @IBOutlet weak var chattextFieldConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        
        // This is the default setting but be explicit anyway...
       // new_view.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        //new_view.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |
         //   UIViewAutoresizing.FlexibleRightMargin
       // new_view.center = CGPointMake(self.view.frame.size.height - 20, view.bounds.midY)
        
        
        let filteredSubviews = self.view.subviews.filter({
            $0.isKindOfClass(UIImageView) })
           // $0.isKindOfClass(UIButton) })
        // 2
        for view in filteredSubviews  {
            // 3
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))   //    (target: self, action: #Selector(handleTap))
            // 4
            
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
            
            recognizer.requireGestureRecognizerToFail(monkeyPan)
            recognizer.requireGestureRecognizerToFail(bananaPan)
            recognizer.requireGestureRecognizerToFail(guitarPan)
            //TODO: Add a custom gesture recognizer too
        }
        
        
        
        configureDatabase()
       // tableview.reloadData()
       // print(self.arrayOfMessages)
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
  
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
       // configureDatabase()
        if !AppState.sharedInstance.signedIn
        {
            performSegueWithIdentifier("ModalLoginSegue", sender: self)
        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func configureDatabase()
    {
        ref = FIRDatabase.database().reference()
        
        // Listen for new messages from Firebase
        //  refHandle = ref.child(uniqueSessionID).observeEventType(.ChildAdded, withBlock: {
        
        /*refHandle =*/
        
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
            self.tableview.reloadData()
            self.messages.append(snapshot)
            
        //    self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.arrayOfMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
            
        })
        
        
    }
    
    
    
    
    
    
    func sendMessage(message: String?)
    {
        let completed: Bool = false
        let removeRequest: Bool = false
        if let msg = message
        {
            if msg.characters.count > 0
                
               
            {
                if let username = AppState.sharedInstance.displayName
                {
                    let messageData = Message(request: msg, name: username, completed: completed, removeRequest: removeRequest)
                    let requestRef = self.ref.child("messages").childByAutoId()
                   // requestRef.setValue(["request": msg, "name": username, "completed": completed, "removeRequest": removeRequest])
                    
                    
                    ref.child("messages").childByAutoId().setValue(["request": msg, "name": username, "completed": completed, "removeRequest": removeRequest])
                    self.arrayOfMessages.append(messageData)
                    self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.arrayOfMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
                    //Push to Firebase Database
                    
                    // ref.child(uniqueSessionID).childByAutoId().setValue(messageData)
                   // ref.child("messages").childByAutoId().setValue(messageData)
                    chatTextField.text = ""
                }
            }
        }
    }

    
    // MARK: - Tableview required methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return messages.count
        return arrayOfMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        // Unpack message from Firebase DataSnapshot
        
       // var aRequest: Message
        
       // let messageSnapshot = self.messages[indexPath.row]
        let thisRequest = self.arrayOfMessages[indexPath.row]
        
       // let aRequest: Message = Message() //  convertSnapshotToMessage(messageSnapshot)
        
//      if let newRequest = Message.convertSnapshotToMessage(messageSnapshot)
/*
        let message = messageSnapshot.value as! Dictionary<String, AnyObject>
        if let name = message["name"], let text = message["text"], let completed = message["completed"], let removeRequest = message["removeRequest"]
            
        {
*/
//      {
        
            
            //cell.requestLabel.text = newRequest.request
        cell.requestLabel.text = thisRequest.request
        
            //if newRequest.completed == true
            if thisRequest.completed == true
            {
                cell.checkButton.setImage(checkImage, forState: .Normal)
               // cell.checkButton.imageView!.image = UIImage(named: checkImageName)
            }
            else if thisRequest.completed == false
           // else if newRequest.completed == false
            {
                cell.checkButton.setImage(unCheckImage, forState: .Normal)
              //  cell.checkButton.imageView!.image = UIImage(named: unCheckImageName)
            }
//        }
        
        return cell
        
        
            
/*
            
            //cell.textLabel?.text = name + ": " + text
            cell.textLabel?.text = text as? String
            
            let fontSized = cell.textLabel?.text?.characters.count
            let tempSize  = CGFloat(40 - fontSized!)
            cell.textLabel?.font = UIFont(name: "Thonburi", size: tempSize)
            
            //            if completed as! Bool == false
            //            {
            //                cell.accessoryType = UITableViewCellAccessoryType.None
            //                cell.textLabel?.textColor = UIColor.blackColor()
            //                cell.detailTextLabel?.textColor = UIColor.blackColor()
            //            } else {
            //
            //                cell.accessoryView?.tintColor = UIColor.greenColor()
            //                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            //
            //                cell.textLabel?.textColor = UIColor.greenColor()
            //                cell.detailTextLabel?.textColor = UIColor.greenColor()
            //            }
 
        
        }
*/

        
        
    }
    
//    func prepareForReuse()
//    {
//       let cell = MessageCell()
//        cell.requestLabel.text = ""
//        cell.checkButton.setImage(unCheckImage, forState: .Normal)
//       
//    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 1
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        var aRequest: Message
      //  var foundMessage: FIRDataSnapshot?
        let snapshotToUpdate = messages[indexPath.row]
        
        

    //    aRequest = convertSnapshotToMessage(snapshotToUpdate)
    //    aRequest.completed = !aRequest.completed
        
        var updatedMessage = snapshotToUpdate.value as! Dictionary<String, AnyObject>
     //   updatedMessage = ["completed": aRequest.completed]
      //  print(aRequest.completed)
       // snapshotToUpdate.ref.updateChildValues(updatedMessage)
      //  print("line 354")
        
//        if aRequest.completed
//        {
//            cell.textLabel?.textColor = UIColor.greenColor()
//            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//            cell.accessoryView?.tintColor = UIColor.greenColor()
//            
//        }
//        else
//        {
//            cell.textLabel?.textColor = UIColor.blackColor()
//            cell.accessoryType = UITableViewCellAccessoryType.None
//        }
        
      //  let updatedRequest = Message.convertMessageToSnapshot(aRequest) as! Dictionary<String, AnyObject>
       // aRequest.convertMessageToSnapshot(aMsg: Message)

        
        // updatedMessage = ["completed": true]
        // snapshotToUpdate.ref.updateChildValues(updatedMessage)
        
        //snapshotToUpdate.ref.removeValue()
        
        //    let messageSnapshot = self.messages[indexPath.row]
        //    let message = messageSnapshot.value as! Dictionary<String, String>
        
        //    refToDelete.ref.updateChildValues(message)
   
 /*
       toggledCompletion = !toggledCompletion
        let tempBool = toggledCompletion
        updatedMessage = ["completed": tempBool]
        snapshotToUpdate.ref.updateChildValues(updatedMessage)
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
  */
        
       // tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
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
    
    
   

    func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool)
    {
        if !isCompleted {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        }
        else
        {
            
            cell.accessoryView?.tintColor = UIColor.greenColor()
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.textLabel?.textColor = UIColor.greenColor()
            cell.detailTextLabel?.textColor = UIColor.greenColor()
        }
    }
    

    @IBAction func checkTapped(sender: UIButton)
    {
        //isChecked = !isChecked
        let contentView = sender.superview
        let cell = contentView?.superview as! MessageCell
        let thisIndexPath = tableview.indexPathForCell(cell)
        
        var myDone = arrayOfMessages[thisIndexPath!.row]
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
        var updatedMessage = ["completed": myDone.completed]
        myDone.ref?.updateChildValues(updatedMessage)
        
    }
    
    
    // MARK: - Textfield delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        
        
        sendMessage(textField.text)
        
        
        return false
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
    
    
    @IBAction func sendMessageTapped(sender: UIButton)
    {
        sendMessage(chatTextField.text)
        
    }
    
    
    @IBAction func hideTapped(sender: UIButton)
    {
        
        canMoveIcons = !canMoveIcons
        if canMoveIcons
        {
            unlockLabel.setTitle("Icons Unlocked", forState: .Normal)
            unlockLabel.setTitleColor(UIColor.redColor(), forState: .Normal)
        }
        else
        {
            unlockLabel.setTitle("Icons Locked", forState: .Normal)
            unlockLabel.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
        //        if chatTextField.isFirstResponder()
        //        {
        //            chatTextField.resignFirstResponder()
        //        }
        
    }
    
    func keyboardDidShow(notification: NSNotification)
    {
        let height = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().height
        chattextFieldConstraint.constant = height! + 4
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        chattextFieldConstraint.constant = 8.0
    }
    
    
    @IBAction func iconPressed(sender: UITapGestureRecognizer)
    {
        let name = iconLabel.text
        setTextFromIcon(name!)
    }
    
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer)
    {
        // if canMoveIcons
        // {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        //  }
        
    }
    
    func setTextFromIcon(name: String)
    {
        chatTextField.text = chatTextField.text! + name
        
    }
    
    func buttonPressed(sender: UIButton)
    {
        
        chatTextField.text = chatTextField.text! + sender.currentTitle!
        // print("piano?")
        
        
        
    }
    
    @IBAction func requestTapped(sender: UIButton)
    {
        chatTextField.text = chatTextField.text! + sender.currentTitle!
        print("piano?")
        
    }
    //    func didSetSessionID(sessionIDFromLogin: String?)
    //    {
    //        if let sessIDFrmLog = sessionIDFromLogin
    //        {
    //            uniqueSessionID = sessIDFrmLog
    //        }
    //    }
    
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    //    func ignore(button: UIPress, for event: UIPressesEvent)
    //    {
    //        let myButton = UIPress.self
    //        var newPoint: CGPoint
    //        newPoint = myButton.center
    //
    //        newGuitarButton2.center = newPoint
    //
    //
    //    }
    
    func handleTap(recognizer: UITapGestureRecognizer)
    {
        let myButton = recognizer.view as! UIImageView
        //let myButton = recognizer.view as! UIButton
        var newPoint: CGPoint = (recognizer.view?.center)!
        newPoint = myButton.center
        print(newPoint)
        //        newGuitarButton2.center = newPoint
        //
        //        newGuitarButton2.updateConstraints()
        //        newGuitarButton2.center = newPoint// center = newPoint
        //        newLabel2.text = myButton.currentTitle!
        //        let tempString = myButton.currentTitle!
        //        print(tempString)
        
        let handRight = UIImage(named: "Hand Right-48.png")
        let handView = UIImageView(image: handRight)
        handView.frame = CGRect(x: newPoint.x, y: newPoint.y, width: 68, height: 68)
        self.view.addSubview(handView)
        
        // newLabel2.text = tempString
        
        myButton.frame = CGRect(x: 40, y: 40, width: 100, height: 100)
        super.viewWillLayoutSubviews()
        view.addSubview(myButton)
    }
    

}
    
    
        
//       if let updatedRequest = Message.convertSnapshotToMessage(aSnap)
//       {
//            updatedRequest.completed = !updatedRequest.completed
//            
//        
//            
//            if updatedRequest.completed == true
//            {
//                sender.setImage(checkImage, forState: .Normal)
//                
//            }
//            else if updatedRequest.completed == false
//            {
//                sender.setImage(unCheckImage, forState: .Normal)
//            }
//        
//            var updatedMessage = aSnap.value as! Dictionary<String, AnyObject>
//            let tempBool = updatedRequest.completed
//          
//            updatedMessage = ["completed": tempBool]
//            aSnap.ref.updateChildValues(updatedMessage)
//        }
        
//    }



    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        super.touchesBegan(touches, withEvent: event)
//        for touch in (touches as! Set<UITouch>)
//        {
//            let
//        }
//        let touch = touches.first
//      
//        start = touch!.locationInView(self.view)
//       
//        //location = touch.locationInView(self.view)
//    //    handLeftButton.center = start!
//        
//    }
//
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        super.touchesMoved(touches, withEvent: event)
//        let touch = touches.first
//        let end = touch!.locationInView(view)
//      //  if let start = self.start
//      //  {
//      //      handLeftButton.center = end
//      //  }
//      //  self.start = end
//       // elecGuitar.center = location
//        
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        super.touchesEnded(touches, withEvent: event)
//        let touch = touches.first
//        let end = touch!.locationInView(view)
//   //     newCenter = end
//   //     handLeftButton.center = newCenter!
//  //      print(newCenter)
//    }
    
//    func makeImage() -> UIImage
//    {
//        
//        
//        UIGraphicsBeginImageContext(self.piano.bounds.size)//  .bounds.size)
//        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
//        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return viewImage
//    }
    
    
    //      let imageToConvert = UIImage(named: "piano")
    //      let imageAsData = UIImagePNGRepresentation(imageToConvert!)
    
    // print("the piano data is: \(imageAsData!)")
    //myData = myImageData!
    
    //let myNewImage : UIImage = UIImage(data: imageAsData!)!
    
    //let aString: String = imageAsData.
    
    //        let textViewData : NSData = imageData.dataUsingEncodin(NSNonLossyASCIIStringEncoding)!
    //        let valueUniCode : String = String(data: textViewData, encoding: NSUTF8StringEncoding)!
    //        let emojData : NSData = valueUniCode.dataUsingEncoding(NSUTF8StringEncoding)!
    //        let emojString:String = String(data: emojData, encoding: NSNonLossyASCIIStringEncoding)!
    

    
    
    // MARK: - Firebase methods
    
    // When messages are added, run the withBlock
    
//    func getSessionIDFirst()
//    {
//        uniqueSessionID =
//    }
    
    
    
    
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // 1
//        ref.observeEventType(.Value, withBlock: { snapshot in
//            
//            // 2
//            var newItems = [GroceryItem]()
//            
//            // 3
//            for item in snapshot.children {
//                
//                // 4
//                let groceryItem = GroceryItem(snapshot: item as! FDataSnapshot)
//                newItems.append(groceryItem)
//            }
//            
//            // 5
//            self.items = newItems
//            self.tableView.reloadData()
//        })
//    }
    
    
    
    

    
    
    
//}

//        /*refHandle =*/

//        ref.child("messages").observeEventType(.ChildRemoved, withBlock: {
//            (snapshot) -> Void in
//
//            var foundMessage: FIRDataSnapshot?
//            for aMessage in self.messages
//            {
//                if aMessage.key == snapshot.key
//                {
//                    foundMessage = aMessage
//                    print("found this snapshot")
//                    break
//                }
//
//            }
//
//            if let index = self.messages.indexOf(foundMessage!)
//            {
//                print("gonna remove it!!")
//                self.messages.removeAtIndex(index)
//                self.tableview.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//                self.tableview.reloadData()
//            }
//
//
//        })

//        refHandle = ref.child("messages").observeEventType(.ChildChanged, withBlock: {
//            (snapshot) -> Void in
//
//            var foundMessage: FIRDataSnapshot?
//            for aMessage in self.messages
//            {
//                if aMessage.key == snapshot.key
//                {
//                    foundMessage = aMessage
//                    break
//                }
//
//            }
//
//            if let index = self.messages.indexOf(foundMessage!)
//            {
//                print("Make it green!!")
//                self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//                print("reload rows at index")
//
//
//
//                self.tableview.reloadData()
//            }
//
//
//            //            if let index = self.messages.indexOf(snapshot)
//            //            {
//            //                //self.messages.insert(snapshot, atIndex: index)
//            //                //self.messages.removeAtIndex(index + 1)
//            //                self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//            //                //   deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
//            //            }
//
//        })




//    }






//    func convertMessageToSnapshot(aMsg: Message) -> [String: AnyObject]
//    {
//
//        let name = aMsg.name
//        let request = aMsg.request
//        let completed = aMsg.completed
//        let removeRequest = aMsg.removeRequest
//
//        let messageData = ["name": name, "text": request, "completed": completed, "removeRequest": removeRequest]
//
//        return messageData as! [String : AnyObject]
//
//    }

//    func convertSnapshotToMessage(aSnap: FIRDataSnapshot) -> Message
//    {
//        let aMessage = Message()
//        let message = aSnap.value as! Dictionary<String, AnyObject>
//        if let name = message["name"], let request = message["text"], let completed = message["completed"], let removeRequest = message["removeRequest"]
//        {
//            aMessage.name = name as! String
//            aMessage.request = request as! String
//            aMessage.completed = completed as! Bool
//            aMessage.removeRequest = removeRequest as! Bool
//        }
//        return aMessage
//    }


