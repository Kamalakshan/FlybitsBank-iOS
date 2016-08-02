//
//  LayoutConfiguration.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-27.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit
import FlybitsSDK

// MARK: - Enums
struct Component {
    // MARK: - Enums
    enum Kind: String {
        case Title = "title"
        case Description = "description"
        case Person = "person"
        case Selection = "selection"
        case CallToAction = "cta"
        case Promo1 = "promo1"
        case Promo2 = "promo2"
    }

    enum ComponentProperty: String {
        case Title = "title"
        case Description = "description"
        case Description1 = "description1"
        case Description2 = "description2"
        case FirstName = "firstname"
        case LastName = "lastname"
        case Identifier = "id"
        case Icon = "icon"
        case Coupon = "coupon"
        case Selection = "selection"
        case Order = "order"
    }

    // MARK: - Properties
    var kind: Kind
    var properties: [ComponentProperty : String]
    var view: UIView

    // MARK: - Lifecycle Function
    init?(kind: Kind, properties: [ComponentProperty : String]) {
        guard let view = NSBundle.mainBundle().loadNibNamed(kind.rawValue, owner: nil, options: nil).first as? UIView else {
            return nil
        }
        self.kind = kind
        self.properties = properties
        self.view = view
    }

    init?(kind: String, content: [String : String]) {
        guard let componentKind = Kind(rawValue: kind) else {
            print("Unrecognized Component: \(kind)")
            return nil
        }
        self.kind = componentKind
        self.properties = [:]

        for (key, value) in content {
            guard let property = ComponentProperty(rawValue: key) else {
                print("Unrecognized property: \(key)")
                continue
            }
            properties[property] = value
        }
        view = UIView() // TODO: (TL)
    }
}

struct LayoutConfiguration: ResponseObjectSerializable {
    // MARK: - Properties
    let backgroundImage: UIImage
    let components: [Component]

    // MARK: - Lifecycle Functions
    init(backgroundImage: UIImage, components: [Component]) {
        self.backgroundImage = backgroundImage
        self.components = components
    }

    init?(response: NSHTTPURLResponse, representation: AnyObject) {
        // Base structure = "localizedKeyValuePairs" -> "en" -> "root" -> { ... }
        guard let baseObject = representation as? [String : AnyObject],
            localizationRoot = baseObject["localizedKeyValuePairs"] as? [String : AnyObject],
            localeRoot = localizationRoot["en"] as? [String : AnyObject],
            components = localeRoot["root"] as? [String : AnyObject] else {
            return nil // Invalid structure
        }

        var componentList = [Component]()
        for (kind, properties) in components {
            guard let content = properties as? [String : String], component = Component(kind: kind, content: content) else {
                continue
            }
            componentList.append(component)
        }


        // TODO: (TL) ...
        backgroundImage = UIImage()
        self.components = componentList
    }
}

/*
{
    "templateId":"sampleOffer2",
    "localizedKeyValuePairs":{
        "en":{
            "root":{
                "cta":{
                    "title":"REQUEST AN UBER",
                    "icon":"https://fbdevelopment.s3.amazonaws.com/moments/production/images/bb1dad0c-fe3b-4d27-854f-e689a380d761.png"
                },
                "title":"Accept our thanks for your business.",
                "promo2":{
                    "description":"Avoid the rain. Use the promo code below for $5 off a ride with Uber.",
                    "icon":"https://fbdevelopment.s3.amazonaws.com/moments/production/images/7a2daf84-513a-4f94-94d0-1f9692732542.png",
                    "coupon":"FLYBITSNATIONAL5"
                }
            }
        },
        "fr":{
            "root":{
                "cta":{
                    "title":null,
                    "icon":null
                },
                "title":null,
                "promo2":{
                    "description":null,
                    "icon":null,
                    "coupon":null
                }
            }
        },
        "ja":{
            "root":{
                "cta":{
                    "title":null,
                    "icon":null
                },
                "title":null,
                "promo2":{
                    "description":null,
                    "icon":null,
                    "coupon":null
                }
            }
        }
    }
}
 */
