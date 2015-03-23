//
//  VictoryController.swift
//  Guess The Number
//
//  Created by Ini on 3/19/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import Foundation
import UIKit

class VictoryController: UIViewController
{
    
    @IBOutlet weak var newRecord: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var victoryMessageLabel: UILabel!
    
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
    
    @IBAction func playAgain(sender: AnyObject) {
        let main = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Main") as ViewController
        presentViewController(main, animated: false, completion: nil)
        main.numGen.generateNewNumber()
    }
}

