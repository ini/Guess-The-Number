//
//  ViewController.swift
//  Guess The Number
//
//  Created by Ini on 3/18/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import UIKit
import iAd
import Foundation

class NumberGenerator
{
    var randomInteger = 0
    var min = 0
    var max = 0
    var guessRangeMin = 0
    var guessRangeMax = 0
    var numGuesses = 0
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Creates arrays of messages from saved text files
    var messages = String(contentsOfFile: NSBundle.mainBundle().pathForResource("Messages", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!.componentsSeparatedByString("\n")
    var messagesWrongRange = String(contentsOfFile: NSBundle.mainBundle().pathForResource("MessagesWrongRange", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!.componentsSeparatedByString("\n")
    var victoryMessages = String(contentsOfFile: NSBundle.mainBundle().pathForResource("VictoryMessages", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!.componentsSeparatedByString("\n")
    
    init(minimum: Int, maximum: Int)
    {
        min = minimum
        max = maximum
        guessRangeMin = min
        guessRangeMax = max
        
        if defaults.dictionaryForKey("guessHistory")?.count == nil
        {
            // Creates default dictionary of stored guesses
            var guessHistory : [String: Int] = [:]
            for index in min ... max
            {
                guessHistory[String(index)] = 1
            }
            defaults.setObject(guessHistory, forKey: "guessHistory")
        }
        
        generateNewNumber()
    }
    
    func randomInt(min: Int, max: Int) -> Int
    {
        // Generates random number within the given range, inclusive
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func guess(guessedNumber:Int) -> (Bool, Int)
    {
        numGuesses++
        var guessHistory = defaults.objectForKey("guessHistory") as! [String: Int]
        if guessedNumber >= min && guessedNumber <= max
        {
            guessHistory[String(guessedNumber)] = guessHistory[String(guessedNumber)]! + 1
        }
        defaults.setObject(guessHistory, forKey: "guessHistory")
        
        if guessedNumber > max || guessedNumber < min
        {
            return (false, 2)
        }
        else if randomInteger < guessedNumber
        {
            guessRangeMax = guessedNumber - 1
            return (false, -1)
        }
        else if randomInteger > guessedNumber
        {
            guessRangeMin = guessedNumber + 1
            return (false, 1)
        }
        println(String(guessRangeMin) + ", " + String(guessRangeMax))
        return (true, 0)
    }
    
    // Algorithm that, based on past history of guesses, generates numbers that the user is unlikely to guess.
    func generateNewNumber() -> Int
    {
        var num = 0, sum = 0, cumulative = min - 1, largest = 0, guessHistory = defaults.objectForKey("guessHistory") as! [String: Int]
        for (guess, number) in guessHistory
        {
            if largest < number
            {
                largest = number
            }
        }

        for index in min ... max
        {
            sum += largest + 1 - guessHistory[String(index)]!
        }
        
        num = randomInt(min, max: min + sum - 1)

        // Uses uniform probability distribution to generates a random number with the probability generating any specific number inversely proportional to the frequency at which the number has been guessed
        for index in min ... max
        {
            cumulative += largest + 1 - guessHistory[String(index)]!
            if num <= cumulative
            {
                num = index
                break
            }
        }
        
        randomInteger = num
        numGuesses = 0
        println(num)
        return num
    }
    
    func message(type: Int) -> String
    {
        switch type
        {
            case -2: // You guessed the number
                return victoryMessages[randomInt(0, max: victoryMessages.count - 1)]
            case -1: // You guessed too high
                return messages[randomInt(0, max: messages.count - 1)].stringByReplacingOccurrencesOfString("/direction/", withString: "lower", options: NSStringCompareOptions(), range: nil)
            case 1: // You guessed too low
                return messages[randomInt(0, max: messages.count - 1)].stringByReplacingOccurrencesOfString("/direction/", withString: "higher", options: NSStringCompareOptions(), range: nil)
            case 2: // You guessed in the wrong range
                return messagesWrongRange[randomInt(0, max: messagesWrongRange.count - 1)]
            default:
                return ""
        }
    }
    
}

class ViewController: UIViewController, OEEventsObserverDelegate
{
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var guessLabel: UILabel!
    @IBOutlet weak var textbox: UITextField!
    @IBOutlet weak var guessButton: CircleButton!

    var numGen = NumberGenerator(minimum: 1, maximum: 100)
    var openEarsEventsObserver = OEEventsObserver()
    var timer: NSTimer = NSTimer()
    var held: Bool = false
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        openEarsEventsObserver.delegate = self
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
        let options = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Options") as! OptionController
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
        
        guessToolbar.items = items as [AnyObject]
        guessToolbar.sizeToFit()
        textbox.inputAccessoryView = guessToolbar
    }
    
    func guessButtonAction()
    {
        self.textbox.resignFirstResponder()
        var numGuess = textbox.text.toInt()
        if numGuess != nil //increments guessLabel and tests to see if the correct number was guessed
        {
            var result = numGen.guess(numGuess!)
            println(String(numGen.guessRangeMin) + ", " + String(numGen.guessRangeMax))

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
    
    @IBAction func guessHeld(sender: AnyObject)
    {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("voice"), userInfo: nil, repeats: false)
        self.textbox.text = ""
        if OEPocketsphinxController.sharedInstance().isListening
        {
            OEPocketsphinxController.sharedInstance().stopListening()
        }
    }
    
    @IBAction func guessed(sender: AnyObject)
    {
        timer.invalidate()
        if !held
        {
            textbox.becomeFirstResponder()
            if OEPocketsphinxController.sharedInstance().isListening
            {
                OEPocketsphinxController.sharedInstance().stopListening()
            }
        }
        held = false
    }
    
    @IBAction func clearText(sender: AnyObject)
    {
        textbox.text = ""
    }
    
    func voice()
    {
        held = true
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        OEPocketsphinxController.sharedInstance().setActive(true, error: nil)
        OEPocketsphinxController.sharedInstance().stopListening()
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(appDelegate.lmPath, dictionaryAtPath: appDelegate.dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
        
        self.guessButton.setTitle("", forState: .Normal)
        self.guessButton.setBackgroundImage(UIImage(named: "microphone"), forState: .Highlighted)
        self.guessButton.setBackgroundImage(UIImage(named: "microphone"), forState: .Normal)
    }
    
    func victory()
    {
        // Update average score
        var newAverage : Double = (defaults.doubleForKey("averageScore") * Double(defaults.integerForKey("timesPlayed")) + Double(numGen.numGuesses)) / Double(defaults.integerForKey("timesPlayed") + 1)
        defaults.setDouble(newAverage, forKey: "averageScore")
        defaults.setInteger(defaults.integerForKey("timesPlayed") + 1, forKey: "timesPlayed")
        
        // Update stats
        var stats : [String : Int]
        if defaults.dictionaryForKey("stats") == nil
        {
            stats = [String(numGen.numGuesses) : 1]
        }
        else
        {
            stats = defaults.dictionaryForKey("stats") as! [String: Int]!
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
        
        // Opens victory screen with numbers and a message
        let victory = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Victory") as! VictoryController
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
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!)
    {
        println("The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID)
        self.textbox.text = hypothesis
        OEPocketsphinxController.sharedInstance().stopListening()
    }
    
    func pocketsphinxDidStartListening()
    {
        println("Pocketsphinx is now listening.")
    }
    
    func pocketsphinxDidDetectSpeech()
    {
        println("Pocketsphinx has detected speech.")
    }
    
    func pocketsphinxDidDetectFinishedSpeech()
    {
        println("Pocketsphinx has detected a period of silence, concluding an utterance.")
    }
    
    func pocketsphinxDidStopListening()
    {
        println("Pocketsphinx has stopped listening.")
        guessButtonAction()
        self.guessButton.setBackgroundImage(nil, forState: .Normal)
        self.guessButton.setBackgroundImage(nil, forState: .Highlighted)
        self.guessButton.setTitle("Guess", forState: .Normal)
    }
    
    func pocketsphinxDidSuspendRecognition()
    {
        println("Pocketsphinx has suspended recognition.")
    }
    
    func pocketsphinxDidResumeRecognition()
    {
        println("Pocketsphinx has resumed recognition.")
    }
    
    func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!)
    {
        println("Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString)
    }
    
    func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String!)
    {
        println("Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure)
    }
    
    func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String!)
    {
        println("Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure)
    }
    
    func testRecognitionCompleted()
    {
        println("A test file that was submitted for recognition is now complete.");
    }
}

