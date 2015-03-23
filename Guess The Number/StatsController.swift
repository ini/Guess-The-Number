//
//  StatsController.swift
//  Guess The Number
//
//  Created by Ini on 3/21/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import Foundation
import UIKit

class StatsController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    let defaults = NSUserDefaults.standardUserDefaults()
    var stats = NSUserDefaults.standardUserDefaults().dictionaryForKey("stats")
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var
    averageLabel: UILabel!
    @IBOutlet weak var worstLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        bestLabel.text = String(defaults.integerForKey("fewestGuesses"))
        worstLabel.text = String(defaults.integerForKey("mostGuesses"))
        println(defaults.doubleForKey("averageScore"))
        averageLabel.text = NSString(format: "%.3g", defaults.doubleForKey("averageScore"))
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (stats?.count != nil)
        {
            println(stats!.count)
            return stats!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        let arrayOfGuesses = sorted(stats?.keys.array as [String], {
            (str1: String, str2: String) -> Bool in
            return str1.toInt() < str2.toInt()
        })
        var guesses : String
        if (arrayOfGuesses[indexPath.row] == "1")
        {
            guesses = "1 Guess : "
        }
        else
        {
            guesses = arrayOfGuesses[indexPath.row] + " Guesses : "
        }
        
        var numTimes : String
        if (stats?[arrayOfGuesses[indexPath.row]] as Int == 1)
        {
            numTimes = "Once"
        }
        else if (stats?[arrayOfGuesses[indexPath.row]] as Int == 2)
        {
            numTimes = "Twice"
        }
        else
        {
            numTimes = String(stats?[arrayOfGuesses[indexPath.row]] as Int) + " Times"
        }
        cell.textLabel?.text = guesses + numTimes
        cell.textLabel?.font = bestLabel.font.fontWithSize(25)
        cell.textLabel?.textColor = bestLabel.textColor
        return cell
    }
    
    @IBAction func back(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
