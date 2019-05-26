//
//  RequestFeature.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

enum RequestFeature {
    case request
    case requestWithParameters(encoding: ParametersEncoding, urlParameters: Parameters, bodyParameters: Parameters, headers: Parameters)
}
