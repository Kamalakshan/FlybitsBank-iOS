//
//  AOBRequest.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-28.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import FlybitsSDK

enum AOBRequest: Requestable {

    case Metadata(Moment, completion: (configuration: LayoutConfiguration?, error: NSError?) -> Void)

	/// All requests are Custom requests.
	var requestType: FlybitsRequestType {
		return .Custom
	}

	/// Return the API's base URI. (i.e. http://api.flybits.com)
	var baseURI: String {
        switch self {
        case .Metadata(let moment, _):
            return moment.launchURL
        }
	}

	/// [OPTIONAL] Only required if the API does not use POST for all endpoints.
	var method: HTTPMethod {
        switch self {
        case .Metadata(let moment, _):
            return HTTPMethod(rawValue: moment.launchURLType.uppercaseString) ?? .GET
        }
	}

	/// [OPTIONAL] Only required if the API does not use JSON for encoding.
	var encoding: HTTPEncoding {
		return .URL
	}

	/// Paths for the endpoints defined above.
	var path: String {
		switch self {
		case .Metadata:
			return "KeyValuePairs/AsMetadata"
		}
	}

	/// [ADVANCED] An NSURLRequest is constructed automatically using the default implementation, only override in special cases.
	// var urlRequest: NSURLRequest

    func execute() -> FlybitsRequest {
        switch self {
        case let .Metadata(moment, completion):
            return FlybitsRequest(request: urlRequest).response { (_, _, data, error) in
                guard let data = data where error == nil else {
                    completion(configuration: nil, error: error)
                    return
                }

                let result = self.componentsFromResponse(data)
                guard let components = result.components where result.error == nil else {
                    completion(configuration: nil, error: result.error)
                    return
                }
                // TODO: (TL) Fields that require additional APIs i.e. PERSON, SELECTION
                guard let metadata = moment.metadata?.convertToClass(BaseMomentMetadata.self) else {
                    let userInfo: [String : AnyObject] = [
                        NSLocalizedDescriptionKey : "Unable to parse Moment Metadata",
                        NSLocalizedFailureReasonErrorKey : "Required metadata structure missing!",
                        NSLocalizedRecoverySuggestionErrorKey : "Please verify the properties available for Moment Metadata."
                    ]
                    completion(configuration: nil, error: MomentMetadataError.MetadataFormatError.error(userInfo))
                    return
                }

                let configuration = LayoutConfiguration(metadata: metadata, components: components)
                completion(configuration: configuration, error: nil)
            }
        }
    }

    private func componentsFromResponse(data: NSData) -> (components: [Component]?, error: NSError?) {
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) else {
            let userInfo: [String : AnyObject] = [
                NSLocalizedDescriptionKey : "Received Invalid Response",
                NSLocalizedFailureReasonErrorKey : "Cannot parse JSON object",
                NSLocalizedRecoverySuggestionErrorKey : "Please check your request and try again"
            ]
            return (components: nil, error: Error(NetworkingRequestError.UnableToParseResponse, userInfo: userInfo))
        }

        // Base structure = "localizedKeyValuePairs" -> "en" -> "root" -> { ... }
        guard let baseObject = json as? [String : AnyObject],
            localizationRoot = baseObject[LayoutConfiguration.Constants.LocalizedKeyValuePairs] as? [String : AnyObject],
            localeRoot = localizationRoot[NSLocale.currentLocale().iso639String] as? [String : AnyObject],
            rawComponents = localeRoot[LayoutConfiguration.Constants.Root] as? [String : AnyObject] else {
                let userInfo: [String : AnyObject] = [
                    NSLocalizedDescriptionKey : "Received Invalid Response",
                    NSLocalizedFailureReasonErrorKey : "Unexpected JSON format",
                    NSLocalizedRecoverySuggestionErrorKey : "Please verify the structure of the response"
                ]
                return (components: nil, error: Error(NetworkingRequestError.UnableToParseResponse, userInfo: userInfo)) // Invalid structure
        }

        var components = [Component]()
        for (kind, properties) in rawComponents {
            guard let content = properties as? [String : String], component = Component(kind: kind, content: content) else {
                continue
            }
            components.append(component)
        }
        components = components.sort({ $0.0.properties[.Order] < $0.1.properties[.Order] })

        return (components: components, error: nil)
    }
}
