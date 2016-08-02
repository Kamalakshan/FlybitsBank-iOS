//
//  LoginViewController.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-19.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Constants
    struct Constants {
        static let AnimationDuration = 0.2
        static let LoginSegue = "LoginSegue"
        static let LoginErrorText = "Login error. Please try again."
    }

    // MARK: - IBOutlets
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var clientCardTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var errorView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var tintView: UIView!
    @IBOutlet var poweredByFlybitsImageView: UIImageView!

    // MARK: - NSLayoutConstraints
    @IBOutlet var logoImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var clientCardViewYConstraint: NSLayoutConstraint!
    @IBOutlet var errorViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var loadingAppConfig = false
    var tokens = [NSObjectProtocol]()

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        clientCardTextField.layer.borderColor = UIColor.whiteColor().CGColor
        passwordTextField.layer.borderColor = UIColor.whiteColor().CGColor

        registerForChanges()
        registerForKeyboardEvents()

        if DataCache.sharedCache.appConfig == nil {
            loadingAppConfig = true
            DataCache.sharedCache.refreshAppConfig()
        } else {
            appConfigurationUpdated()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        loginButton.enabled = true

        if loadingAppConfig {
            logoImageView.alpha = 0
            clientCardTextField.alpha = 0
            passwordTextField.alpha = 0
            loginButton.alpha = 0
            poweredByFlybitsImageView.alpha = 0
        } else {
            showLoginFields()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        for token in tokens {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
        tokens.removeAll()
    }

    // MARK: - DataCache Notification Functions
    func registerForChanges() {
        var token = NSNotificationCenter.defaultCenter().addObserverForName(DataCache.Notifications.AppConfigurationUpdated, object: nil, queue: nil) { (notification) in
            self.appConfigurationUpdated()
        }
        tokens.append(token)

        token = NSNotificationCenter.defaultCenter().addObserverForName(DataCache.Notifications.AppConfigurationUpdateError, object: nil, queue: nil) { (notification) in
            self.appConfigurationUpdateFailed()
        }
        tokens.append(token)
    }

    func appConfigurationUpdated() {
        loadingAppConfig = false
        loginButton.setTitleColor(DataCache.sharedCache.appConfigColor, forState: .Normal)

        Utilities.loadingView.addToView(view)
        APIManager.login(nil, password: nil) { (success, error) in
            if let appConfig = DataCache.sharedCache.appConfig {
                self.tintView.backgroundColor = appConfig.color.uiColor ?? UIColor.clearColor()
                Utilities.loadAndCrossfadeImage(self.logoImageView, image: appConfig.image, duration: Constants.AnimationDuration)
            }
            if success && error == nil {
                self.loginSuccess()
            } else {
                self.showLoginFields()
            }
        }
    }

    func appConfigurationUpdateFailed() {
        loadingAppConfig = false

        showLoginFields()
    }

    // MARK: - Functions
    func registerForKeyboardEvents() {
        var token = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            guard let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size else {
                return
            }
            let delta = keyboardSize.height - (self.passwordTextField.frame.origin.y + self.passwordTextField.frame.height)
            self.keyboardWillShow(delta)
        }
        tokens.append(token)

        token = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide()
        }
        tokens.append(token)
    }

    func loginSuccess() {
        Utilities.loadingView.removeFromView()

        errorLabel.text = ""
        errorViewBottomConstraint.constant = -self.errorView.frame.height
        performSegueWithIdentifier(Constants.LoginSegue, sender: nil)
    }

    func loginFailure(error: NSError?) {
        Utilities.loadingView.removeFromView()

        self.errorLabel.text = Constants.LoginErrorText
        self.errorViewBottomConstraint.constant = 0
        self.loginButton.enabled = true
    }

    // MARK: - UI Helper Functions
    func showLoginFields() {
        Utilities.loadingView.removeFromView()
        UIView.animateWithDuration(Constants.AnimationDuration, delay: 0, options: .CurveEaseIn, animations: {
            self.logoImageView.alpha = 1
            self.clientCardTextField.alpha = 1
            self.passwordTextField.alpha = 1
            self.loginButton.alpha = 1
            self.poweredByFlybitsImageView.alpha = 1
        }) { (finished) in
            self.clientCardTextField.becomeFirstResponder()
        }
    }

    func toggleError(show: Bool = false, message: String? = nil) {
        if show {
            errorLabel.text = message
            errorViewBottomConstraint.constant = 0
        } else {
            errorViewBottomConstraint.constant = -errorView.frame.height
        }
    }

    // TODO: (TL) Make this more intelligent based on device screen space
    func keyboardWillShow(delta: CGFloat) {
        logoImageViewBottomConstraint.constant += delta * 0.75
        clientCardViewYConstraint.constant = delta
        UIView.animateWithDuration(Constants.AnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide() {
        logoImageViewBottomConstraint.constant = 110
        clientCardViewYConstraint.constant = 10
        UIView.animateWithDuration(Constants.AnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - IBActions
    @IBAction func onLoginAction(sender: UIButton) {
        sender.enabled = false

        Utilities.loadingView.addToView(view)

        let email = clientCardTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        APIManager.login(email, password: password) { (success, error) in
            if success && error == nil {
                self.loginSuccess()
            } else {
                self.loginFailure(error)
            }
        }
    }
}
