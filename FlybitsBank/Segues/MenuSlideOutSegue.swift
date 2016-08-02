//
//  MenuSlideOutSegue.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-20.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class MenuSlideOutSegue: UIStoryboardSegue {
    override func perform() {
        let sourceView = sourceViewController.view

        // Get the screen width and height.
        let finalFrame = sourceView.frame.offsetBy(dx: -sourceView.frame.width, dy: 0)

        // Animate the transition
        UIView.animateWithDuration(0.4, animations: {
            sourceView.frame = finalFrame
        }) { (finished) in
            self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
