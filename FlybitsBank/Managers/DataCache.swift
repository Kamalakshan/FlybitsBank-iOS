//
//  DataCache.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-21.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import Foundation
import FlybitsSDK

class DataCache {

    // MARK: - Constants
    struct Constants {
        static let ConfigurationTagName = "Configuration"
        static let BranchTagName = "Branch"
    }

    struct Notifications {
        static let AppConfigurationUpdated = "com.flybits.notification.appConfigUpdated"
        static let AppConfigurationUpdateError = "com.flybits.notification.appConfigUpdateError"
        static let CacheUpdated = "com.flybits.notification.cacheUpdated"
        static let CacheUpdateError = "com.flybits.notification.cacheUpdateError"
        static let OfferReceived = "com.flybits.notification.offerReceived"
        static let OfferRemoved = "com.flybits.notification.offerRemoved"
    }

    struct UserInfoKeys {
        static let ErrorSource = "com.flybits.userInfo.errorSource"
        static let Error = "com.flybits.userInfo.error"
        static let Content = "com.flybits.userInfo.content"
    }

    // MARK: - Enums
    enum ErrorSource: String {
        case Zone = "com.flybits.error.zone"
        case Moment = "com.flybits.error.moment"
    }

    // MARK: - Properties
    static let sharedCache = DataCache()

    // APNS
    var pushConnected = false
    var apnsToken: NSData? {
        didSet {
            if let apnsToken = apnsToken where pushConnected && PushManager.sharedManager.configuration.serviceLevel == .Foreground {
                PushManager.sharedManager.configuration = PushConfiguration(serviceLevel: .Both, apnsToken: apnsToken)
            }
        }
    }

    // App Configuration
    private(set) var appConfig: Zone?
    private(set) var appFeatures = [Moment]()
    private(set) var configTag: Tag?

    // Current Zone & Moments
    private(set) var localBranch: Branch?
    private(set) var localFeatures = [Feature]()
    private var localMoments = [Moment]()
    private var localZone: Zone?

    // Notifications
    private var observers = [String : NSObjectProtocol]()
    private var notificationQueue = NSOperationQueue()

    var appConfigColor: UIColor {
        return appConfig?.color.uiColor ?? Utilities.flybitsBlue
    }

    // MARK: - Lifecycle Functions
    private init() {}

    // MARK: - Functions
    func appFeaturesForFilter(filter: String) -> [Moment] {
        return appFeatures.filter({ $0.tagIDs.contains(filter) })
    }

    // MARK: - NSNotificationCenter Helper Functions
    func registerForAppConfigurationChanges() -> NSObjectProtocol? {
        guard let appConfig = appConfig else {
            return nil
        }
        let topic = PushMessage.CompleteNotificationType(.Zone, action: .Modified, rawAction: appConfig.id)
        let token = NSNotificationCenter.defaultCenter().addObserverForName(topic, object: nil, queue: notificationQueue) { (notification) in
            guard let userInfo = notification.userInfo else {
                let userInfo: [String : AnyObject] = [
                    UserInfoKeys.Error : NSError(domain: "DOMAIN", code: 0, userInfo: nil)
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppConfigurationUpdateError, object: nil, userInfo: userInfo)
                return
            }
            // TODO: (TL) parse userInfo into something valid
            if let config = userInfo[PushManager.Constants.PushFetchedContent] as? Zone {
                self.appConfig = config
            }
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppConfigurationUpdated, object: nil, userInfo: userInfo)
        }
        observers[topic] = token

