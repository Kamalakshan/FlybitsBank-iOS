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
        case .Metadata(_, let completion):
            return FlybitsRequest(request: urlRequest).responseObject { (_, _, configuration: LayoutConfiguration?, error) in
                // TODO: (TL) Fields that require additional APIs i.e. PERSON, SELECTION
                completion(configuration: configuration, error: error)
            }
        }
    }
}
