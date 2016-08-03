//
//  MainViewController.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-19.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

enum CollectionViewSection: Int {
    case Accounts
    case Services
    case Banner
    case Count

    var reuseIdentifier: String {
        switch self {
        case .Accounts:
            return "AccountReuseIdentifier"
        case .Services:
            return "ServiceReuseIdentifier"
        case .Banner:
            return "BannerReuseIdentifier"

        default:
            return "None"
        }
    }
}

class MainViewController: UICollectionViewController {

    // MARK: - Constants
    struct Constants {
        static let ShowLoginScreenSegue = "ShowLoginScreenSegue"
        static let MenuSlideInSegue = "MenuSlideInSegue"
        static let Accounts = "Accounts"
        static let Services = "Services"
        static let HeaderReuseIdentifier = "HeaderReuseIdentifier"
        static let HeaderReusableViewKind = "HeaderReuseIdentifier"
        static let AnimationDuration = 0.2
    }

    // MARK: - IBOutlets
    @IBOutlet var headerReusableView: HeaderCollectionReusableView! // TODO: (TL) Find a way to actually use this

    // MARK: - Properties
    var tokens = [NSObjectProtocol]()

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = DataCache.sharedCache.appConfigColor
        collectionView?.registerClass(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: Constants.HeaderReusableViewKind, withReuseIdentifier: Constants.HeaderReuseIdentifier)

        registerForChanges()

        DataCache.sharedCache.refreshCurrentZone()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {
            return // No identifier
        }
        switch segueIdentifier {
        case Constants.MenuSlideInSegue:
            if let destinationViewController = segue.destinationViewController as? MenuViewController {
                destinationViewController.delegate = self
            }

        default:
            break
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

        token = NSNotificationCenter.defaultCenter().addObserverForName(DataCache.Notifications.CacheUpdated, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue()) {
                self.appContentUpdated()
            }
        }
        tokens.append(token)

        token = NSNotificationCenter.defaultCenter().addObserverForName(DataCache.Notifications.CacheUpdateError, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue()) {
                self.appContentUpdateFailed()
            }
        }
        tokens.append(token)

        DataCache.sharedCache.registerForAppConfigurationChanges()
        DataCache.sharedCache.registerForContentChanges()
        OfferManager.sharedManager.registerForOffers()
    }

    func appConfigurationUpdated() {
        collectionView?.reloadAllSections()
        UIView.animateWithDuration(Constants.AnimationDuration) {
            self.navigationController?.navigationBar.barTintColor = DataCache.sharedCache.appConfigColor
        }
    }

    func appConfigurationUpdateFailed() {
        // TODO: (TL) ?
    }

    func appContentUpdated() {
        collectionView?.reloadAllSections()
    }

    func appContentUpdateFailed() {
        // TODO: (TL) ?
    }

    // MARK: - UICollectionViewController Functions
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return CollectionViewSection.Count.rawValue
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case CollectionViewSection.Accounts.rawValue:
            return 3 // TODO: (TL) Get proper number
        case CollectionViewSection.Services.rawValue:
            return DataCache.sharedCache.localFeatures.count
        case CollectionViewSection.Banner.rawValue:
            return 1 // TODO: (TL) This likely is always 1

        default:
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case CollectionViewSection.Accounts.rawValue:
            return self.collectionView(collectionView, accountCellForItemAtIndexPath: indexPath)
        case CollectionViewSection.Services.rawValue:
            return self.collectionView(collectionView, serviceCellForItemAtIndexPath: indexPath)
        case CollectionViewSection.Banner.rawValue:
            return self.collectionView(collectionView, bannerCellForItemAtIndexPath: indexPath)

        default:
            return UICollectionViewCell()
        }
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.HeaderReuseIdentifier, forIndexPath: indexPath) as! HeaderCollectionReusableView

        switch indexPath.section {
        case CollectionViewSection.Accounts.rawValue:
            headerView.contentView.backgroundColor = DataCache.sharedCache.appConfigColor
            headerView.titleLabel.text = Constants.Accounts
            headerView.titleLabel.textColor = UIColor.whiteColor()
        case CollectionViewSection.Services.rawValue:
            let localFeatures = DataCache.sharedCache.localFeatures

            headerView.contentView.backgroundColor = Utilities.androidLightGray
            headerView.titleLabel.text = "\(Constants.Services) (\(localFeatures.count))"
            headerView.titleLabel.textColor = Utilities.androidDarkGray
            headerView.titleLabel.textAlignment = .Center

        default:
            break
        }

        return headerView
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Clicky: \(indexPath)")
    }

    // MARK: - UICollectionView Helper Functions
    func collectionView(collectionView: UICollectionView, accountCellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewSection.Accounts.reuseIdentifier, forIndexPath: indexPath) as! AccountCollectionViewCell

        cell.accountNameLabel.text = "General Chequing Account"
        cell.balanceLabel.text = "$1,433.43"
        cell.accountNumberLabel.text = "20-33-55 12345678"
        cell.balanceDescriptionLabel.text = "Available Balance"

        return cell
    }

    func collectionView(collectionView: UICollectionView, serviceCellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewSection.Services.reuseIdentifier, forIndexPath: indexPath) as! ServiceCollectionViewCell

        let feature = DataCache.sharedCache.localFeatures[indexPath.row]
        // imageWithRenderingMode(.AlwaysTemplate)
        // Utilities.loadAndCrossfadeImage(cell.serviceImageView, image: image, duration: Constants.AnimationDuration)
        cell.serviceImageView.image = UIImage(named: "TestImage")!.imageWithRenderingMode(.AlwaysTemplate)
        cell.serviceImageView.tintColor = DataCache.sharedCache.appConfigColor
        cell.serviceLabel.text = feature.name
        cell.serviceLabel.textColor = DataCache.sharedCache.appConfigColor

        return cell
    }

    func collectionView(collectionView: UICollectionView, bannerCellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewSection.Banner.reuseIdentifier, forIndexPath: indexPath)
    }

    // MARK: - IBActions
    @IBAction func unwindToMainView(sender: UIStoryboardSegue) {
        /* EMPTY */
    }
}

extension MainViewController: MenuDelegate {
    func onLogoutCompleted(success: Bool) {
        self.dismissViewControllerAnimated(false) { // Dismiss the menu & main VC in one animation
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
