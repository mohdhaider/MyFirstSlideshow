//
//  RequestInfo.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

enum HTTPType: String {
    case get = "GET"
    case post = "POST"
}

protocol EndPoints {
    var httpType: HTTPType {get}
    var requestURL: URL? {get}
    var requestType: RequestFeature {get}
}
