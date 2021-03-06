//
//  OfferManager.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-02.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import Foundation
import FlybitsSDK

protocol OfferDisplayDelegate {
    func showFullScreen(viewController: PopupController)
    func showBanner(view: UIView)
}

class OfferManager {
    // MARK: - Constants
    struct Constants {
        static let ZoneID = "zoneId"
    }

    // MARK: - Enums
    private enum State {
        case Blocked
        case Available
        case Banner
    }

    // MARK: - Properties
    static let sharedManager = OfferManager()

    var delegate: OfferDisplayDelegate?
    private(set) var currentOffer: LayoutConfiguration?
    private(set) var offerQueue = [LayoutConfiguration]()

    private var popupController: PopupController?
    private var state: State = .Blocked {
        didSet {
            stateUpdated()
        }
    }

    // Notifications
    private var observers = [NSObjectProtocol]()
    private var notificationQueue = NSOperationQueue()

    // MARK: - Notifications
    func registerForOffers() {
        let completionBlock: (NSNotification) -> Void = { (notification) in
            self.handleOfferNotification(notification.userInfo)
        }

        let topics: [String] = [
            // APNS
            PushMessage.NotificationType(.MomentInstance, action: .ZoneEntered),
            PushMessage.NotificationType(.MomentInstance, action: .ZoneExited),

            // MQTT
            // PushMessage.NotificationType(.Zone, action: .Entered),
            // PushMessage.NotificationType(.Zone, action: .Exited)
        ]

        for topic in topics {
            let token = NSNotificationCenter.defaultCenter().addObserverForName(topic, object: nil, queue: notificationQueue, usingBlock: completionBlock)
            observers.append(token)
        }
    }

    // MARK: - Functions
    func enableOffers() {
        state = .Available
    }

    func disableOffers() {
        state = .Blocked
    }

    func handleOfferNotification(userInfo: [NSObject : AnyObject]?) {
        guard let userInfo = userInfo else {
            return
        }
        // TODO: (TL) Handle MQTT vs. APNS (body contains ID vs. Zone ID)
        if let message = userInfo[PushManager.Constants.PushMessageContent] as? PushMessage, pushedZoneID = message.body?[Constants.ZoneID] as? String {
            APIManager.fetchConfigForPushedZone(pushedZoneID) { (configuration, error) in
                guard let configuration = configuration where error == nil else {
                    return // Can't show anything
                }
                self.receivedNewOffer(configuration)
            }
        }
    }

    func receivedNewOffer(configuration: LayoutConfiguration) {
        offerQueue.append(configuration)

        // If we're not currently showing an offer and we can be, show one
        guard state == .Available else {
            return // State changes will handle the rest
        }
        state = .Available // Force refresh
    }

    func stateUpdated() {
        switch state {
        case .Available:
            // TODO: (TL) Show banner for next available offer
            guard offerQueue.count > 0 else {
                return // Nothing to do
            }
            let offer = offerQueue.removeAtIndex(0)

            // Configure popup
            if popupController == nil {
                popupController = PopupController()
            }
            popupController?.layout(offer)
            delegate?.showFullScreen(popupController!)
        case .Banner:
            // TODO: (TL) Banners could be swipable left/right if multiple offers are received
            break

        case .Blocked:
            // TODO: (TL) stop active banner?
            break
        }
    }
}
