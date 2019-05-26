//
//  ParametersEncoding.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

typealias Parameters = [String:Any]

protocol EncodingProtocol {
    func encode(_ request: inout URLRequest, parameters: Parameters) throws
}

enum ParametersEncoding {
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    
    func encode(_ request: inout URLRequest, urlParameters urlParams: Parameters, bodyParameters bodyParams: Parameters) throws {
        
        switch self {
        case .urlEncoding:
            try UrlParametersEncoding().encode(&request, parameters: urlParams)
        case .jsonEncoding:
            try JsonParametersEncoding().encode(&request, parameters: bodyParams)
        case .urlAndJsonEncoding:
            try UrlParametersEncoding().encode(&request, parameters: urlParams)
            try JsonParametersEncoding().encode(&request, parameters: bodyParams)
        }
    }
}

enum ParametersEncodingErrors: String, Error {
    case urlNotAvailable = "Url Not Available"
    case urlEncodingFailed = "Url Encoding Failed"
    case jsonEncodingFailed = "Json Encoding Failed"
}
