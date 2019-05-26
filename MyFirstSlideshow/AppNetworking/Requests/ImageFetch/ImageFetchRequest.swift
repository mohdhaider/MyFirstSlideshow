//
//  ImageFetchRequest.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

enum ImageRefreshPolicy {
    
    case defaultPolicy
    case timelyRefresh
}

enum ImageFetchRequest {
    case none
    case fetch(imageUrl: String, refreshPolicy: ImageRefreshPolicy)
}

extension ImageFetchRequest : EndPoints {
    
    var requestURL: URL? {
        switch self {
        case .fetch(let imageUrl, _):
            return URL(string: imageUrl)
        default:
            return nil
        }
    }
    
    var httpType: HTTPType {
        return .get
    }
    
    var requestType: RequestFeature {
        
        let headers =  Parameters()
        let bodyParams =  Parameters()
        let urlParams =  Parameters()
        
        switch self {
        case .fetch(_, let refreshPolicy):
            break
        default:
            break
        }
        
        return .requestWithParameters(encoding: .urlEncoding, urlParameters: urlParams, bodyParameters: bodyParams, headers: headers)
    }
}
