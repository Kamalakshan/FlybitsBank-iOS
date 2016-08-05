//
//  MainHeaderView.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-05.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit
import FlybitsSDK // TODO: (TL) Can we remove this?

protocol MainHeaderViewDelegate {
    func headerViewFilterAction(headerView: MainHeaderView)
}

class MainHeaderView: UIView {

    // MARK: - IBOutlets
    @IBOutlet var blurredImageView: UIImageView!
    @IBOutlet var colourOverlayView: UIView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userPersonaLabel: UILabel!
    @IBOutlet var bottomBarView: UIView!
    @IBOutlet var filterButton: UIButton!

    // MARK: - NSLayoutConstraints
    @IBOutlet var branchesHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var offersHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var gradientButtons: [UIButton]!

    // MARK: - Properties
    var delegate: MainHeaderViewDelegate?
    let gradientColors = [
        // Events
        "#FFFF00FF".uiColor!,
        "#FBB03BFF".uiColor!,
        // Branches
        "#6CC4D8FF".uiColor!,
        "#1D81C4FF".uiColor!,
        // Offers
        "#92298DFF".uiColor!,
        "#662D91FF".uiColor!,
    ]
    var minHeight: CGFloat {
        return bottomBarView?.frame.height ?? 0
    }

    // MARK: - Lifecycle Functions
    override func layoutSubviews() {
        super.layoutSubviews()

        updateBackgroundImage()
        updateUserDetails()
        layoutGradientButtons()
    }

    // MARK: - UI Helpers
    private func updateBackgroundImage() {
        // TODO: (TL) The background image doesn't seem to relate to anything ...
        colourOverlayView.backgroundColor = DataCache.sharedCache.appConfigColor
    }

    private func updateUserDetails() { // TODO: (TL) Listen for user changes?
        guard let currentUser = DataCache.sharedCache.currentUser else {
            return // Nothing to do!
        }
        userNameLabel.text = currentUser.name
        userPersonaLabel.text = currentUser.persona
        if let image = currentUser.image {
            Utilities.loadAndCrossfadeImage(userImageView, image: image)
        }
    }

    private func layoutGradientButtons() {
        let quarterWidth = frame.width / 4
        let thirdButtonWidth = gradientButtons.first!.frame.width / 3
        let offset = quarterWidth + thirdButtonWidth
        branchesHorizontalConstraint.constant = -offset
        offersHorizontalConstraint.constant = offset

        updateGradientButtons()
    }

    private func updateGradientButtons() {
        let visibleTags = DataCache.sharedCache.visibleTags

        for (index, button) in gradientButtons.enumerate() {
            let startGradient = gradientColors[index * 2]
            let endGradient = gradientColors[(index * 2) + 1]
            let gradientLayer = createGradientLayer(button, startColor: startGradient, endColor: endGradient)
            button.layer.addSublayer(gradientLayer)

            if index < visibleTags.count {
                configureButton(button, tag: visibleTags[index])
            }
            button.bringSubviewToFront(button.imageView!)
            button.bringSubviewToFront(button.titleLabel!)
        }
    }

    private func createGradientLayer(button: UIButton, startColor: UIColor, endColor: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.layer.bounds
        gradientLayer.colors = [startColor.CGColor, endColor.CGColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        return gradientLayer
    }

    private func configureButton(button: UIButton, tag: VisibleTag) {
        button.setTitle("999", forState: .Normal)
        guard let image = tag.image?.loadedImage() else {
            tag.image?.loadImage { (image, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    button.setImage(image.loadedImage(), forState: .Normal)
                }
            }
            return
        }
        button.setImage(image, forState: .Normal)
    }

    // MARK: - IBActions
    @IBAction func onFilterAction(sender: UIButton) {
        delegate?.headerViewFilterAction(self)
    }
}
