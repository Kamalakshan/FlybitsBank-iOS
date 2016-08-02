//
//  MenuViewController.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-20.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit
import FlybitsSDK

enum MenuSection: Int {
    case BasicServices
    case AccountServices
    case Count
}

protocol MenuDelegate {
    func onLogoutCompleted(success: Bool)
}

class MenuViewController: UIViewController {
    // MARK: - Constants
    struct Constants {
        static let AnimationDuration = 0.1
        static let AnimationDelay = 0.4
        static let Logout = "Logout"
        static let LogoutSegue = "LogoutSegue"
        static let BasicCellReuseIdentifier = "BasicCellReuseIdentifier"
        static let BankServicesTagID = "B60F0409-03F8-4BA3-8F07-6B7D10F085B9"
        static let AccountServicesTagID = "F1954106-ADFE-47F1-A4C2-A3663D73D0EE"
    }

    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableHeaderView: MenuTableHeaderView!
    @IBOutlet var accountServicesHeaderView: UIView!

    // MARK: - Properties
    var delegate: MenuDelegate?
    var tokens = [NSObjectProtocol]()
    var menuItems = [MenuSection : [Moment]]()
    var fakeUser = User(name: "Bill Johnson", persona: "Business Customer")

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = DataCache.sharedCache.appConfigColor
        tableHeaderView.backgroundColor = DataCache.sharedCache.appConfigColor
        tableHeaderView.configure(fakeUser)

        menuItems[.BasicServices] = DataCache.sharedCache.appFeaturesForFilter(Constants.BankServicesTagID)
        menuItems[.AccountServices] = DataCache.sharedCache.appFeaturesForFilter(Constants.AccountServicesTagID)

        registerForChanges()
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animateWithDuration(Constants.AnimationDuration, delay: Constants.AnimationDelay, options: .CurveEaseOut, animations: {
            self.view.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        }, completion: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        for token in tokens {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
        tokens.removeAll()
    }

    // MARK: - Functions
    func registerForChanges() {
        var token = NSNotificationCenter.defaultCenter().addObserverForName(DataCache.Notifications.AppConfigurationUpdated, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue()) {
                self.appConfigurationUpdated()
            }
        }
        tokens.append(token)

        token = NSNotificationCenter.defaultCenter().addObserverForName(DataCache.Notifications.AppConfigurationUpdateError, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue()) {
                self.appConfigurationUpdateFailed()
            }
        }
        tokens.append(token)

        DataCache.sharedCache.registerForAppConfigurationChanges()
    }

    func appConfigurationUpdated() {
        tableView.backgroundColor = DataCache.sharedCache.appConfigColor
        tableHeaderView.backgroundColor = DataCache.sharedCache.appConfigColor
    }

    func appConfigurationUpdateFailed() {
    }
}

// MARK: - UITableViewDataSource Functions
extension MenuViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return MenuSection.Count.rawValue
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menuSection = MenuSection(rawValue: section) else {
            return 0
        }

        var numberOfRows = menuItems[menuSection]?.count ?? 0
        if menuSection == .AccountServices {
            numberOfRows += 1 // Account for logout
        }

        return numberOfRows
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.BasicCellReuseIdentifier, forIndexPath: indexPath) as! MenuTableViewCell

        guard let menuSection = MenuSection(rawValue: indexPath.section) else {
            return cell
        }

        if menuSection == .AccountServices && indexPath.row == menuItems[.AccountServices]!.count {
            cell.cellImageView.image = UIImage.image(with: UIColor.redColor())
            cell.cellTitleLabel.text = Constants.Logout
        } else {
            let moment = menuItems[menuSection]?[indexPath.row]
            cell.cellImageView.image = UIImage.image(with: UIColor.blackColor())
            cell.cellTitleLabel.text = moment?.name.value ?? ""
            if let image = moment?.image {
                Utilities.loadAndCrossfadeImage(cell.cellImageView, image: image, duration: Constants.AnimationDuration)
            }
        }

        let size = CGSize(width: tableView.frame.width, height: cell.frame.height)
        cell.frame = CGRect(origin: cell.frame.origin, size: size)

        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == MenuSection.AccountServices.rawValue ? accountServicesHeaderView : nil
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == MenuSection.AccountServices.rawValue ? accountServicesHeaderView.frame.height : 0
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        print("Clicky: \(indexPath)")
        guard let menuSection = MenuSection(rawValue: indexPath.section) else {
            return // Can't find section
        }
        if menuSection == .AccountServices && indexPath.row == menuItems[.AccountServices]!.count {
            APIManager.logout { (success, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.onLogoutCompleted(success)
                }
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate Functions
extension MenuViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if !contentView.frame.contains(touch.locationInView(contentView)) {
            UIView.animateWithDuration(Constants.AnimationDuration) {
                self.view.backgroundColor = UIColor.clearColor()
            }
            return true
        }
        return false
    }
}
