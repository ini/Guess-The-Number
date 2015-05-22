//
//  StatsController.swift
//  Guess The Number
//
//  Created by Ini on 3/21/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import Foundation
import UIKit

class StatsController: UIViewController
{
    let defaults = NSUserDefaults.standardUserDefaults()
    var stats = NSUserDefaults.standardUserDefaults().dictionaryForKey("stats")
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var
    averageLabel: UILabel!
    @IBOutlet weak var worstLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        bestLabel.text = String(defaults.integerForKey("fewestGuesses"))
        worstLabel.text = String(defaults.integerForKey("mostGuesses"))
        averageLabel.text = NSString(format: "%.3g", defaults.doubleForKey("averageScore")) as String
        if stats != nil
        {
            loadBarChartUsingArray()
        }
        else
        {
            var noStats: UILabel = UILabel(frame: CGRectMake(10, barChart.origin.y, self.view.width - 20, barChart.height))
            noStats.text = "Try playing the game first before trying to look at your stats, Einstein."
            noStats.font = bestLabel.font.fontWithSize(30)
            noStats.textColor = bestLabel.textColor
            noStats.textAlignment = .Center
            noStats.lineBreakMode = NSLineBreakMode.ByWordWrapping
            noStats.numberOfLines = 5
            self.view.addSubview(noStats)
            barChart.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    func loadBarChartUsingArray()
    {
        var titles = sorted(stats?.keys.array as! [String], {
            (str1: String, str2: String) -> Bool in
            return str1.toInt() < str2.toInt()
        })
        var values : [String] = [], labelColors = [String](count: stats!.count, repeatedValue: "308034"), colors = labelColors
        for index in 0 ... stats!.count - 1
        {
            var val = stats?[titles[index]] as! Int
            if Double(val) > barChart.maximum
            {
                barChart.maximum = Double(val)
            }
            values.append(String(val))
        }

        var array = barChart.createChartDataWithTitles(titles, values: values, colors: colors, labelColors: labelColors)
        barChart.setupBarViewShape(BarShapeRounded)
        barChart.setupBarViewStyle(BarStyleFlat)
        barChart.setupBarViewShadow(BarShadowNone)
        barChart.setDataWithArray(array, showAxis: DisplayBothAxes, withColor: UIColor(red: 48.0/255.0, green: 128.0/255.0, blue: 52.0/255.0, alpha: 1.0), shouldPlotVerticalLines: true)
    }
    
    func loadbarChartUsingXML()
    {
        barChart.setupBarViewShape(BarShapeRounded)
        barChart.setupBarViewStyle(BarStyleFlat)
        barChart.setupBarViewShadow(BarShadowNone)
        barChart.setXmlData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("barChart", ofType: "xml")!), showAxis: DisplayBothAxes, withColor: UIColor.clearColor(), shouldPlotVerticalLines: true)
    }
    
    @IBAction func back(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
