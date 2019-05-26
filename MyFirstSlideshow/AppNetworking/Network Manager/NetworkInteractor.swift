//
//  NetworkInteractor.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

typealias NetworkRequestCompletion = (_ info:AnyObject?, _ response: URLResponse?, _ error: Error?) -> ()

protocol InteractorProtocol {
    associatedtype Info: EndPoints
    
    func request(_ requestInfo:Info, completion completionBlock: @escaping NetworkRequestCompletion)
}

class NetworkInteractor<Info>: InteractorProtocol where Info: EndPoints {
    
    private var downloadTask: URLSessionDownloadTask?
    private var dataTask: URLSessionDataTask?
    
    func request(_ requestInfo: Info, completion completionBlock: @escaping NetworkRequestCompletion) {
        
        let session = URLSession.shared
        if let url = requestInfo.requestURL {
            
            do {
                switch requestInfo.task {
                case .dataTask:
                    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
                    
                    try buildRequest(&request, requestInfo: requestInfo)
                    
                    dataTask = session.dataTask(with: request) { (data, response, error) in
                        completionBlock(data as AnyObject, response, error)
                    }
                    
                    dataTask?.resume()
                    
                case .downloadTask:
                    downloadTask = session.downloadTask(with: url) { (url, urlResponse, error) in
                        completionBlock(url as AnyObject, urlResponse, error)
                    }
                    
                    downloadTask?.resume()
                }
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
