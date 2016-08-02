//
//  OfferManager.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-02.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import Foundation
import FlybitsSDK

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
    private(set) var currentOffer: LayoutConfiguration?
    private(set) var offerQueue = [LayoutConfiguration]()

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
            PushMessage.NotificationType(.Zone, action: .Entered),
            PushMessage.NotificationType(.Zone, action: .Exited)
        ]

        for topic in topics {
            let token = NSNotificationCenter.defaultCenter().addObserverForName(topic, object: nil, queue: notificationQueue, usingBlock: completionBlock)
            observers.append(token)
        }
    }

    // MARK: - Functions
    func handleOfferNotification(userInfo: [NSObject : AnyObject]?) {
        guard let userInfo = userInfo else {
            return
        }
        if let message = userInfo[PushManager.Constants.PushMessageContent] as? PushMessage, pushedZoneID = message.body?[Constants.ZoneID] as? String {
            print("Message: \(message)")
            APIManager.fetchConfigForPushedZone(pushedZoneID) { (configuration, error) in
                guard let configuration = configuration where error == nil else {
                    return // Can't show anything
                }
                print("Configuration: \(configuration)")
                self.receivedNewOffer(configuration)
            }
        }
    }

    func receivedNewOffer(configuration: LayoutConfiguration) {
        offerQueue.append(configuration)

        guard currentOffer == nil && offerQueue.count == 1 else {
            return // State changes will handle the rest
        }
    }

    func stateUpdated() {
        switch state {
        case .Available:
            // TODO: (TL) Show banner for next available offer
            break
        case .Banner:
            // TODO: (TL) Banners could be swipable left/right if multiple offers are received
            break

        case .Blocked:
            // TODO: (TL) stop active banner?
            break
        }
    }
}
