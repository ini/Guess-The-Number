//
//  AppDelegate.swift
//  Guess The Number
//
//  Created by Ini on 3/18/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?
    var voiceGen: OELanguageModelGenerator = OELanguageModelGenerator()
    var lmPath: String? = nil;
    var dicPath: String? = nil;
    
    func setupVoiceGen()
    {
        var words: [String] = []
        for index in 1 ... 100
        {
            words.append(String(index))
        }
        var name = "NameIWantForMyLanguageModelFiles"
        var err = voiceGen.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        if(err == nil)
        {
            lmPath = voiceGen.pathToSuccessfullyGeneratedLanguageModelWithRequestedName("NameIWantForMyLanguageModelFiles")
            dicPath = voiceGen.pathToSuccessfullyGeneratedDictionaryWithRequestedName("NameIWantForMyLanguageModelFiles")
        }
        else
        {
            println("Error: %@", err.localizedDescription);
        }
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        downloadMessages()
        setupVoiceGen()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func downloadMessages()
    {
        // Retrieves message text files from the internet
        var strMessages = String(contentsOfURL: NSURL(string: "http://sites.google.com/site/insidevelopment/home/messages.txt")!, encoding: NSUTF8StringEncoding, error: nil)
        var strMessagesWrongRange = String(contentsOfURL: NSURL(string: "http://sites.google.com/site/insidevelopment/home/messagesWrongRange.txt")!, encoding: NSUTF8StringEncoding, error: nil)
        var strVictoryMessages = String(contentsOfURL: NSURL(string: "http://sites.google.com/site/insidevelopment/home/victoryMessages.txt")!, encoding: NSUTF8StringEncoding, error: nil)
        
        if (strMessages != nil)
        {
            strMessages?.writeToFile(NSBundle.mainBundle().pathForResource("Messages", ofType: "txt")!, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
        if (strMessagesWrongRange != nil)
        {
            strMessagesWrongRange?.writeToFile(NSBundle.mainBundle().pathForResource("MessagesWrongRange", ofType: "txt")!, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
        if (strVictoryMessages != nil)
        {
            strVictoryMessages?.writeToFile(NSBundle.mainBundle().pathForResource("VictoryMessages", ofType: "txt")!, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
    }
}

