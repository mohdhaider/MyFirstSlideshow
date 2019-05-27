//
//  NetworkInteractor.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit

typealias NetworkRequestCompletion = (_ info:Any?, _ response: URLResponse?, _ error: Error?) -> ()

protocol InteractorProtocol {
    associatedtype Info: EndPoints
    
    func request(_ requestInfo:Info, completion completionBlock: @escaping NetworkRequestCompletion)
}

class NetworkInteractor<Info>: NSObject, InteractorProtocol where Info: EndPoints {
    
    // MARK:- Variables -
    
    private var downloadTask: URLSessionDownloadTask?
    private var dataTask: URLSessionDataTask?
    private var completion:NetworkRequestCompletion?
    
    // MARK:- Initializers -
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
    // MARK:- Class Helpers -
    
    func request(_ requestInfo: Info, completion completionBlock: @escaping NetworkRequestCompletion) {
        
        if let url = requestInfo.requestURL {
            
            do {
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
                
                try buildRequest(&request, requestInfo: requestInfo)
                
                completion = completionBlock
                
                switch requestInfo.task {
                case .dataTask:
                    
                    let session = URLSession.shared
                    
                    dataTask = session.dataTask(with: request) {[weak self] (data, response, error) in
                        self?.completion?(data, response, error)
                    }
                    
                    dataTask?.resume()
                    
                case .downloadTask:
                    
                    if let task = BackgroundDownloader.shared.getDownloadTask(forRequest: request, delegate: self) {
                        
                        downloadTask = task
                        
                        downloadTask?.resume()
                    }
                    else {
                        completionBlock(nil, nil, nil)
                    }
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

extension NetworkInteractor: BackgroundDownloaderDelegate {
    
    func didFinishTask(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if downloadTask.originalRequest?.url == self.downloadTask?.originalRequest?.url {
            completion?(location, downloadTask.response, downloadTask.error)
        }
    }
    
    func didFinishWithError(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if task.originalRequest?.url == self.downloadTask?.originalRequest?.url {
            completion?(nil, task.response, error)
        }
    }
    
    func downloadProgress(_ session: URLSession, downloadTask: URLSessionDownloadTask, downloadProgress progress: Float) {
        print(progress)
    }
}
