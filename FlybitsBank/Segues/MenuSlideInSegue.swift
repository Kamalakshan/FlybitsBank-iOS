//
//  MenuSlideInSegue.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-20.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class MenuSlideInSegue: UIStoryboardSegue {
    override func perform() {
        let firstVCView = sourceViewController.view
        let secondVCView = destinationViewController.view

        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)

        // Get the screen width and height.
        let finalFrame = CGRect(origin: CGPoint.zero, size: UIScreen.mainScreen().bounds.size)
        secondVCView.frame = finalFrame.offsetBy(dx: -finalFrame.width, dy: 0)

        // Animate the transition
        UIView.animateWithDuration(0.4, animations: {
            secondVCView.frame = finalFrame
        }) { (finished) in
            self.sourceViewController.presentViewController(self.destinationViewController, animated: false, completion: nil)
        }
    }
}
