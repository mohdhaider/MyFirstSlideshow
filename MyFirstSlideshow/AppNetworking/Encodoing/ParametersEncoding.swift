//
//  ParametersEncoding.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

typealias Parameters = [String:Any]

/// Encoding protocol to provide encoding(body, url and headers) to request generation.
protocol EncodingProtocol {
    func encode(_ request: inout URLRequest, parameters: Parameters) throws
}

/// Differnet request encodig features
///
/// - urlEncoding: Only url/query-items will added
/// - jsonEncoding: Body encoding will added
/// - urlAndJsonEncoding: Above both encoding will be in taken care off
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

/// Errors while encoding
///
/// - urlNotAvailable: URL not available to initila encoding
/// - urlEncodingFailed: Query items uncoding fails
/// - jsonEncodingFailed: Body encoding fails
enum ParametersEncodingErrors: String, Error {
    case urlNotAvailable = "Url Not Available"
    case urlEncodingFailed = "Url Encoding Failed"
    case jsonEncodingFailed = "Json Encoding Failed"
}
