//
//  GradientButton.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-04.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class GradientButton: UIButton {

    // MARK: - IBInspectables
    @IBInspectable var gradientStart: UIColor!
    @IBInspectable var gradientEnd: UIColor!
    @IBInspectable var gradientAngle: CGFloat = 0

    // MARK: - Properties
    private var gradientLayer: CAGradientLayer!

    // MARK: - Lifecycle Functions
    override init(frame: CGRect) {
        super.init(frame: frame)

        addGradientLayer(frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addGradientLayer(frame)
    }

    // MARK: - Functions
    func addGradientLayer(frame: CGRect) {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [gradientStart.CGColor, gradientEnd.CGColor]
        gradientLayer.locations = [0, 1]

        layer.addSublayer(gradientLayer)
    }

    // MARK: - UIView Overrides
    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = frame
    }
}
