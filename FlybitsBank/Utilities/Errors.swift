//
//  Errors.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-02.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import Foundation

enum AppConfigError: Int {
    case NoConfigTag
    case PushError

    var domain: String {
        return "com.flybits.config.error"
    }

    var error: NSError {
        return NSError(domain: domain, code: rawValue, userInfo: nil)
    }
}

enum CacheError: Int {
    case ConfigMissing
    case ConfigTagMissing
    case PushError

    var domain: String {
        return "com.flybits.cache.error"
    }

    var error: NSError {
        return NSError(domain: domain, code: rawValue, userInfo: nil)
    }
}

enum TagError: Int {
    case NoVisibleTags

    var domain: String {
        return "com.flybits.tags.error"
    }

    var error: NSError {
        return NSError(domain: domain, code: rawValue, userInfo: nil)
    }
}

enum MomentMetadataError: Int {
    case MetadataFormatError

    var domain: String {
        return "com.flybits.moments.metadata.error"
    }

    func error(userInfo: [String : AnyObject]?) -> NSError {
        return NSError(domain: domain, code: rawValue, userInfo: userInfo)
    }
}
