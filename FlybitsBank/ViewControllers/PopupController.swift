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
    var configuration: LayoutConfiguration?

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.distribution = .EqualSpacing
        stackView.alignment = .Center
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        view.addConstraints(Utilities.fullContainerConstraints(stackView))

        if let configuration = configuration {
            layout(configuration)
        }
    }

    // MARK: - Functions
    func layout(configuration: LayoutConfiguration) {
        self.configuration = configuration

        guard let stackView = stackView else {
            return // Can't do much
        }

        for subview in stackView.subviews {
            subview.removeFromSuperview()
        }
        let componentCount = configuration.components.count == 0 ? 1 : CGFloat(configuration.components.count)
        let height = view.frame.height / componentCount
        for component in configuration.components {
            component.view.widthAnchor.constraintEqualToConstant(view.frame.width).active = true
            component.view.heightAnchor.constraintEqualToConstant(height).active = true
            stackView.addArrangedSubview(component.view)
        }
    }
}
