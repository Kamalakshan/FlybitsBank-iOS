//
//  Utilities.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-20.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit
import FlybitsSDK

class Utilities {
    // MARK: - Constants
    struct Constants {
        static let LoadingView = "LoadingView"
    }

    // MARK: - Enums
    enum LayoutDirection: String {
        case Horizontal = "H"
        case Vertical   = "V"
    }

    // MARK: - Properties
    static var loadingView: LoadingView = {
        guard let views = NSBundle.mainBundle().loadNibNamed(Constants.LoadingView, owner: nil, options: nil), loadingView = views.first as? LoadingView else {
            return LoadingView()
        }
        return loadingView
    }()

    static let flybitsBlue: UIColor = {
        return UIColor(red: 17/255.0, green: 109/255.0, blue: 190/255.0, alpha: 1.0)
    }()

    static let androidLightGray: UIColor = {
        return UIColor(red: 219/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1.0)
    }()

    static let androidDarkGray: UIColor = {
        return UIColor(red: 118/255.0, green: 118/255.0, blue: 118/255.0, alpha: 1.0)
    }()

    static let flybitsFont: UIFont = {
        return UIFont(name: "flybits-generic-icons", size: 18)!
    }()

    // MARK: - NSLayoutConstraint Functions
    static func fullContainerConstraints(view: UIView, withInset inset: CGSize = CGSize.zero) -> [NSLayoutConstraint] {
        let horizontalConstraints = fullContainerConstraints(view, withInset: inset.width, forDirection: .Horizontal)
        let verticalConstraints = fullContainerConstraints(view, withInset: inset.height, forDirection: .Vertical)

        return horizontalConstraints + verticalConstraints
    }

    static func fullContainerConstraints(view: UIView, withInset inset: CGFloat) -> [NSLayoutConstraint] {
        let horizontalConstraints = fullContainerConstraints(view, withInset: inset, forDirection: .Horizontal)
        let verticalConstraints = fullContainerConstraints(view, withInset: inset, forDirection: .Vertical)

        return horizontalConstraints + verticalConstraints
    }

    static func fullContainerConstraints(view: UIView, withInset inset: CGFloat, forDirection direction: LayoutDirection) -> [NSLayoutConstraint] {
        let format = "\(direction.rawValue):|-\(inset)-[view]-\(inset)-|"
        let views = ["view" : view]
        return NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
    }

    // MARK: - Loading Functions
    static func loadAndCrossfadeImage(imageView: UIImageView, image: Image, duration: NSTimeInterval = 0.2) {
        if let image = image.loadedImage() {
            transitionImage(imageView, image: image, duration: duration)
        } else {
            image.loadImage { (image, error) in
                guard let uiImage = image.loadedImage() where error == nil else {
                    return
                }
                transitionImage(imageView, image: uiImage, duration: duration)
            }
        }
    }

    static func loadAndCrossfadeImage(imageView: UIImageView, imageURL: NSURL, duration: NSTimeInterval = 0.2) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, _, error) in
            guard let imageData = data, image = UIImage(data: imageData) where error == nil else {
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                Utilities.transitionImage(imageView, image: image)
            }
        }
        task.resume() // TODO: (TL) Cancel option?
    }

    static func loadImage(button: UIButton, state: UIControlState, imageURL: NSURL, duration: NSTimeInterval = 0.2) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, _, error) in
            guard let imageData = data, image = UIImage(data: imageData) where error == nil else {
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                button.setImage(image, forState: state)
            }
        }
        task.resume() // TODO: (TL) Cancel option?
    }

    static func transitionImage(imageView: UIImageView, image: UIImage, duration: NSTimeInterval = 0.2, completion: ((finished: Bool) -> Void)? = nil) {
        UIView.transitionWithView(imageView, duration: duration, options: .TransitionCrossDissolve, animations: {
            imageView.image = image
        }, completion: completion)
    }

    // MARK: - Component Functions
    static func viewForKind(kind: Component.Kind) -> DynamicView? {
        guard let view = NSBundle.mainBundle().loadNibNamed(kind.nibName, owner: nil, options: nil).first as? DynamicView else {
            return nil
        }
        return view
    }
}
