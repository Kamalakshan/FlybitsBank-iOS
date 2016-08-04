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

        var nibName: String {
            switch self {
            case .Title:
                return "ComponentTitleView"
            case Description:
                return "ComponentDescriptionView"
            case Person:
                return "ComponentPersonView"
            case Selection:
                return "ComponentSelectionView"
            case CallToAction:
                return "ComponentCTAView"
            case Promo1:
                return "ComponentPromo1View"
            case Promo2:
                return "ComponentPromo2View"
            }
        }

        // In theory these could come from outside of the App (i.e. from a Moment)
        var mappings: [Property : Int] {
            switch self {
            case Title:
                return [
                    .Text : 1
                ]
            case Description:
                return [
                    .Text : 1
                ]
            case Person:
                return [
                    .Icon : 1,
                    .FirstName : 2,
                    .LastName : 3
                ]
            case Selection:
                return [
                    : // TODO: (TL) How do we do this one?
                ]
            case CallToAction:
                return [
                    .Icon : 1,
                    .Text : 2
                ]
            case Promo1:
                return [
                    .Icon : 1,
                    .Description1 : 2,
                    .Description2 : 3
                ]
            case Promo2:
                return [
                    .Icon : 1,
                    .Description : 2,
                    .Coupon : 3
                ]
            }
        }
    }

    // TODO: (TL) Revisit these names (description shouldn't have 3 versions, first name and last name need to be fetched not passed along
    enum Property: String {
        case Text = "text"
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

        var componentMapper: ComponentMapper {
            switch self {
            case Text, Description, Description1, Description2, FirstName, LastName, Identifier, Coupon, Selection:
                return TextComponentMapper()
            case Icon:
                return ImageComponentMapper()
            case Order:
                return EmptyComponentMapper()
            }
        }
    }

    // MARK: - Properties
    var kind: Kind
    var properties: [Property : String]
    var view: UIView

    // MARK: - Lifecycle Function
    init?(kind: Kind, properties: [Property : String]) {
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
            guard let property = Property(rawValue: key) else {
                print("Unrecognized property: \(key)")
                continue
            }
            properties[property] = value
        }

        guard let view = Utilities.viewForKind(componentKind, properties: properties, mappings: componentKind.mappings) else {
            print("Unable to construct view for kind: \(kind)")
            return nil
        }
        self.view = view
    }
}

struct LayoutConfiguration: ResponseObjectSerializable {
    // MARK: - Constants
    struct Constants {
        static let LocalizedKeyValuePairs = "localizedKeyValuePairs"
        static let Root = "root"
    }

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
            localizationRoot = baseObject[Constants.LocalizedKeyValuePairs] as? [String : AnyObject],
            localeRoot = localizationRoot[NSLocale.currentLocale().iso639String] as? [String : AnyObject],
            components = localeRoot[Constants.Root] as? [String : AnyObject] else {
            return nil // Invalid structure
        }

        var componentList = [Component]()
        for (kind, properties) in components {
            guard let content = properties as? [String : String], component = Component(kind: kind, content: content) else {
                continue
            }
            componentList.append(component)
        }


        // TODO: (TL) Get background image from Moment
        backgroundImage = UIImage()
        self.components = componentList.sort({ $0.0.properties[.Order] < $0.1.properties[.Order] })
    }
}
