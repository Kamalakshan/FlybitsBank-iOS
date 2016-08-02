//
//  LoadingView.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-27.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    // MARK: - Constants
    struct Constants {
        static let RotationAnimation = "com.flybits.rotation"
        static let ZRotation = "transform.rotation.z"
        static let LoadingImageName = "Loading-Half-Circle"
        static let LoadingImage = UIImage(named: Constants.LoadingImageName)!.imageWithRenderingMode(.AlwaysTemplate)
        static let AnimationDuration = 0.2
    }

    // MARK: - IBOutlets
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var loadingImageView: UIImageView!

    // MARK: - IBDesignable Outlets
    @IBInspectable var transitionStartColor: UIColor!
    @IBInspectable var transitionEndColor: UIColor!

    // MARK: - Lifecycle Functions
    override func awakeFromNib() {
        translatesAutoresizingMaskIntoConstraints = false
        loadingImageView.image = Constants.LoadingImage
    }

    // MARK: - Functions
    func addToView(view: UIView?) {
        guard let view = view else {
            return
        }

        logoImageView.image = DataCache.sharedCache.appConfig?.image.loadedImage()
        loadingImageView.tintColor = DataCache.sharedCache.appConfigColor

        backgroundColor = transitionStartColor
        view.addSubview(self)

        let constraints = Utilities.fullContainerConstraints(self)
        view.addConstraints(constraints)

        startLoadingAnimation()

        UIView.animateWithDuration(Constants.AnimationDuration) {
            self.backgroundColor = self.transitionEndColor
        }
    }

    func removeFromView() {
        guard superview != nil else {
            backgroundColor = transitionStartColor
            return
        }

        UIView.animateWithDuration(Constants.AnimationDuration, animations: {
            self.backgroundColor = self.transitionStartColor
        }) { (finished) in
            self.removeFromSuperview()
            self.stopLoadingAnimation()
        }
    }

    private func startLoadingAnimation() {
        let animation = CABasicAnimation(keyPath: Constants.ZRotation)
        animation.duration = M_PI/3
        animation.repeatCount = MAXFLOAT
        animation.toValue = M_PI * 2
        animation.fromValue = 0
        loadingImageView.layer.addAnimation(animation, forKey: Constants.RotationAnimation)
    }

    private func stopLoadingAnimation() {
        loadingImageView.layer.removeAnimationForKey(Constants.RotationAnimation)
    }
}
