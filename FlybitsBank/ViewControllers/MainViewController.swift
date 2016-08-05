//
//  MainViewController.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-19.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit
import FlybitsSDK // TODO: (TL) Can we remove this requirement?

enum CollectionViewSection: Int {
    case Zones
    case Count

    var reuseIdentifier: String {
        switch self {
        case .Zones:
            return "ZoneReuseIdentifier"

        default:
            return "None"
        }
    }
}

class MainViewController: UICollectionViewController {

    // MARK: - Constants
    struct Constants {
        static let FilterTitle = "Filter By"
        static let Nearby = "Nearby"
        static let All = "All"
        static let Cancel = "Cancel"
        static let ShowLoginScreenSegue = "ShowLoginScreenSegue"
        static let MenuSlideInSegue = "MenuSlideInSegue"
        static let Accounts = "Accounts"
        static let Services = "Services"
        static let HeaderReuseIdentifier = "HeaderReuseIdentifier"
        static let HeaderReusableViewKind = "HeaderReuseIdentifier"
        static let AnimationDuration = 0.2
        static let ItemPadding: CGFloat = 10
    }

    // MARK: - IBOutlets
    @IBOutlet var stickyHeaderView: MainHeaderView!
    @IBOutlet var headerReusableView: HeaderCollectionReusableView! // TODO: (TL) Find a way to actually use this

    // MARK: - NSLayoutContraints
    var heightConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var tokens = [NSObjectProtocol]()

    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = DataCache.sharedCache.appConfigColor
        collectionView?.registerClass(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: Constants.HeaderReusableViewKind, withReuseIdentifier: Constants.HeaderReuseIdentifier)

        setupHeaderView()
        setupCollectionView()
        registerForChanges()

        DataCache.sharedCache.refreshCurrentZone()
        OfferManager.sharedManager.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        OfferManager.sharedManager.enableOffers()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        OfferManager.sharedManager.disableOffers()
        for token in tokens {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
        tokens.removeAll()
    }

    // MARK: - UI Helper Functions
    func setupHeaderView() {
        stickyHeaderView.delegate = self
        stickyHeaderView.clipsToBounds = true
        stickyHeaderView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stickyHeaderView)
        view.addConstraints(Utilities.fullContainerConstraints(stickyHeaderView, withInset: 0, forDirection: .Horizontal))

        let topConstraint = NSLayoutConstraint(item: stickyHeaderView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(topConstraint)

        heightConstraint = NSLayoutConstraint(item: stickyHeaderView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: view.frame.height / 2)
        view.addConstraint(heightConstraint)

        var inset = collectionView!.contentInset
        inset.top = heightConstraint.constant
        collectionView?.contentInset = inset
    }

    func setupCollectionView() {
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return // Can't do it w/ a custom layout
        }
        flowLayout.itemSize = CGSize(width: view.frame.width - Constants.ItemPadding, height: flowLayout.itemSize.height)
        flowLayout.minimumInteritemSpacing = Constants.ItemPadding
    }

    // MARK: - IBActions
    @IBAction func unwindToMainView(sender: UIStoryboardSegue) {
        /* EMPTY */
    }
}

// MARK: - UICollectionViewController Functions
extension MainViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return CollectionViewSection.Count.rawValue
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case CollectionViewSection.Zones.rawValue:
            return 10

        default:
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case CollectionViewSection.Zones.rawValue:
            return self.collectionView(collectionView, zonesCellForItemAtIndexPath: indexPath)

        default:
            return UICollectionViewCell()
        }
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Clicky: \(indexPath)")
    }

    // MARK: - UICollectionView Helper Functions
    func collectionView(collectionView: UICollectionView, zonesCellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewSection.Zones.reuseIdentifier, forIndexPath: indexPath) as! ZoneCollectionViewCell

        // if let tag = DataCache.sharedCache.visibleTags.filter({ $0.id == zoneID }).first
        // Utilities.loadAndCrossfadeImage(<#T##imageView: UIImageView##UIImageView#>, image: <#T##Image#>)
        let image = UIImage.image(with: UIColor.greenColor())
        Utilities.transitionImage(cell.iconImageView, image: image) // TODO: (TL) Gradient
        cell.titleLabel.text = "Zone Name" // TODO: (TL) ...
        cell.descriptionLabel.text = "Distance" // TODO: (TL) ...

        applyCellStyle(cell)

        return cell
    }

    func applyCellStyle(cell: UICollectionViewCell) {
        // General
        cell.layer.masksToBounds = false

        // Shadows
        cell.layer.shadowColor = UIColor.lightGrayColor().CGColor
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = CGSize.zero
    }
}

// MARK: - DataCache Notification Functions
extension MainViewController {
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
}

// MARK: - UIScrollViewDelegate Functions
extension MainViewController {
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        heightConstraint.constant = max(-collectionView!.contentOffset.y, stickyHeaderView.minHeight)
    }
}

// MARK: - OfferDisplayDelegate
extension MainViewController: OfferDisplayDelegate {
    func showFullScreen(viewController: PopupController) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }

    func showBanner(view: UIView) {
        // TODO: (TL) ...
    }
}

// MARK: - MainHeaderViewDelegate
extension MainViewController: MainHeaderViewDelegate {
    func headerViewFilterAction(headerView: MainHeaderView) {
        let alertController = UIAlertController(title: Constants.FilterTitle, message: nil, preferredStyle: .ActionSheet)

        let nearbyAction = UIAlertAction(title: Constants.Nearby, style: .Default) { (action) in
            headerView.filterButton.setTitle("Nearby v", forState: .Normal)
        }
        let allAction = UIAlertAction(title: Constants.All, style: .Default) { (action) in
            headerView.filterButton.setTitle("All v", forState: .Normal)
        }
        let cancelAction = UIAlertAction(title: Constants.Cancel, style: .Cancel, handler: nil)

        alertController.addAction(nearbyAction)
        alertController.addAction(allAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
