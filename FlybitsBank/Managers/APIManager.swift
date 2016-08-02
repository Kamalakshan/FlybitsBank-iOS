//
//  APIManager.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-25.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import CoreLocation
import FlybitsSDK

class APIManager {
    // MARK: - Constants
    struct Constants {
        static let BranchRadius: CLLocationDistance = 1000
    }

    // MARK: - Properties
    static var locationProvider: CoreLocationDataProvider?
    static var branchTag: Tag?

    // MARK: - Lifecycle Functions
    private init() {}

    // MARK: - APIs
    static func login(username: String?, password: String?, completion: (success: Bool, error: NSError?) -> Void) {
        if Session.sharedInstance.canLoginUsingSessionToken() {
            Session.sharedInstance.validateSession { (valid, currentUser, error) in
                if valid && error == nil {
                    // TODO: (TL) Tokens
                    NSNotificationCenter.defaultCenter().addObserverForName(PushManager.Constants.PushConnected, object: nil, queue: nil) { (notification) in
                        DataCache.sharedCache.pushConnected = true
                        DataCache.sharedCache.appConfig?.subscribeToPush()
                    }
                    NSNotificationCenter.defaultCenter().addObserverForName(PushManager.Constants.PushDisconnected, object: nil, queue: nil) { (notification) in
                        DataCache.sharedCache.pushConnected = false
                    }
                    NSNotificationCenter.defaultCenter().addObserverForName(PushManager.Constants.PushErrorTopic, object: nil, queue: nil) { (notification) in
                        print("Push Error: \(notification.userInfo)")
                    }
                    if let apnsToken = DataCache.sharedCache.apnsToken {
                        PushManager.sharedManager.configuration = PushConfiguration(serviceLevel: .Both, apnsToken: apnsToken)
                    } else {
                        PushManager.sharedManager.configuration = PushConfiguration(serviceLevel: .Foreground)
                    }

                    self.locationProvider = ContextManager.sharedManager.registerSDKContextProvider(.CoreLocation, priority: .Any, pollFrequency: 60, uploadFrequency: 5 * 60) as? CoreLocationDataProvider
                    ContextManager.sharedManager.startDataPolling()
                    completion(success: valid, error: nil)
                } else {
                    if let username = username, password = password {
                        loginRequest(username, password: password, completion: completion)
                    } else {
                        completion(success: valid, error: error)
                    }
                }
            }
        } else {
            guard let username = username, password = password else {
                completion(success: false, error: nil)
                return
            }
            loginRequest(username, password: password, completion: completion)
        }

    }

    static func logout(completion: (success: Bool, error: NSError?) -> Void) {
        SessionRequest.Logout(completion: completion).execute()
    }

    static func fetchBranchZones(completion: (zones: [Zone], pager: Pager?, error: NSError?) -> Void) {
        guard let branchTag = branchTag else {
            let query = TagQuery(limit: 1, offset: 0)
            query.searchValue = DataCache.Constants.BranchTagName
            TagsRequest.Query(query) { (tags, pagination, error) in
                guard let branchTag = tags?.first else {
                    return // Nothing we can do
                }
                self.branchTag = branchTag
                let query = ZonesQuery.query()
                query.location = locationProvider?.location
                query.distance = Constants.BranchRadius
                query.tagIDs = [branchTag.id]
                query.orderBy = "distance"
                ZoneRequest.Query(query, completion: completion).execute()
            }.execute()
            return
        }
        let query = ZonesQuery.query()
        query.location = locationProvider?.location
        query.distance = Constants.BranchRadius
        query.tagIDs = [branchTag.id]
        query.orderBy = "distance"
        ZoneRequest.Query(query, completion: completion).execute()
    }

    static func fetchBranchContent(zoneID: String, completion: (moments: [Moment], pager: Pager?, error: NSError?) -> Void) {
        MomentRequest.GetZoneMoments(zoneID: zoneID, completion: completion).execute()
    }

    static func fetchConfigForPushedZone(zoneID: String, completion: (configuration: LayoutConfiguration?, error: NSError?) -> Void) {
        let finalCompletion: (configTagID: String, zoneID: String) -> Void = { (configTagID, zoneID) in
            let query = MomentQuery.queryWithLimit(1)
            query.tagIDs = [configTagID]
            query.zoneIDs = [zoneID]
            MomentRequest.Query(query) { (moments, pagination, error) in
                guard let configMoment = moments.first else {
                    // TODO: (TL) Error
                    completion(configuration: nil, error: nil)
                    return
                }
                MomentRequest.AutoValidate(moment: configMoment) { (validated, error) in
                    guard validated && error == nil else {
                        completion(configuration: nil, error: nil)
                        return
                    }
                    AOBRequest.Metadata(configMoment, completion: completion).execute()
                }.execute()
            }.execute()
        }
        guard let configTagID = DataCache.sharedCache.configTag?.id else {
            // Fetch config tag
            let query = TagQuery(limit: 1, offset: 0)
            query.searchValue = DataCache.Constants.ConfigurationTagName
            TagsRequest.Query(query) { (tags, pagination, error) in
                guard let configTag = tags?.first else {
                    // TODO: (TL) New error for can't find config tag
                    completion(configuration: nil, error: error)
                    return // Nothing we can do
                }
                finalCompletion(configTagID: configTag.id, zoneID: zoneID)
            }.execute()
            return
        }
        finalCompletion(configTagID: configTagID, zoneID: zoneID)
    }

    // MARK: - Helper Functions
    private static func loginRequest(email: String, password: String, completion: (success: Bool, error: NSError?) -> Void) {
        SessionRequest.Login(email: email, password: password, rememberMe: false) { (user, error) in
            guard user != nil && error == nil else {
                completion(success: false, error: error)
                return
            }
            NSNotificationCenter.defaultCenter().addObserverForName(PushManager.Constants.PushConnected, object: nil, queue: nil) { (notification) in
                DataCache.sharedCache.appConfig?.subscribeToPush()
            }
            NSNotificationCenter.defaultCenter().addObserverForName(PushManager.Constants.PushErrorTopic, object: nil, queue: nil) { (notification) in
                print("Push Error: \(notification.userInfo)")
            }

            if let apnsToken = DataCache.sharedCache.apnsToken {
                PushManager.sharedManager.configuration = PushConfiguration(serviceLevel: .Both, apnsToken: apnsToken)
            } else {
                PushManager.sharedManager.configuration = PushConfiguration(serviceLevel: .Foreground)
            }
            completion(success: true, error: nil)
        }.execute()
    }
}