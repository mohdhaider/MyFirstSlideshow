//
//  NetworkInteractor.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

typealias NetworkRequestCompletion = (_ data:URL?, _ response: URLResponse?, _ error: Error?) -> ()

protocol InteractorProtocol {
    associatedtype Info: EndPoints
    
    func request(_ requestInfo:Info, completion completionBlock: @escaping NetworkRequestCompletion)
}

class NetworkInteractor<Info>: InteractorProtocol where Info: EndPoints {
    
    private var task: URLSessionDownloadTask?
    
    func request(_ requestInfo: Info, completion completionBlock: @escaping NetworkRequestCompletion) {
        
        let session = URLSession.shared
        if let url = requestInfo.requestURL {
            var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
            
            do {
                try buildRequest(&request, requestInfo: requestInfo)
                
                task = session.downloadTask(with: url) { (url, urlResponse, error) in
                    completionBlock(url, urlResponse, error)
                }
                
                task?.resume()
            } catch {
                completionBlock(nil, nil, error)
            }
        }
    }
    
    private func buildRequest(_ request: inout URLRequest, requestInfo: Info) throws {
        
        switch requestInfo.requestType {
        case .requestWithParameters(let encoding, let urlParameters, let bodyParameters, let headers):
            
            try encoding.encode(&request, urlParameters: urlParameters, bodyParameters: bodyParameters)
            addHeaders(request: &request, headers)
        default:
            break
        }
    }
    
    private func addHeaders(request  req: inout URLRequest, _ headers: Parameters) {
        for (key, value) in headers {
            req.setValue("\(value)", forHTTPHeaderField: key)
        }
    }
}
