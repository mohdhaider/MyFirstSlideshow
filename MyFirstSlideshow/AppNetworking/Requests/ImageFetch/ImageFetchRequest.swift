//
//  ImageFetchRequest.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

enum BaseUrlDomains: String {
    case staticFlickrDomain = "c1.staticflickr.com"
    case staticReddItDomain = "i.redd.it"
    case variableUrlDomain = "www.kapstadt.de"
    case none
    
    init?(withUrl url: String) {
        
        var domain:BaseUrlDomains = .none
        
        if url.contains(BaseUrlDomains.staticFlickrDomain.rawValue) {
            domain = .staticFlickrDomain
        }
        else if url.contains(BaseUrlDomains.staticReddItDomain.rawValue) {
            domain = .staticReddItDomain
        }
        else if url.contains(BaseUrlDomains.variableUrlDomain.rawValue) {
            domain = .variableUrlDomain
        }
        
        switch domain {
        case .staticFlickrDomain:
            self = .staticFlickrDomain
        case .staticReddItDomain:
            self = .staticReddItDomain
        case .variableUrlDomain:
            self = .variableUrlDomain
        default:
            return nil
        }
    }
}

enum ImageRefreshPolicy {
    
    case defaultPolicy
    case timelyRefresh
    case none
    
    init?(withUrl url: String) {
        
        var policy:ImageRefreshPolicy = .none
        
        if let domain = BaseUrlDomains(withUrl: url) {
            switch domain {
            case .staticFlickrDomain, .staticReddItDomain:
                policy = .defaultPolicy
            case .variableUrlDomain:
                policy = .timelyRefresh
            default:
                break
            }
        }
        
        switch policy {
        case .defaultPolicy:
            self = .defaultPolicy
        case .timelyRefresh:
            self = .timelyRefresh
        default:
            return nil
        }
    }
}

enum ImageFetchRequest {
    case none
    case fetch(imageUrl: String, refreshPolicy: ImageRefreshPolicy)
}

extension ImageFetchRequest : EndPoints {
    
    var task: SessionTask {
        switch self {
        case .fetch(_, _):
            return .downloadTask
        default:
            return .dataTask
        }
    }
    
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
        
        var headers =  Parameters()
        let bodyParams =  Parameters()
        let urlParams =  Parameters()
        
        switch self {
        case .fetch(let imageUrl, _):
            if let savedHeaders = URLResponseCache().cachedUrlResponse(forKey: imageUrl) {
                headers = savedHeaders
            }
        default:
            break
        }
        
        return .requestWithParameters(encoding: .urlEncoding, urlParameters: urlParams, bodyParameters: bodyParams, headers: headers)
    }
}
