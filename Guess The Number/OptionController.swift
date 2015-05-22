//
//  VictoryController.swift
//  Guess The Number
//
//  Created by Ini on 3/19/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import Foundation
import UIKit

class OptionController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    @IBAction func `continue`(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func resetScores(sender: AnyObject)
    {
        var areYouSureAlert = UIAlertController(title: "Are you sure?", message: "All of your game data will be deleted.", preferredStyle: .Alert)
        let yes = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in self.actuallyResetScores() })
        let no = UIAlertAction(title: "No", style: .Cancel) { (action) -> Void in}
        areYouSureAlert.addAction(yes); areYouSureAlert.addAction(no)
        presentViewController(areYouSureAlert, animated: true, completion: nil)
    }
    
    func actuallyResetScores()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        for (key, object) in defaults.dictionaryRepresentation() as! [String: AnyObject]
        {
            defaults.setObject(nil, forKey: key)
        }
        var alert = UIAlertController(title: "Reset Scores", message: "All of your scores have been cleared.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    @IBAction func back(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

