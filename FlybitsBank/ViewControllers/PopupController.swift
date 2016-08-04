//
//  PopupController.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-03.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class PopupController: UIViewController {
    // MARK: - Constants
    struct Constants {
        static let TintViewAlpha: CGFloat = 0.2
        static let CancelButtonColor = UIColor.blackColor()
    }

    // MARK: - IBOutlets
    var backgroundImageView: UIImageView!
    var stackView: UIStackView!
    var tintView: UIView!
    var cancelButton: UIButton!
    var configuration: LayoutConfiguration?

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackgroundImageView()
        addStackView()
        addTintView()
        addCancelButton()

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

        // Clean up
        for subview in stackView.subviews {
            subview.removeFromSuperview()
        }
        layoutMetadata(configuration.metadata)
        layoutComponents(configuration.components)
    }

    // MARK: - Layout Helpers
    private func layoutMetadata(metadata: BaseMomentMetadata) {
        tintView.backgroundColor = metadata.overlayColor.uiColor
        // TODO: (TL) Text color
        if let imageURL = NSURL(string: metadata.backgroundImageURL) {
            Utilities.loadAndCrossfadeImage(backgroundImageView, imageURL: imageURL)
        }
    }

    private func layoutComponents(components: [Component]) {
        let componentCount = components.count == 0 ? 1 : CGFloat(components.count)
        let height = view.frame.height / componentCount
        for component in components {
            component.view.widthAnchor.constraintEqualToConstant(view.frame.width).active = true
            component.view.heightAnchor.constraintEqualToConstant(height).active = true
            stackView.addArrangedSubview(component.view)

            if component.kind == .CallToAction {
                component.view.delegate = self
            }
        }
    }

    // MARK: - UI Helpers
    private func addBackgroundImageView() {
        backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backgroundImageView)
        view.addConstraints(Utilities.fullContainerConstraints(backgroundImageView))
    }

    private func addStackView() {
        stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.distribution = .EqualSpacing
        stackView.alignment = .Center
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        view.addConstraints(Utilities.fullContainerConstraints(stackView))
    }

    private func addTintView() {
        tintView = UIView()
        tintView.alpha = Constants.TintViewAlpha
        tintView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tintView)
        view.addConstraints(Utilities.fullContainerConstraints(tintView))
    }

    private func addCancelButton() {
        cancelButton = UIButton(type: .System)
        cancelButton.titleLabel?.font = Utilities.flybitsFont.fontWithSize(20)
        cancelButton.setTitle("J", forState: .Normal)
        cancelButton.setTitleColor(Constants.CancelButtonColor, forState: .Normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(onCancelAction(_:)), forControlEvents: .TouchUpInside)

        view.addSubview(cancelButton)

        let constraints = cancelButtonConstraints()
        view.addConstraints(constraints)
    }

    private func cancelButtonConstraints() -> [NSLayoutConstraint] {
        var format = "H:[button(==40)]-20-|"
        let options = NSLayoutFormatOptions(rawValue: 0)
        let views: [String : AnyObject] = [
            "button" : cancelButton
        ]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: nil, views: views)

        format = "V:|-20-[button(==40)]"
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: nil, views: views)

        return horizontalConstraints + verticalConstraints
    }

    // MARK: - UIActions
    func onCancelAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func handleAction(gestureRecognizer: UIGestureRecognizer, forComponent component: Component) {
        // TODO: (TL) Figure out how to trigger the requisite action
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PopupController: DynamicViewActionDelegate {
    func dynamicView(dynamicView: DynamicView, gestureRecognized gestureRecognizer: UIGestureRecognizer) {
        print("DynamicView: \(dynamicView) -> Gesture Performed: \(gestureRecognizer)")
        guard let configuration = configuration else {
            return // Can't do anything w/o a configuration
        }
        for component in configuration.components {
            if component.view == dynamicView {
                // Found the view and component that triggered it
                handleAction(gestureRecognizer, forComponent: component)
                break
            }
        }
    }
}
