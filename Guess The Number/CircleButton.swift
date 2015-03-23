//
//  CircleButton.swift
//  Guess The Number
//
//  Created by Ini on 3/18/15.
//  Copyright (c) 2015 Insi Productions. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

class CircleButton: UIButton
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var length = (self.frame.width + self.frame.height) / 2
        let constraint = NSLayoutConstraint(item: self,     //make button square (aspect ratio 1:1)
            attribute: .Width,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Height,
            multiplier: 1.0,
            constant: 0.0);
        self.addConstraint(constraint);
        self.layer.cornerRadius = self.frame.width / 2      //make button circular (rounded corners)
    }
}

