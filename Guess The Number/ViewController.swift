//
//  ViewController.swift
//  Guess The Number
//
//  Created by Ini on 3/18/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import UIKit
import Foundation
import iAd

class NumberGenerator
{
    var randomInteger = 0
    var min = 0
    var max = 0
    var numGuesses = 0
    
    //creates arrays of messages from saved text files
    var messages = String(contentsOfFile: NSBundle.mainBundle().pathForResource("Messages", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)?.componentsSeparatedByString("\n")
    var messagesWrongRange = String(contentsOfFile: NSBundle.mainBundle().pathForResource("MessagesWrongRange", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)?.componentsSeparatedByString("\n")
    var victoryMessages = String(contentsOfFile: NSBundle.mainBundle().pathForResource("VictoryMessages", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)?.componentsSeparatedByString("\n")
    
    init(minimum: Int, maximum: Int)
    {
        min = minimum
        max = maximum
        randomInteger = randomInt(min, max: max)
    }
    
    func randomInt(min: Int, max: Int) -> Int
    {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func guess(guessedNumber:Int) -> (Bool, Int)
    {
        numGuesses++
        if guessedNumber > max || guessedNumber < min
        {
            return (false, 2)
        }
        else if randomInteger < guessedNumber
        {
            return (false, -1)
        }
        else if randomInteger > guessedNumber
        {
            return (false, 1)
        }
        return (true, 0)
    }
    
    func generateNewNumber()
    {
        var num = randomInt(min, max: max + 1)
        if min <= 42 && max >= 42 && num == max + 1
        {
            num = 42 // Bias towards the number 42.
        }
        randomInteger = num
        numGuesses = 0
    }
    
    func message(type: Int) -> String
    {
        switch type
        {
            case -2: // You guessed the number
                return victoryMessages![randomInt(0, max: victoryMessages!.count - 1)]
            case -1: // You guessed too high
                return messages![randomInt(0, max: messages!.count - 1)].stringByReplacingOccurrencesOfString("/direction/", withString: "lower", options: NSStringCompareOptions(), range: nil)
            case 1: // You guessed too low
                return messages![randomInt(0, max: messages!.count - 1)].stringByReplacingOccurrencesOfString("/direction/", withString: "higher", options: NSStringCompareOptions(), range: nil)
            case 2: // You guessed in the wrong range
                return messagesWrongRange![randomInt(0, max: messagesWrongRange!.count - 1)]
            default:
                return ""
        }
    }
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var guessLabel: UILabel!
    @IBOutlet weak var textbox: UITextField!
    var numGen = NumberGenerator(minimum: 1, maximum: 100)
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        println(defaults.dictionaryForKey("stats"))
        addGuessButtonOnKeyboard()
        canDisplayBannerAds = true
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
    
    @IBAction func infoClicked(sender: AnyObject)
    {
        let options = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Options") as OptionController
        presentViewController(options, animated: true, completion: nil)
    }
    
    @IBAction func dismissNumPad(sender: AnyObject)
    {
        if textbox.isFirstResponder()
        {
            self.view.endEditing(true)
            guessButtonAction()
        }
    }
    
    func addGuessButtonOnKeyboard()
    {
        var guessToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        guessToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Guess", style: UIBarButtonItemStyle.Done, target: self, action: Selector("guessButtonAction"))
        
        var items = NSMutableArray()
        items.addObject(flexSpace)
        items.addObject(done)
        
        guessToolbar.items = items
        guessToolbar.sizeToFit()
        textbox.inputAccessoryView = guessToolbar
    }
    
    func guessButtonAction()
    {
        self.textbox.resignFirstResponder()
        var numGuess = textbox.text.toInt()
        if numGuess != nil //increments guessLabel and tests to see if number was guessed
        {
            var result = numGen.guess(numGuess!)
            if numGen.numGuesses == 1
            {
                guessLabel.text = "1 Guess"
            }
            else
            {
                guessLabel.text = String(numGen.numGuesses) + " Guesses"
            }
            if result.0
            {
                victory()
            }
            var message = numGen.message(result.1)
            while messageLabel.text == message
            {
                message = numGen.message(result.1)
            }
            if (message != "")
            {
                messageLabel.text = message
            }
        }
        else
        {
            textbox.text = "" // clears textfield if guess is not a number
        }
    }
    
    @IBAction func guessed(sender: AnyObject)
    {
        textbox.becomeFirstResponder()
    }
    @IBAction func clearText(sender: AnyObject)
    {
        textbox.text = ""
    }
    
    func victory()
    {
        var newAverage : Double = (defaults.doubleForKey("averageScore") * Double(defaults.integerForKey("timesPlayed")) + Double(numGen.numGuesses)) / Double(defaults.integerForKey("timesPlayed") + 1)
        defaults.setDouble(newAverage, forKey: "averageScore")
        defaults.setInteger(defaults.integerForKey("timesPlayed") + 1, forKey: "timesPlayed")
        
        var stats : [String : Int]
        if defaults.dictionaryForKey("stats") == nil
        {
            stats = [String(numGen.numGuesses) : 1]
        }
        else
        {
            stats = defaults.dictionaryForKey("stats") as [String: Int]!
            if defaults.dictionaryForKey("stats") == nil || stats[String(numGen.numGuesses)] == nil
            {
                stats[String(numGen.numGuesses)] = 1
            }
            else
            {
                stats[String(numGen.numGuesses)] = stats[String(numGen.numGuesses)]! + 1
            }
        }
        defaults.setObject(stats, forKey:"stats")
        println(defaults.dictionaryForKey("stats"))
        
        
        let victory = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Victory") as VictoryController
        presentViewController(victory, animated: false, completion: nil)
        
        if (numGen.numGuesses == 1)
        {
            victory.winLabel.text = "You got it after 1 guess."
        }
        else
        {
            victory.winLabel.text = "You got it after " + String(numGen.numGuesses) + " guesses."
        }
        
        if defaults.integerForKey("fewestGuesses") > numGen.numGuesses || defaults.integerForKey("fewestGuesses") == 0
        {
            defaults.setInteger(numGen.numGuesses, forKey: "fewestGuesses")
            victory.newRecord.hidden = false
        }
        else
        {
            victory.newRecord.hidden = true
        }
        
        if defaults.integerForKey("mostGuesses") < numGen.numGuesses || defaults.integerForKey("mostGuesses") == 0
        {
            defaults.setInteger(numGen.numGuesses, forKey: "mostGuesses")
        }
        
        victory.victoryMessageLabel.text = numGen.message(-2)
        victory.scoreLabel.text = String(numGen.numGuesses)
        victory.bestLabel.text = String(defaults.integerForKey("fewestGuesses"))
    }
    
}

