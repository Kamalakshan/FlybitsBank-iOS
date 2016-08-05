//
//  GradientButton.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-04.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {

    // MARK: - IBInspectables
    @IBInspectable var gradientStart: UIColor!
    @IBInspectable var gradientEnd: UIColor!
    @IBInspectable var gradientAngle: CGFloat = 0

    // MARK: - Properties
    private var gradientLayer: CAGradientLayer!

    // MARK: - Functions
    func updateGradient(frame: CGRect) {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            layer.addSublayer(gradientLayer)
        }
        gradientLayer.frame = frame
        if let startColor = gradientStart?.CGColor, endColor = gradientEnd?.CGColor {
            gradientLayer.colors = [startColor, endColor]
        }
        gradientLayer.locations = [0, 1]
    }

    // MARK: - UIView Overrides
    override func layoutSubviews() {
        super.layoutSubviews()

        updateGradient(frame)
    }
}
