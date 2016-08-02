//
//  ScreenTakeoverViewController.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-27.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class ScreenTakeoverViewController: UIViewController {
    // MARK: - Properties
    var configuration: LayoutConfiguration? {
        didSet {
            configureSubviews()
        }
    }

    // MARK: - Functions
    func configureSubviews() {
        // Clean up first
        view.subviews.forEach { $0.removeFromSuperview() }

        // Verify we have a valid configuration
        guard let configuration = configuration else {
            return
        }

        // Organize and layout components
        for component in configuration.components {
            view.addSubview(component.view)

            let constraints = constraintsForComponent(component)
            view.addConstraints(constraints)
        }
    }

    func constraintsForComponent(component: Component) -> [NSLayoutConstraint] {
        let horizontalConstraints = Utilities.fullContainerConstraints(component.view, withInset: 0, forDirection: .Horizontal)

        let verticalConstraints = heightConstraintsForComponent(component)

        return horizontalConstraints + verticalConstraints
    }

    func heightConstraintsForComponent(component: Component) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint]
        switch component.kind { // TODO: (TL)
        case .Title:
            constraints = []
        case .Description:
            constraints = []
        case .Person:
            constraints = []
        case .Selection:
            constraints = []
        case .CallToAction:
            constraints = []
        case .Promo1:
            constraints = []
        case .Promo2:
            constraints = []
        }

        return constraints
    }
}
