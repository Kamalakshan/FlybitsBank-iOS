//
//  PopupController.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-03.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class PopupController: UIViewController {
    // MARK: - IBOutlets
    var stackView: UIStackView!

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.distribution = .EqualSpacing
        stackView.alignment = .Center
        stackView.spacing = 0

        view.addSubview(stackView)
        view.addConstraints(Utilities.fullContainerConstraints(stackView))
    }

    // MARK: - Functions
    func layout(configuration: LayoutConfiguration) {
        view.subviews.forEach({ $0.removeFromSuperview() })
        for component in configuration.components {
            // TODO: (TL) might need to add constraints
            stackView.addArrangedSubview(component.view)

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
        let format = "\(Utilities.LayoutDirection.Vertical.rawValue):[view(==\(component.view.frame.height)]"
        let views = ["view" : component.view]

        return NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
    }
}
