//
//  LayoutViewController.swift
//  TwoCans2
//
//  Created by Gregory Weiss on 9/24/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

import UIKit
import Firebase

//protocol PickMusicianDelegate
//{
//    func musicianWasChosen(pickedMusician: Musician)
//}


class LayoutViewController: UIViewController//, PickMusicianDelegate,  UIGestureRecognizerDelegate
{
    var arrayOfMusicians: [Musician] = []
    var location = CGPoint(x: 0, y: 0)
    

    @IBOutlet weak var newTextField: UITextField!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        configureMusicians()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        reloadMusicians()
    }
    
    func configureMusicians()
    {
        
    }
    
    func setUpMusiciansForLayout()
    {
        
    }
    
    func reloadMusicians()
    {
       for item in arrayOfMusicians
       {
            if item.doesExist == false
            {
            let aButton = UIButton()
            aButton.frame = CGRect(x: item.positionX, y: item.positionY, width: item.width + 10, height: item.height)
            aButton.setImage(UIImage(named: item.iconImage), forState: .Normal)
            aButton.setTitle(item.name, forState: .Normal)
            aButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
                
            aButton.tag = item.uniqueID
            self.view.addSubview(aButton)
                let panGesture = UIPanGestureRecognizer()
              //  panGesture.delegate = self
                aButton.addGestureRecognizer(panGesture)
                aButton.addTarget(self, action: #selector(buttonDragged), forControlEvents: .TouchDragInside)
                let aLabel = UILabel()
                aLabel.frame = CGRect(x: item.positionX, y: item.positionY - 15, width: item.width, height: 15)
                aLabel.text = item.name
                aLabel.textColor = UIColor.blackColor()
                self.view.addSubview(aLabel)
             item.doesExist = true
            print("\(arrayOfMusicians.count)")
            }
        }
    }
    
    func buttonPressed(sender: UIButton)
    {
        
        newTextField.text = newTextField.text! + " " + sender.currentTitle!
        // print("piano?")
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch =  touches.first{
            location = touch.locationInView(self.view)
            print("\(touch)")
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
            location = touch.locationInView(self.view)
            print("\(touch)")
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
            location = touch.locationInView(self.view)
            print("\(touch)")
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    
    
    //func buttonDragged(recognizer:UIPanGestureRecognizer)
    func buttonDragged(button: UIButton, event: UIEvent)
    {
//        // get the touch
//        let translation = recognizer.translationInView(self.view)
//        if let view = recognizer.view {
//            view.center = CGPoint(x:view.center.x + translation.x,
//                                  y:view.center.y + translation.y)
//        }
//        recognizer.setTranslation(CGPointZero, inView: self.view)

        let touch = event.touchesForView(button)!.first!  //touches(forView: button)!.first!
        // get delta
        let previousLocation = touch.previousLocationInView(button)//    .previousLocation(inView: button)
        let location = touch.locationInView(button)   //.location(inView: button)
        let delta_x: CGFloat = location.x - previousLocation.x
        let delta_y: CGFloat = location.y - previousLocation.y
        // move button
        button.center = CGPoint(x: button.center.x + delta_x, y: button.center.y + delta_y)
    
    }
    
    func musicianWasChosen(pickedMusician: Musician)
    {
       // dismiss(animated: true, completion: nil)
        
        arrayOfMusicians.append(pickedMusician)
        //remainingTimeZones.remove(at: theIndex)
        //tableView.reloadData()
        
    }


    @IBAction func configureBarButtonTapped(sender: UIBarButtonItem)
    {
//        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ConfigTableView")
//        self.showViewController(vc as! LayoutConfigTableViewController, sender: vc)
//      //  vc.delegate = self
//
//        
    }
    
    
    // MARK: - Navigation

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
//    {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "ConfigureSegue"
//        {
//            let pickVC = segue.destinationViewController as! LayoutConfigTableViewController
//            pickVC.delegate = self
//        }
//
//    }
    

}
