//
//  RequestFeature.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

/// Provide request feature as per requirement.
///
/// - request: Provide simple request
/// - requestWithParameters: Request with custom body, query items and headers.
enum RequestFeature {
    case request
    case requestWithParameters(encoding: ParametersEncoding, urlParameters: Parameters, bodyParameters: Parameters, headers: Parameters)
}
