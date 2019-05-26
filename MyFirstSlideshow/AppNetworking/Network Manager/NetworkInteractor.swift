//
//  NetworkInteractor.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 25/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation
import UIKit

typealias NetworkRequestCompletion = (_ info:AnyObject?, _ response: URLResponse?, _ error: Error?) -> ()

protocol InteractorProtocol {
    associatedtype Info: EndPoints
    
    func request(_ requestInfo:Info, completion completionBlock: @escaping NetworkRequestCompletion)
}

final class BackgroundDownloader: NSObject, URLSessionDownloadDelegate {
    
    private var session: URLSession!
    
    // MARK:- Variables -
    
    static let shared = BackgroundDownloader()
    
    // MARK:- Initializers -
    
    private override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.Yoti.backgroundDownloads")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    // MARK:- Class Helpers -
    
    func getDownloadTask(forRequest request: URLRequest) -> URLSessionDownloadTask? {
     
        return session.downloadTask(with: request)
    }
    
    // MARK:- URLSessionDownloadDelegate -
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
   
        var arrInfos = [Any]()
        arrInfos.append(downloadTask)
        arrInfos.append(location)
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: NotificatinIdentifers.ImageDownloadingFinishNotifiaction.rawValue),
            object: arrInfos)
    }
}

class NetworkInteractor<Info>: NSObject, InteractorProtocol where Info: EndPoints {
    
    // MARK:- Variables -
    
    private var downloadTask: URLSessionDownloadTask?
    private var dataTask: URLSessionDataTask?
    private var completion:NetworkRequestCompletion?
    
    // MARK:- Initializers -
    
    override init() {
        super.init()
        addObservers()
    }
    
    deinit {
        removeObserver()
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
                        self?.completion?(data as AnyObject, response, error)
                    }
                    
                    dataTask?.resume()
                    
                case .downloadTask:
                    
                    downloadTask = BackgroundDownloader.shared.getDownloadTask(forRequest: request)
                    
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
    
    // MARK:- Notifications -
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imageDownlaoded(_:)),
            name: NSNotification.Name(rawValue: NotificatinIdentifers.ImageDownloadingFinishNotifiaction.rawValue),
            object: nil)
    }
    
    func removeObserver() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func imageDownlaoded(_ notif: Notification?) {
        
        if let arrObjs = notif?.object as? [Any] {
            
            var task:URLSessionDownloadTask?
            var location: URL?
            
            for obj in arrObjs {
                if let content = obj as? URL {
                    location = content
                }
                else if let content = obj as? URLSessionDownloadTask {
                    task = content
                }
            }
            
            if let downloadTask = downloadTask,
                let taskAvail = task,
                downloadTask === taskAvail{
                
                completion?(location as AnyObject, downloadTask.response, downloadTask.error)
            }
        }
    }
}