        return token
    }

    func registerForContentChanges() {
        let topic = PushMessage.NotificationType(.Zone, action: .Modified)
        let token = NSNotificationCenter.defaultCenter().addObserverForName(topic, object: nil, queue: notificationQueue) { (notification) in
            guard let userInfo = notification.userInfo else {
                let userInfo: [String : AnyObject] = [
                    UserInfoKeys.Error : NSError(domain: "DOMAIN", code: 1, userInfo: nil)
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CacheUpdateError, object: nil, userInfo: userInfo)
                return
            }
            if let currentBranchZone = userInfo[PushManager.Constants.PushFetchedContent] as? Zone {
                if currentBranchZone.id == DataCache.sharedCache.appConfig?.id {
                    return // Ignore changes to this Zone
                }
                self.localBranch = Branch(identifier: currentBranchZone.id, name: currentBranchZone.zoneName() ?? "")
                self.localZone?.unsubscribeFromPush()
                self.localZone = currentBranchZone
                self.localZone?.subscribeToPush()
            }
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CacheUpdated, object: nil)
        }
        observers[topic] = token
    }

    // Flybits SDK Wrapper Functions
    func refreshCurrentZone() {
        APIManager.fetchBranchZones { (zones, pager, error) in
            guard let error = error else {
                guard let currentBranchZone = zones.first else {
                    self.localZone?.unsubscribeFromPush()
                    self.localZone = nil
                    self.localBranch = nil
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CacheUpdated, object: nil)
                    return
                }
                self.localZone?.unsubscribeFromPush()
                self.localZone = currentBranchZone
                self.localZone?.subscribeToPush()
                self.localBranch = Branch(identifier: currentBranchZone.id, name: currentBranchZone.zoneName() ?? "")
                APIManager.fetchBranchContent(self.localBranch!.identifier) { (moments, pager, error) in
                    guard let error = error else {
                        if let configTag = self.configTag {
                            self.localMoments = moments.filter({ !$0.tagIDs.contains(configTag.id) })
                            self.localFeatures = self.localMoments.map({ Feature(identifier: $0.id, name: $0.momentName() ?? "") })
                        } else {
                            self.localMoments = moments
                            self.localFeatures = moments.map({ Feature(identifier: $0.id, name: $0.momentName() ?? "") })
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CacheUpdated, object: nil)
                        return
                    }
                    let userInfo: [String : AnyObject] = [
                        UserInfoKeys.Error : error,
                        UserInfoKeys.ErrorSource : ErrorSource.Moment.rawValue
                    ]
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CacheUpdateError, object: nil, userInfo: userInfo)
                }
                return
            }
            let userInfo: [String : AnyObject] = [
                UserInfoKeys.Error : error,
                UserInfoKeys.ErrorSource : ErrorSource.Zone.rawValue
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CacheUpdateError, object: nil, userInfo: userInfo)
        }
    }

    func refreshAppConfig() {
        guard configTag != nil else {
            let query = TagQuery(limit: 1, offset: 0)
            query.searchValue = Constants.ConfigurationTagName
            TagsRequest.Query(query) { (tags, pagination, error) in
                guard let configurationTag = tags?.first where error == nil else {
                    // Handle error
                    let userInfo: [String : AnyObject] = [
                        UserInfoKeys.Error : error!
                    ]
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppConfigurationUpdateError, object: nil, userInfo: userInfo)
                    return
                }
                self.configTag = configurationTag
                self.refreshAppConfigData()
            }.execute()
            return
        }
        refreshAppConfigData()
    }

    private func refreshAppConfigData() {
        guard let configurationZoneID = configTag?.zoneID.first else {
            let userInfo: [String : AnyObject] = [
                UserInfoKeys.Error : NSError(domain: "DOMAIN", code: 0, userInfo: nil)
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppConfigurationUpdateError, object: nil, userInfo: userInfo)
            return
        }
        ZoneRequest.GetZone(id: configurationZoneID) { (zone, error) in
            guard let zone = zone where error == nil else {
                let userInfo: [String : AnyObject] = [
                    UserInfoKeys.Error : error!
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppConfigurationUpdateError, object: nil, userInfo: userInfo)
                return
            }
            self.appConfig = zone
            MomentRequest.GetZoneMoments(zoneID: zone.id) { (moments, pagination, error) in
                guard error == nil else {
                    let userInfo: [String : AnyObject] = [
                        UserInfoKeys.Error : error!
                    ]
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppConfigurationUpdateError, object: nil, userInfo: userInfo)
                    return
                }
                self.appFeatures = moments
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppConfigurationUpdated, object: nil)
                }.execute()
            }.execute()
    }
}
